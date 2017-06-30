//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "PGARVideoProcessor.h"
#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>
#import <CoreImage/CoreImage.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <vector>
#include <cstring>
#import <UIKit/UIKit.h>

using namespace cv;
using namespace std;

static const float kFilterCoeffs[] = {1.0f,0.5f,0.25f};

#define FILTER_LEN (3)
#define VIDEO_SCALE (0.5f)

@interface PGARVideoProcessor() {
    Mat _cvToGl;
    Mat _cameraIntrinsic;
    Mat _descriptors;
    Ptr<Feature2D> _feature;
    Ptr<Feature2D> _featureSource;
    Ptr<Feature2D> _featureSourceCompute;
    Ptr<DescriptorMatcher> _matcher;
    BOOL _loaded;
    int _filterpos;
    int _frameCount;
    BOOL _enableFilter;
    float _filterWeight;
    GLKMatrix4 _filter[FILTER_LEN];
    
    vector<KeyPoint> _keyPoints;
    vector<Point2f> _corners;
    vector<Point3f> _planeCorners;
    vector<Point3f> _axisPoints;
}

@end

@implementation PGARVideoProcessor

- (instancetype)initWithArtifactSize:(CGSize)artifactSize videoSize:(CGSize)dim renderSize:(CGSize)renderSize fieldOfView:(float)fieldOfView keyPoints:(NSData *)keyPoints descriptors:(NSData *)descriptors
{
    self = [super init];
    if (self) {
        
        _filterWeight = 0;
        for( int i = 0 ; i < FILTER_LEN; i++ ) {
            _filterWeight += kFilterCoeffs[i];
        }
    
        _feature = ORB::create(500, 1.2f, 8, 31, 0, 2,ORB::HARRIS_SCORE, 31,20);
        //_matcher = new FlannBasedMatcher(new flann::LshIndexParams(5,24,2));
        _matcher = new BFMatcher(NORM_HAMMING,true);
        _loaded = NO;
        
        _cvToGl = Mat::zeros(4,4,CV_64FC1);
        _cvToGl.at<double>(0,0) = 1.0f;
        _cvToGl.at<double>(1,1) = -1.0f;
        _cvToGl.at<double>(2,2) = -1.0f;
        _cvToGl.at<double>(3,3) = 1.0f;
        _enableFilter = YES;
        
        for( int i = 0 ; i < FILTER_LEN ; i++ ) {
            memset(_filter[i].m,0x00,sizeof(_filter[i].m));
        }
        _filterpos = 0;
        _frameCount = 0;
        
        // Width and Height are flipped because video is portrait
        float w = dim.height * VIDEO_SCALE;
        float h = dim.width * VIDEO_SCALE;
        float cx = w / 2.0f;
        float cy = h / 2.0f;
        float VFOV = fieldOfView;
        float HFOV = ((VFOV)/cx)*cy;
        
        float ffx = fabs(w/2.0 * tan(HFOV/180.0 * M_PI));
        float ffy = fabs(h/2.0 * tan(VFOV/180.0 * M_PI));
        float f;
        if( h > w ) {
            f = ffy;
        } else {
            f = ffx;
        }
        
        _cameraIntrinsic = (Mat_<float>(3,3) << f, 0, cx, 0, f, cy, 0, 0, 1.0f);
        
        double zmax = 300;
        double zmin = 0.1;
        
        CGSize effectiveRenderSize;
        CGSize sentVideoSize = CGSizeMake(w/VIDEO_SCALE,h/VIDEO_SCALE);
        CGRect targetRect = [PGARVideoProcessor calcTargetVideoRect:sentVideoSize inView:renderSize];
        CGFloat viewAspect = renderSize.height/renderSize.width;
        
        BOOL hx = targetRect.size.width == renderSize.width;
        if( hx ) {
            effectiveRenderSize.height = targetRect.size.height;
            effectiveRenderSize.width = effectiveRenderSize.height /viewAspect;
        } else {
            effectiveRenderSize.width = targetRect.size.width;
            effectiveRenderSize.height = effectiveRenderSize.width * viewAspect;
        }
        
        CGFloat wprop = effectiveRenderSize.width/w;
        CGFloat hprop = effectiveRenderSize.height/h;
        
        if( hx ) {
            f *=  wprop;
        } else {
            f *= hprop;
        }

        w *= wprop;
        h *= hprop;
        cx *= wprop;
        cy *= hprop;
        
        GLKMatrix4 m4;
        m4.m[0] = 2 * f/w;
        m4.m[1] = 0;
        m4.m[2] = 0,
        m4.m[3] = 0,
        m4.m[4] = 0;
        m4.m[5] = 2 * f/h;
        m4.m[6] = 0;
        m4.m[7] = 0;
        m4.m[8] = 2 * (cx/w) - 1;
        m4.m[9] = 2 * (cy/h) - 1;
        m4.m[10] = -(zmax+zmin)/(zmax-zmin);
        m4.m[11] = -1;
        m4.m[12] = 0;
        m4.m[13] = 0;
        m4.m[14] = -2*zmax*zmin/(zmax-zmin);
        m4.m[15] = 0;
        
        self.projection = SCNMatrix4FromGLKMatrix4(m4);
        
        // update local keypoints and descriptors
        NSUInteger length = [keyPoints length];
        char *bytes = (char *)[keyPoints bytes];
        
        while (length > 0) {
            KeyPoint k;
            
            memcpy(&k.pt.x,bytes,sizeof(k.pt.x));
            bytes += sizeof(k.pt.x);
            length -= sizeof(k.pt.x);
            
            memcpy(&k.pt.y,bytes,sizeof(k.pt.y));
            bytes += sizeof(k.pt.y);
            length -= sizeof(k.pt.y);
            
            memcpy(&k.angle,bytes,sizeof(k.angle));
            bytes += sizeof(k.angle);
            length -= sizeof(k.angle);
            
            memcpy(&k.size,bytes,sizeof(k.size));
            bytes += sizeof(k.size);
            length -= sizeof(k.size);
            
            memcpy(&k.response,bytes,sizeof(k.response));
            bytes += sizeof(k.response);
            length -= sizeof(k.response);
            
            memcpy(&k.octave,bytes,sizeof(k.octave));
            bytes += sizeof(k.octave);
            length -= sizeof(k.octave);
            
            memcpy(&k.class_id,bytes,sizeof(k.class_id));
            bytes += sizeof(k.class_id);
            length -= sizeof(k.class_id);
            
            _keyPoints.push_back(k);
        }
        
        length = [descriptors length];
        bytes = (char *)[descriptors bytes];
        
        int rows;
        memcpy(&rows,bytes,sizeof(int));
        bytes += sizeof(int);
        int cols;
        memcpy(&cols,bytes,sizeof(int));
        bytes += sizeof(int);
        int type;
        memcpy(&type,bytes,sizeof(int));
        bytes += sizeof(int);

        _descriptors = Mat(rows,cols,type);
        
        memcpy(_descriptors.data,bytes,_descriptors.elemSize() * _descriptors.total());
        
        [self loadPatternWithCols:artifactSize.width andRows:artifactSize.height];
    }
    
    return self;
}

//TODO: double check this includes SCALE
- (void) loadPatternWithCols:(float)cols andRows:(float)rows {
    Point2f tl(0, 0);
    Point2f tr(cols, 0);
    Point2f bl(0, rows);
    Point2f br(cols, rows);
    Point2f c(cols/2,rows/2);
    
    _corners.push_back(tl);
    _corners.push_back(tr);
    _corners.push_back(br);
    _corners.push_back(bl);
    _corners.push_back(c);
    
    float W = 2.0f/2.0f;
    float H = 3/2.0f;
    
    Point3f ptl(-W,H,0);
    Point3f ptr(W, H,0);
    Point3f pbl(-W,-H,0);
    Point3f pbr(W,-H,0);
    Point3f pc(0,0,0);
    
    _planeCorners.push_back(ptl);
    _planeCorners.push_back(ptr);
    _planeCorners.push_back(pbr);
    _planeCorners.push_back(pbl);
    _planeCorners.push_back(pc);
    
    
    Point3f zero(0,0,0);
    Point3f ax(1,0,0);
    Point3f ay(0,1,0);
    Point3f az(0,0,1);
    _axisPoints.push_back(zero);
    _axisPoints.push_back(ax);
    _axisPoints.push_back(ay);
    _axisPoints.push_back(az);
    
    _loaded = YES;
}

-(void) runTracker:(CMSampleBufferRef)sampleBuffer completion: (nullable void (^)(PGARVideoProcessorResult *res)) completion {
    CVImageBufferRef i = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(i, 0);
    
    uint8_t * base = (uint8_t*)CVPixelBufferGetBaseAddress(i);
    int w = (int)CVPixelBufferGetWidth(i);
    int h = (int)CVPixelBufferGetHeight(i);
    size_t stride = CVPixelBufferGetBytesPerRow(i);
    
    cv::Mat frameO(h,w,CV_8UC4,base,stride);
    Mat frame(h*VIDEO_SCALE,w*VIDEO_SCALE,CV_8UC4);
    resize(frameO,frame,frame.size(),0,0);
    
    PGARVideoProcessorResult *res = [[PGARVideoProcessorResult alloc] init];
    
    res.transAvailable = YES;
    res.detected = NO;
    
    if( _loaded ) {
        //        Mat ff;
        vector<KeyPoint> kp;
        Mat dd;
        _feature->detectAndCompute(frame, noArray(), kp, dd);
        
        //        BFMatcher bf(NORM_HAMMING, true);
        if( !dd.empty() ) {
            vector<DMatch, allocator<DMatch> > matches;
            
            _matcher->match(dd, _descriptors, matches);
            
            vector<Point2f> pt;
            vector<Point2f> ps;
    
            for (auto i = matches.begin(); i != matches.end();) {
                //                d1 += i->distance;
                if (i->distance > 64) {
                    i = matches.erase(i);
                } else {
                    pt.push_back(_keyPoints.at((unsigned long) i->trainIdx).pt);
                    ps.push_back(kp.at((unsigned long) i->queryIdx).pt);
                    i++;
                }
            }
            
            if( pt.size() >= 30 ) {
                Mat inliners;
                
                Mat homo = findHomography(pt, ps, CV_RANSAC, 10, inliners, 2000, 0.999);
                
                const uint8_t * ptr = inliners.data;
                int ic = 0;
                for( int i = 0 ; i < pt.size() ; i++ ) {
                    ic += (*ptr++) & 0x01;
                }
                
                if( (!homo.empty()) && ic > 30 ) {
                    
                    
                    vector<Point2f> tcorners1;
                    perspectiveTransform(_corners, tcorners1, homo);
                    
                    Mat rvec;
                    Mat tvec;
                    Vec4f coeffs(0,0,0,0);
                    solvePnP(_planeCorners, tcorners1, _cameraIntrinsic, coeffs, rvec, tvec);
                    
                    Mat rotation, viewMatrix(4,4,CV_64FC1);
                    Rodrigues(rvec, rotation);
                    
                    for( unsigned int row = 0; row < 3 ; row++ ) {
                        for( unsigned int col = 0 ; col < 3; col++ ) {
                            viewMatrix.at<double>(row,col) = rotation.at<double>(row,col);
                        }
                        viewMatrix.at<double>(row,3) = tvec.at<double>(row,0);
                    }
                    
                    viewMatrix.at<double>(3,3) = 1.0f;
                    viewMatrix = _cvToGl * viewMatrix;
     
                    Mat glMatrix;
                    transpose(viewMatrix,glMatrix);

                    GLKMatrix4 m4;
                    for( int i = 0 ; i < 16 ; i++ ) {
                        m4.m[i] = glMatrix.at<double>(i);
                    }
                    
                    if( self.enableFilter ) {
                        _filter[_filterpos] = m4;
                        GLKMatrix4 mm;
                        memset(mm.m,0x00,sizeof(mm.m));
                        int j = _filterpos;
                        for( int i = 0 ; i < FILTER_LEN ; i++ ) {
                            GLKMatrix4 * x = & _filter[j];
                            for( int k = 0 ; k < 16 ; k++ ) {
                                mm.m[k] += x->m[k] * kFilterCoeffs[i];
                            }
                            j--;
                            if( j < 0 ) {
                                j += FILTER_LEN;
                            }
                        }
                        for( int i = 0 ; i < 16 ; i++ ) {
                            mm.m[i] /= _filterWeight;
                        }
                        
                        res.trans = SCNMatrix4FromGLKMatrix4(mm);
                        _filterpos = (_filterpos + 1 ) % FILTER_LEN;
                    } else {
                        res.trans = SCNMatrix4FromGLKMatrix4(m4);
                    }
                    
                    res.detected = YES;
                }
            }
        }
        
    } else {
        res.transAvailable = NO;
    }
    
    
    res.videoFrame = [CIImage imageWithCVImageBuffer:i];
    
    CVPixelBufferUnlockBaseAddress(i, 0);
    _frameCount++;
    
    completion(res);
}

+(CGRect) calcTargetVideoRect:(CGSize) videoSize inView:(CGSize) viewSize {
    CGFloat aview = viewSize.height/viewSize.width;
    CGFloat aim = videoSize.height / videoSize.width;
    CGRect tgt = CGRectZero;
    if( aview < aim ) {
        tgt.size.width = viewSize.width;
        tgt.size.height = viewSize.width * aim;
        tgt.origin.y = -(tgt.size.height - viewSize.height) / 2.0f;
    } else {
        tgt.size.height = viewSize.height;
        tgt.size.width = viewSize.height / aim;
        tgt.origin.x = -(tgt.size.width - viewSize.width) / 2.0f;
    }
    return tgt;
}

@end

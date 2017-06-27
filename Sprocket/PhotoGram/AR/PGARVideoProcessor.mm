//
//  PGARVideoProcessor.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGARVideoProcessor.h"
#import <CoreImage/CoreImage.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>

#import <vector>
#include <cstring>
#import <UIKit/UIKit.h>

using namespace cv;
using namespace std;

#define FILTER_LEN (4)
#define VIDEO_SCALE (0.5f)

@interface PGARVideoProcessor() {
    Mat _cvToGl;
    Mat _cameraIntrinsic;
    Ptr<Feature2D> _feature;
    Ptr<Feature2D> _featureSource;
    Ptr<Feature2D> _featureCompute;
    Ptr<Feature2D> _featureSourceCompute;
    Ptr<DescriptorMatcher> _matcher;
    BOOL _loaded;
    int _filterpos;
    int _frameCount;
    BOOL _enableFilter;
    GLKMatrix4 _filter[FILTER_LEN];
    SCNMatrix4 _projection;
    
    vector<KeyPoint> _keyPoints;
    Mat _descriptors;
}

@end

@implementation PGARVideoProcessor

- (instancetype)initWithWidth:(float)width height:(float)height fieldOfView:(float)fieldOfView keyPoints:(NSData *)keyPoints descriptors:(NSData *)descriptors
{
    self = [super init];
    if (self) {
        _feature = _featureCompute = ORB::create(500, 1.2f, 8, 62, 0, 2,ORB::HARRIS_SCORE, 31,20);
        _featureSource = _featureSourceCompute = ORB::create(500, 1.2f, 8, 31, 0, 2,ORB::HARRIS_SCORE, 31,20);
        _matcher = new FlannBasedMatcher(new flann::LshIndexParams(5,24,2));
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
        
        float w = height * VIDEO_SCALE;
        float h = width * VIDEO_SCALE;
        float cx = w / 2.0f;
        float cy = h / 2.0f;
        float VFOV = fieldOfView*2;
        float HFOV = ((VFOV)/cx)*cy;
        float fx = fabs(w/2.0 * tan(HFOV/180.0 * M_PI/2.0));
        float fy = fabs(h/2.0 * tan(VFOV/180.0 * M_PI/2.0));
        
        _cameraIntrinsic = (Mat_<float>(3,3) << fx, 0, cx, 0, fy, cy, 0, 0, 1.0f);
        
        double zmax = 300;
        double zmin = 0.1;
        GLKMatrix4 m4;
        m4.m[0] = 2 * fx/w;
        m4.m[1] = 0;
        m4.m[2] = 0,
        m4.m[3] = 0,
        m4.m[4] = 0;
        m4.m[5] = 2 * fy/h;
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
        
        _projection = SCNMatrix4FromGLKMatrix4(m4);
        
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
    }
    
    return self;
}

@end

//
//  PGARImageProcessor.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/26/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "PGARImageProcessor.h"
#import <CoreImage/CoreImage.h>

using namespace cv;
using namespace std;

@interface PGARImageProcessor () {
}

@end

@implementation PGARImageProcessor

+(Mat) createMatFromImage:(UIImage*) image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace([image CGImage]);
    CGFloat cols = image.size.width * image.scale;
    CGFloat rows = image.size.height * image.scale;
    Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
    CGContextDrawImage(contextRef, CGRectMake(0,0,cols,rows),image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

-(PGMetarArtifact *) createORBPatternArtifact:(UIImage*) image {
    
    Mat _pattern;
    Ptr<Feature2D> _featureSource;
    Ptr<Feature2D> _featureSourceCompute;
    vector<KeyPoint> _keyPoints;
    Mat _descriptors;
    
    _featureSource = _featureSourceCompute = ORB::create(500, 1.2f, 8, 31, 0, 2,ORB::HARRIS_SCORE, 31,20);
    
    _pattern = [PGARImageProcessor createMatFromImage:image];
    
    // ORB on original image
    _featureSource->detect(_pattern, _keyPoints);
    _featureSourceCompute->compute(_pattern, _keyPoints, _descriptors);
    
    
    NSMutableData *keypointData = [[NSMutableData alloc] init];
    
    for (auto i = _keyPoints.begin(); i != _keyPoints.end(); i++) {
        KeyPoint & k = *i;
        [keypointData appendBytes: (const char*)&k.pt.x length: sizeof(k.pt.x)];
        [keypointData appendBytes: (const char*)&k.pt.y length: sizeof(k.pt.y)];
        [keypointData appendBytes: (const char*)&k.angle length: sizeof(k.angle)];
        [keypointData appendBytes: (const char*)&k.size length: sizeof(k.size)];
        [keypointData appendBytes: (const char*)&k.response length: sizeof(k.response)];
        [keypointData appendBytes: (const char*)&k.octave length: sizeof(k.octave)];
        [keypointData appendBytes: (const char*)&k.class_id length: sizeof(k.class_id)];
    }
    
    NSMutableData *descriptorData = [[NSMutableData alloc] init];
    
    int type = _descriptors.type();
    
    [descriptorData appendBytes: (const char *)&_descriptors.rows length: sizeof(int)];
    [descriptorData appendBytes: (const char *)&_descriptors.cols length: sizeof(int)];
    [descriptorData appendBytes: (const char *)&type length: sizeof(int)];
    [descriptorData appendBytes: (const char *)_descriptors.data length: _descriptors.elemSize() * _descriptors.total()];
    
    PGMetarArtifact *artifact = [[PGMetarArtifact alloc] init];
    
    artifact.descriptors = descriptorData;
    artifact.keypoints = keypointData;
    artifact.type = PGMetarArtifactTypeOrbFeature;
    artifact.bounds = CGRectMake(0,0,_pattern.cols,_pattern.rows);
    
    return artifact;
}

@end

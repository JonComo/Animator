//
//  ARMovieComposer.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARMovieComposer.h"

#import "NSURL+Unique.h"
#import "ARTimedURL.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
#define MOV_DIR [DOCUMENTS URLByAppendingPathComponent:@"movies"]

@import AVFoundation;

@implementation ARMovieComposer

+(void)renderData:(NSDictionary *)data completion:(RenderMovieBlock)block
{
    NSLog(@"Write Started");
    
    NSArray *images = data[MovieComposerImages];
    NSArray *audioURLS = data[MovieComposerAudio];
    
    NSURL *URL = [NSURL uniqueWithName:@"movie.mp4" inDirectory:MOV_DIR];
    
    UIImage *image = images[0];
    CGSize size = image.size;
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:URL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput
                                             assetWriterInputWithMediaType:AVMediaTypeVideo
                                             outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        int frameCount = 0;
        int kRecordingFPS = 24;
        CVPixelBufferRef buffer = NULL;
        
        for (UIImage *img in images)
        {
            buffer = [self pixelBufferFromCGImage:img.CGImage withSize:size];
            
            BOOL append_ok = NO;
            int j = 0;
            while (!append_ok && j < 30)
            {
                if (adaptor.assetWriterInput.readyForMoreMediaData)
                {
                    printf("appending %d attemp %d\n", frameCount, j);
                    
                    CMTime frameTime = CMTimeMake(frameCount,(int32_t) kRecordingFPS);
                    append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                    
                    if(buffer)
                        CVBufferRelease(buffer);
                    
                    [NSThread sleepForTimeInterval:0.05];
                }
                else
                {
                    printf("adaptor not ready %d, %d\n", frameCount, j);
                    [NSThread sleepForTimeInterval:0.1];
                }
                
                j++;
            }
            
            if (!append_ok) {
                printf("error appending image %d times %d\n", frameCount, j);
            }
            
            frameCount++;
        }
        
        
        //Finish the session:
        [videoWriterInput markAsFinished];
        [videoWriter finishWriting];
        NSLog(@"Write Ended");
        
        //Combine in audio clips
        [ARMovieComposer combineVideo:URL andAudioURLs:audioURLS completion:block];
    });
}

+(CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image withSize:(CGSize)frameSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    
    //CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+(void)combineVideo:(NSURL *)videoURL andAudioURLs:(NSArray *)audioURLs completion:(RenderMovieBlock)block
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //Add video
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    
    //Add audio
    for (ARTimedURL *timedURL in audioURLs)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[timedURL.URL path]]) {
            NSLog(@"Found file!");
        }
        
        AVURLAsset *assetAudio = [AVURLAsset assetWithURL:timedURL.URL];
        
        CMTime time = CMTimeMakeWithSeconds((float)timedURL.frame/24.0f, 24);
        
        AVAssetTrack *audioTrack = [[assetAudio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetAudio.duration) ofTrack:audioTrack atTime:time error:nil];
    }
    
    NSURL *exportURL = [NSURL uniqueWithName:@"finalMovie.mp4" inDirectory:MOV_DIR];
    
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:mutableComposition presetName:AVAssetExportPreset640x480];
    
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.outputURL = exportURL;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch([exporter status])
        {
            case AVAssetExportSessionStatusFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(nil);
                });
            } break;
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusCompleted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(exportURL);
                });
                
            } break;
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(nil);
                });
            } break;
        }
        
    }];
}

@end
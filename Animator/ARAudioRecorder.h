//
//  ARAudioRecorder.h
//  Animator
//
//  Created by Jon Como on 1/12/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARAudioRecorder : NSObject

@property (nonatomic, strong) NSMutableArray *URLs;

+(ARAudioRecorder *)audioRecorder;

+(void)enableAudioSession;

-(void)recordAtFrame:(int)frame;
-(void)stop;

-(void)clear;
-(void)undo;

@end

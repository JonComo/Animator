//
//  ARAudioRecorder.h
//  Animator
//
//  Created by Jon Como on 1/12/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioPlayer;

@interface ARAudioRecorder : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSMutableArray *URLs;

+(ARAudioRecorder *)audioRecorder;

+(void)enableAudioSession;

-(void)recordAtFrame:(int)frame;
-(void)stop;

-(void)playAudioAtFrame:(int)frame;

-(void)clear;
-(void)undo;

@end

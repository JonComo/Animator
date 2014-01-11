//
//  ARAnimation.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARAnimation : NSObject

@property int currentFrame;
@property (nonatomic, weak) NSMutableArray *parts;

+(ARAnimation *)animation;

-(void)play;
-(void)stop;

-(void)startRecording;
-(void)stopRecordingSave:(BOOL)save;

-(void)reset;

@end

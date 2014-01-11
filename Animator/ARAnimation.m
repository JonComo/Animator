//
//  ARAnimation.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimation.h"
#import "ARPart.h"

@implementation ARAnimation
{
    NSTimer *timerRecord;
    NSTimer *timerPlay;
    
    NSMutableArray *frames;
}

-(id)init
{
    if (self = [super init]) {
        //init
        _currentFrame = 0;
    }
    
    return self;
}

+(ARAnimation *)animation
{
    ARAnimation *animation = [[ARAnimation alloc] init];
    
    return animation;
}

-(void)play
{
    [timerPlay invalidate];
    timerPlay = nil;
    
    timerPlay = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(layoutNextFrame) userInfo:nil repeats:YES];
    
    [self layoutFrame:0];
}

-(void)stop
{
    [timerPlay invalidate];
    timerPlay = nil;
    
    [self layoutFrame:0];
}

-(void)layoutNextFrame
{
    self.currentFrame++;
    
    [self layoutFrame:self.currentFrame];
}

-(void)layoutFrame:(int)frame
{
    if (frame < 0 || frame > frames.count)
    {
        //reached end
        [self stop];
        return;
    }
    
    NSMutableArray *frameInfo = frames[frame];
    for (NSDictionary *info in frameInfo)
    {
        ARPart *part = info[@"part"];
        part.position = [info[@"p"] CGPointValue];
        part.zRotation = [info[@"r"] floatValue];
    }
    
    self.currentFrame = frame;
}

-(void)startRecording
{
    if (!frames) frames = [NSMutableArray array];
    
    [timerRecord invalidate];
    timerRecord = nil;
    
    timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(snapshot) userInfo:nil repeats:YES];
    
    [self snapshot];
}

-(void)stopRecordingSave:(BOOL)save
{
    [timerRecord invalidate];
    timerRecord = nil;
}

-(void)snapshot
{
    NSMutableArray *frameInfo = [NSMutableArray array];
    
    for (ARPart *part in self.parts)
    {
        NSValue *position = [NSValue valueWithCGPoint:part.position];
        NSNumber *rotation = @(part.zRotation);
        
        NSDictionary *info = @{@"part": part, @"p": position, @"r": rotation};
        
        [frameInfo addObject:info];
    }
    
    [frames addObject:frameInfo];
    
    self.currentFrame ++;
}

-(void)reset
{
    self.currentFrame = 0;
    [frames removeAllObjects];
}

@end

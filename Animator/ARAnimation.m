//
//  ARAnimation.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimation.h"
#import "ARAnimationScene.h"
#import "ARPart.h"

@implementation ARAnimation
{
    NSTimer *timerRecord;
    NSTimer *timerPlay;
    
    NSMutableArray *frames;
    
    int frameStartedRecording;
    
    //Rendering
    RenderBlock _renderBlock;
    NSMutableArray *renderImages;
    BOOL isRendering;
}

-(id)init
{
    if (self = [super init]) {
        //init
        _currentFrame = 0;
        _frameLimit = 240;
    }
    
    return self;
}

+(ARAnimation *)animationWithDelegate:(id<ARAnimationDelegate>)delegate
{
    ARAnimation *animation = [[ARAnimation alloc] init];
    
    animation.delegate = delegate;
    
    return animation;
}

-(void)play
{
    [timerPlay invalidate];
    timerPlay = nil;
    
    if (frames.count == 0) return;
    
    timerPlay = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(layoutNextFrame) userInfo:nil repeats:YES];
    
    [self layoutFrame:0];
    
    [self.delegate animationDidStartPlaying:self];
}

-(void)stop
{
    [timerPlay invalidate];
    timerPlay = nil;
    
    if (isRendering)
    {
        isRendering = NO;
        if (_renderBlock) _renderBlock(renderImages);
    }
    
    [self.delegate animationDidFinishPlaying:self];
}

-(void)layoutNextFrame
{
    self.currentFrame++;
    
    [self layoutFrame:self.currentFrame];
}

-(void)layoutFrame:(int)frame
{
    if (frame < 0 || frame > frames.count-1 || frames.count == 0){
        //reached end
        [self stop];
        return;
    }
    
    NSMutableArray *frameInfo = frames[frame];
    
    for (NSDictionary *info in frameInfo){
        ARPart *part = info[@"part"];
        part.position = [info[@"p"] CGPointValue];
        part.zRotation = [info[@"r"] floatValue];
    }
    
    self.currentFrame = frame;
    
    if (isRendering){
        [self renderCurrentFrame];
    }
}

-(void)startRecording
{
    if (!frames) frames = [NSMutableArray array];
    
    [timerRecord invalidate];
    timerRecord = nil;
    
    timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(snapshot) userInfo:nil repeats:YES];
    
    frameStartedRecording = self.currentFrame;
    
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
    
    for (ARPart *part in self.scene.parts)
    {
        NSValue *position = [NSValue valueWithCGPoint:part.position];
        NSNumber *rotation = @(part.zRotation);
        
        NSDictionary *info = @{@"part": part, @"p": position, @"r": rotation};
        
        [frameInfo addObject:info];
    }
    
    [frames addObject:frameInfo];
    
    self.currentFrame ++;
    
    NSLog(@"Captured frame: %i", self.currentFrame);
}

-(void)renderCompletion:(RenderBlock)block
{
    _renderBlock = block;
    isRendering = YES;
    
    if (!renderImages) renderImages = [NSMutableArray array];
    [renderImages removeAllObjects];
    
    [self play];
}

-(void)renderCurrentFrame
{
    //Render image
    UIGraphicsBeginImageContext(CGSizeMake(320, 320));
    [self.scene.view drawViewHierarchyInRect:CGRectMake(0, 0, 320, 320) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [renderImages addObject:image];
}

-(void)undo
{
    //delete up to the frame the recording was started at

    NSRange rangeToRemove = NSMakeRange(frameStartedRecording, self.currentFrame-frameStartedRecording);

    if (frames.count < rangeToRemove.location + rangeToRemove.length || frames.count == 0) return;

    [frames removeObjectsInRange:rangeToRemove];
    self.currentFrame = frameStartedRecording;
    
    [self layoutFrame:self.currentFrame];
}

-(void)restart
{
    self.currentFrame = 0;
    [frames removeAllObjects];
}

-(void)setCurrentFrame:(int)currentFrame
{
    _currentFrame = currentFrame;
    [self.delegate animationChangedFrames:self];
}

@end

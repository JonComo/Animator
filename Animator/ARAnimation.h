//
//  ARAnimation.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RenderBlock)(NSMutableArray *images, NSMutableArray *audio);

@class ARAnimationScene;
@class ARAnimation;

@protocol ARAnimationDelegate <NSObject>

-(void)animationDidStartPlaying:(ARAnimation *)animation;
-(void)animationDidFinishPlaying:(ARAnimation *)animation;

-(void)animationDidStartRecording:(ARAnimation *)animation;
-(void)animationDidFinishRecording:(ARAnimation *)animation;

-(void)animationChangedFrames:(ARAnimation *)animation;

@end

@interface ARAnimation : NSObject

@property (nonatomic, weak) id<ARAnimationDelegate> delegate;

@property int frameLimit;
@property (nonatomic, assign) int currentFrame;
@property (nonatomic, weak) ARAnimationScene *scene;
@property BOOL isRecording;

+(ARAnimation *)animationWithDelegate:(id<ARAnimationDelegate>)delegate;

-(void)play;
-(void)stop;

-(void)renderCompletion:(RenderBlock)block;

-(void)startRecording;
-(void)stopRecording;
-(void)stopRecordingDontSave;
-(void)snapshot;

-(void)restart;
-(void)undo;

@end
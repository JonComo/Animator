//
//  ARAnimationScene.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimationScene.h"

#import "ARTouchSystem.h"

#import "ARAnimation.h"

@interface ARAnimationScene () <ARAnimationDelegate>

@end

@implementation ARAnimationScene
{
    //Dragging system
    ARTouchSystem *touchSystem;
    
    //Play/record sprites
    SKSpriteNode *spriteProgress;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //init
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.backgroundColor = [UIColor whiteColor];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-40, -40, size.width + 80, size.height + 80)];
        
        _animation = [ARAnimation animationWithDelegate:self];
        _animation.scene = self;
        
        _parts = [NSMutableArray array];
        
        touchSystem = [ARTouchSystem touchSystemWithScene:self parts:_parts];
        touchSystem.allowsJointCreation = NO;
    }
    
    return self;
}

-(void)addPart:(ARPart *)part
{
    [self.parts addObject:part];
    [self addChild:part];
}

-(void)removePart:(ARPart *)part
{
    [self.parts removeObject:part];
    [part removeFromParent];
}

-(void)restart
{
    [self.animation restart];
    
    [self.physicsWorld removeAllJoints];
    
    //Remove parts above part line
    for (ARPart *part in self.parts)
        [part removeFromParent];
    
    [self.parts removeAllObjects];
}

-(void)animationDidStartRecording:(ARAnimation *)animation
{
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 2;
}

-(void)animationDidFinishRecording:(ARAnimation *)animation
{
    self.view.layer.borderWidth = 0;
}

-(void)animationDidStartPlaying:(ARAnimation *)animation
{
    self.physicsWorld.speed = 0;
}

-(void)animationDidFinishPlaying:(ARAnimation *)animation
{
    self.physicsWorld.speed = 1;
}

-(void)animationChangedFrames:(ARAnimation *)animation
{
    //show recording progress
    if (!spriteProgress)
    {
        spriteProgress = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.071 green:0.8 blue:0.9 alpha:1] size:CGSizeMake(0, 10)];
        [self addChild:spriteProgress];
    }
    
    spriteProgress.size = CGSizeMake(self.size.width * (float)animation.currentFrame/(float)animation.frameLimit, 4);
    spriteProgress.position = CGPointMake(spriteProgress.size.width/2, 2);
}

-(void)update:(NSTimeInterval)currentTime
{
    [touchSystem update:currentTime];
}

-(void)didSimulatePhysics
{
    [touchSystem didSimulatePhysics];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesBegan:touches withEvent:event];
    
    if (self.shouldRecord)
        [self.animation startRecording];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesEnded:touches withEvent:event];
    
    if (self.shouldRecord && self.animation.isRecording && touchSystem.touchNodes.count == 0)
        [self.animation stopRecording];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesEnded:touches withEvent:event];
}

@end

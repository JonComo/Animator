//
//  ARAnimationScene.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimationScene.h"

#import "ARAnimation.h"

static const uint32_t categoryPart = 0x1 << 1;
static const uint32_t categoryTouch = 0x1 << 2;

static const uint32_t categoryNone = 0x1 << 3;

@interface ARAnimationScene () <ARAnimationDelegate>

@end

@implementation ARAnimationScene
{
    //Dragging system
    SKPhysicsJointPin *joint;
    SKSpriteNode *nodeTouch;
    ARPart *nodeToDrag;
    CGPoint touchPosition;
    
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
    
}

-(void)didSimulatePhysics
{
    if (nodeTouch){
        //move towards current touch position
        nodeTouch.position = touchPosition;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    NSArray *nodes = [self nodesAtPoint:touchPosition];
    ARPart *topNode = [nodes lastObject];
    
    if (![self.parts containsObject:topNode]) return;
    
    nodeToDrag = topNode;
    
    nodeTouch = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)];
    nodeTouch.position = touchPosition;
    nodeTouch.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nodeTouch.size];
    nodeTouch.physicsBody.mass = 10;
    nodeTouch.physicsBody.categoryBitMask = categoryTouch;
    nodeTouch.physicsBody.collisionBitMask = categoryNone;
    
    [self addChild:nodeTouch];
    
    joint = [SKPhysicsJointPin jointWithBodyA:nodeToDrag.physicsBody bodyB:nodeTouch.physicsBody anchor:touchPosition];
    [self.physicsWorld addJoint:joint];
    
    [self.animation startRecording];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    nodeTouch.position = touchPosition;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    [nodeTouch removeFromParent];
    nodeTouch = nil;
    
    [self.physicsWorld removeJoint:joint];
    joint = nil;
    
    //Don't record animation if dragged offscreen
    [self.animation stopRecordingSave:YES];
    
    nodeToDrag = nil;
}

@end

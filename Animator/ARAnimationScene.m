//
//  ARAnimationScene.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimationScene.h"

#import "ARTouchNode.h"
#import "ARAnimation.h"

static const uint32_t categoryNone = 0x1 << 0;
static const uint32_t categoryTouch = 0x1 << 1;
static const uint32_t categoryPart = 0x1 << 3;

@interface ARAnimationScene () <ARAnimationDelegate>

@end

@implementation ARAnimationScene
{
    //Dragging system
    NSMutableArray *touchNodes;
    
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
    
}

-(void)didSimulatePhysics
{
    for (ARTouchNode *touchNode in touchNodes)
        touchNode.position = touchNode.lastPosition;
}

-(ARTouchNode *)touchNodeForTouch:(UITouch *)touch
{
    CGPoint position = [touch locationInNode:self];
    
    ARTouchNode *touchNode = [[ARTouchNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(20, 20)];
    
    touchNode.key = [NSString stringWithFormat:@"%d", (int)touch];
    NSLog(@"key: %@", touchNode.key);
    
    touchNode.position = position;
    touchNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:touchNode.size];
    touchNode.physicsBody.mass = 10;
    touchNode.physicsBody.categoryBitMask = categoryTouch;
    touchNode.physicsBody.collisionBitMask = categoryNone;
    
    return touchNode;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!touchNodes) touchNodes = [NSMutableArray array];
    
    UITouch *touch = [touches anyObject];
    
    ARTouchNode *touchNode = [self touchNodeForTouch:touch];
    
    CGPoint touchLocation = [touch locationInNode:self];
    NSArray *nodesAtPoint = [self nodesAtPoint:touchLocation];
    
    touchNode.lastPosition = touchLocation;
    [touchNodes addObject:touchNode];
    [self addChild:touchNode];
    
    //Get topmost node
    SKSpriteNode *top = [nodesAtPoint lastObject];
    
    if ([top isMemberOfClass:[ARPart class]]){
        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:touchNode.physicsBody bodyB:top.physicsBody anchor:touchLocation];
        [self.physicsWorld addJoint:joint];
    }
    
    if (self.shouldRecord)
        [self.animation startRecording];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches){
        ARTouchNode *touchNode;
        for (ARTouchNode *testNode in touchNodes){
            if ([testNode.key isEqualToString:[NSString stringWithFormat:@"%d", (int)touch]]) touchNode = testNode;
        }
        
        touchNode.position = [touch locationInNode:self];
        touchNode.lastPosition = touchNode.position;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [touches allObjects]){
        ARTouchNode *touchNode;
        for (ARTouchNode *testNode in touchNodes){
            if ([testNode.key isEqualToString:[NSString stringWithFormat:@"%d", (int)touch]]) touchNode = testNode;
        }
        
        [self removeTouchNode:touchNode];
    }
    
    if (self.shouldRecord && self.animation.isRecording && touchNodes.count == 0)
        [self.animation stopRecording];
    
    //NSLog(@"Touch nodes: %@", touchNodes);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)removeTouchNode:(ARTouchNode *)touchNode
{
    for (SKPhysicsJointPin *pin in touchNode.physicsBody.joints)
        [self.physicsWorld removeJoint:pin];
    
    [touchNode removeFromParent];
    [touchNodes removeObject:touchNode];
    touchNode = nil;
}

@end

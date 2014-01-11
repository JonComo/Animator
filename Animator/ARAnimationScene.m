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
static const uint32_t categoryCursor = 0x1 << 2;

static const uint32_t categoryNone = 0x1 << 3;
static const uint32_t categoryIgnore = 0x1 << 4;

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
    SKSpriteNode *spriteHideParts;
    SKSpriteNode *spriteRecordLength;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //init
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.backgroundColor = [UIColor orangeColor];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-40, -40, size.width + 80, size.height + 80)];
        
        _animation = [ARAnimation animationWithDelegate:self];
        _animation.scene = self;
        
        _parts = [NSMutableArray array];
        
        SKSpriteNode *sceneLine = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(320, 320)];
        sceneLine.position = CGPointMake(size.width/2, size.height - sceneLine.size.height/2);
        [self addChild:sceneLine];
        
        //Load archived parts
        [self loadParts];
    }
    
    return self;
}

-(void)loadParts
{
    NSArray *archived = [ARPart loadParts];
    for (ARPart *part in archived)
        [self addPart:part];
    
    //Reposition neatly
    //spread about the width
    int count = archived.count;
    for (ARPart *part in archived)
        part.position = CGPointMake((float)([archived indexOfObject:part]-(float)count/2)/(float)count * self.size.width + self.size.width/2 + 40, 40);
}

-(void)addPart:(ARPart *)part
{
    //add a sprite and put it in the parts location (0 - 80y)
    
    [self.parts addObject:part];
    [self addChild:part];
    part.position = CGPointMake(self.size.width/2, 40);
    part.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:MIN(part.size.width, part.size.height)/2];
    part.physicsBody.categoryBitMask = categoryPart;
    part.physicsBody.collisionBitMask = categoryNone;
}

-(void)removePart:(ARPart *)part
{
    [self.parts removeObject:part];
    [part removeFromParent];
}

-(void)restart
{
    [self.animation restart];
    
    //Remove parts above part line
    for (int i = self.parts.count-1; i>0; i--)
    {
        ARPart *part = self.parts[i];
        if (part.position.y > 80){
            [self removePart:part];
        }
    }
}

-(void)archiveParts
{
    for (ARPart *part in self.parts)
        [part save];
}

-(void)animationDidStartPlaying:(ARAnimation *)animation
{
    if (!spriteHideParts)
    {
        spriteHideParts = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(self.size.width, 80)];
        spriteHideParts.position = CGPointMake(self.size.width/2, 40);
    }
    
    [self addChild:spriteHideParts];
}

-(void)animationDidFinishPlaying:(ARAnimation *)animation
{
    [spriteHideParts removeFromParent];
}

-(void)animationChangedFrames:(ARAnimation *)animation
{
    [self updateProgress:(float)animation.currentFrame/(float)animation.frameLimit];
}

-(void)updateProgress:(float)progress
{
    //show recording progress
    if (!spriteRecordLength)
    {
        spriteRecordLength = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:0.071 green:0.8 blue:0.9 alpha:1] size:CGSizeMake(0, 10)];
        [self addChild:spriteRecordLength];
    }
    
    spriteRecordLength.size = CGSizeMake(self.size.width * progress, 4);
    spriteRecordLength.position = CGPointMake(spriteRecordLength.size.width/2, 82);
}

-(void)update:(NSTimeInterval)currentTime
{
    //auto scale down parts in parts location
    
    for (SKSpriteNode *sprite in self.parts)
    {
        if (sprite.position.y < 80)
        {
            //in parts
            
            if (sprite.xScale != 0.3)
            {
                sprite.xScale = 0.3;
                sprite.yScale = 0.3;
                sprite.physicsBody.collisionBitMask = categoryNone;
                sprite.physicsBody.categoryBitMask = categoryIgnore;
            }
        }else{
            if (sprite.xScale != 1)
            {
                sprite.xScale = 1;
                sprite.yScale = 1;
                sprite.physicsBody.collisionBitMask = categoryPart;
                sprite.physicsBody.categoryBitMask = categoryPart;
            }
        }
    }
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
    
    nodeToDrag = (ARPart *)[self nodeAtPoint:touchPosition];
    if (![self.parts containsObject:nodeToDrag]){
        nodeToDrag = nil;
        return;
    }
    
    if (nodeToDrag.position.y < 80)
    {
        ARPart *duplicate = [nodeToDrag copy];
        [self addChild:duplicate];
        [self.parts addObject:duplicate];
        
        nodeToDrag = duplicate;
    }
    
    nodeTouch = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(20, 20)];
    nodeTouch.position = touchPosition;
    nodeTouch.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nodeTouch.size];
    nodeTouch.physicsBody.mass = 10;
    nodeTouch.physicsBody.categoryBitMask = categoryCursor;
    nodeTouch.physicsBody.collisionBitMask = categoryNone;
    
    [self addChild:nodeTouch];
    
    if (nodeToDrag){
        joint = [SKPhysicsJointPin jointWithBodyA:nodeToDrag.physicsBody bodyB:nodeTouch.physicsBody anchor:touchPosition];
        [self.physicsWorld addJoint:joint];
    }
    
    if (nodeToDrag.position.y > 80)
    {
        //record pieces dragged that are out of the parts already
        [self.animation startRecording];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    nodeTouch.position = touchPosition;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nodeTouch removeFromParent];
    nodeTouch = nil;
    
    [self.physicsWorld removeJoint:joint];
    joint = nil;
    
    //Don't record animation if dragged offscreen
    if (nodeToDrag && nodeToDrag.position.y < 80){
        [self.animation stopRecordingSave:NO];
        nodeToDrag.position = CGPointMake(0, 2000);
    }else{
        [self.animation stopRecordingSave:YES];
    }
    
    nodeToDrag = nil;
}

@end

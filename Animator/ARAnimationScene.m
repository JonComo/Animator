//
//  ARAnimationScene.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimationScene.h"

@implementation ARAnimationScene
{
    NSMutableArray *parts;
    
    //animation
    int frames;
    int frameStartedDrag;
    NSTimer *timerPlay;
    NSTimer *timerRecord;
    
    //rendering
    BOOL isRendering;
    NSMutableArray *images;
    
    //Dragging system
    SKPhysicsJointPin *joint;
    SKSpriteNode *nodeTouch;
    ARPart *nodeToDrag;
    CGPoint touchPosition;
    
    RenderBlock _renderBlock;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //init
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.backgroundColor = [UIColor orangeColor];
        
        frames = 0;
        _currentFrame = 0;
        
        parts = [NSMutableArray array];
        
        SKSpriteNode *sceneLine = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(320, 320)];
        sceneLine.position = CGPointMake(size.width/2, size.height - sceneLine.size.height/2);
        [self addChild:sceneLine];
    }
    
    return self;
}

-(void)addPart:(ARPart *)part
{
    //add a sprite and put it in the parts location (0 - 40y)
    
    [parts addObject:part];
    [self addChild:part];
    part.position = CGPointMake(parts.count * 20, 20);
    part.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:MIN(part.size.width, part.size.height)/2];
}

-(void)play
{
    self.currentFrame = 0;
    
    [timerPlay invalidate];
    timerPlay = nil;
    
    timerPlay = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(layoutNextFrame) userInfo:nil repeats:YES];
}

-(void)reset
{
    self.currentFrame = 0;
    frames = 0;
    
    for (ARPart *part in parts)
        [part removeAllFrames];
}

-(void)renderCompletion:(RenderBlock)block
{
    _renderBlock = block;
    isRendering = YES;
    
    if (!images) images = [NSMutableArray array];
    [images removeAllObjects];
    
    [self play];
}

-(void)layoutNextFrame
{
    self.currentFrame++;
    
    if (self.currentFrame > frames){
        [timerPlay invalidate];
        timerPlay = nil;
        
        if (isRendering)
        {
            isRendering = NO; //Done rendering!
            
            if (_renderBlock) _renderBlock(images);
        }
        
        return;
    }
    
    for (ARPart *part in parts){
        [part layoutForFrame:self.currentFrame];
    }
    
    if (isRendering)
    {
        //Render image
        UIGraphicsBeginImageContext(CGSizeMake(320, 320));
        
        [self.view drawViewHierarchyInRect:CGRectMake(0, 0, 320, 400) afterScreenUpdates:YES];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [images addObject:image];
    }
}

-(void)snapshotFrame
{
    //Record frame
    self.currentFrame ++;
    frames ++;
    
    for (ARPart *part in parts){
        [part snapshotAtFrame:self.currentFrame];
    }
}

-(void)update:(NSTimeInterval)currentTime
{
    //auto scale down parts in parts location
    
    for (SKSpriteNode *sprite in parts)
    {
        if (sprite.position.y < 80)
        {
            //in parts
            sprite.xScale = 0.3;
            sprite.yScale = 0.3;
        }else{
            sprite.xScale = 1;
            sprite.yScale = 1;
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
    
    nodeToDrag = (SKSpriteNode *)[self nodeAtPoint:touchPosition];
    if (![parts containsObject:nodeToDrag]){
        nodeToDrag = nil;
        return;
    }
    
    nodeTouch = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(20, 20)];
    nodeTouch.position = touchPosition;
    nodeTouch.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nodeTouch.size];
    nodeTouch.physicsBody.mass = 10;
    
    [self addChild:nodeTouch];
    
    if (nodeToDrag){
        joint = [SKPhysicsJointPin jointWithBodyA:nodeToDrag.physicsBody bodyB:nodeTouch.physicsBody anchor:touchPosition];
        [self.physicsWorld addJoint:joint];
    }
    
    if (nodeToDrag.position.y > 80)
    {
        //record pieces dragged that are out of the parts already
        [timerRecord invalidate];
        timerRecord = nil;
        
        timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(snapshotFrame) userInfo:nil repeats:YES];
        frameStartedDrag = self.currentFrame;
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
    
    //Stop recording
    [timerRecord invalidate];
    timerRecord = nil;
    
    //Don't record animation if dragged offscreen
    if (nodeToDrag.position.y < 80){
        //delete recording
        for (ARPart *part in parts)
            [part removeFramesInRange:NSMakeRange(frameStartedDrag, self.currentFrame)];
        
        frames = frameStartedDrag;
        self.currentFrame = frameStartedDrag;
    }
    
    nodeToDrag = nil;
}

@end

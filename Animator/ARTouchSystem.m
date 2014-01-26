//
//  ARTouchSystem.m
//  Animator
//
//  Created by Jon Como on 1/15/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARTouchSystem.h"

#import "ARScene.h"

@implementation ARTouchSystem
{
    SKSpriteNode *spriteHide;
}

+(ARTouchSystem *)touchSystemWithScene:(ARScene *)scene parts:(NSMutableArray *)parts
{
    return [[ARTouchSystem alloc] initWithScene:scene parts:parts];
}

-(id)initWithScene:(ARScene *)scene parts:(NSMutableArray *)parts
{
    if (self = [super init]) {
        //init
        _scene = scene;
        _parts = parts;
        _allowsDeletion = YES;
        
        spriteHide = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(20, 20)];
        [scene addChild:spriteHide];
        spriteHide.position = CGPointMake(scene.size.width - 40, 40);
        spriteHide.alpha = 0;
    }
    
    return self;
}

-(void)setAllowsDeletion:(BOOL)allowsDeletion
{
    _allowsDeletion = allowsDeletion;
    
    spriteHide.alpha = allowsDeletion ? 0.2 : 0.0;
}

-(void)update:(NSTimeInterval)currentTime
{
    if (!self.allowsJointCreation) return;
    
    //Highlight parts that will get jointed
    for (ARPart *part in self.parts)
        part.alpha = 1;
    
    for (ARTouchNode *touchNode in self.touchNodes)
    {
        NSArray *partsToConnect = [self partsToConnectAtTouchNode:touchNode];
        
        for (ARPart *part in partsToConnect)
            part.alpha = 0.5;
    }
}

-(void)didSimulatePhysics
{
    for (ARTouchNode *touchNode in self.touchNodes)
        touchNode.position = touchNode.lastPosition;
}

-(void)enumerateTouchNodesForTouches:(NSSet *)touches block:(void(^)(ARTouchNode *touchNode, UITouch *touch))block
{
    for (UITouch *touch in touches){
        ARTouchNode *touchNode;
        for (ARTouchNode *testNode in self.touchNodes){
            if ([testNode.key isEqualToString:[NSString stringWithFormat:@"%d", (int)touch]]) touchNode = testNode;
        }
        
        if (block) block(touchNode, touch);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.touchNodes) self.touchNodes = [NSMutableArray array];
    
    UITouch *touch = [touches anyObject];
    
    ARTouchNode *touchNode = [ARTouchNode touchNodeForTouch:touch position:[touch locationInNode:self.scene]];
    
    touchNode.lastPosition = touchNode.position;
    [self.touchNodes addObject:touchNode];
    [self.scene addChild:touchNode];
    
    //Get topmost node
    ARPart *nodeDragging = [[self partsAtTouchNode:touchNode] lastObject];
    
    if (nodeDragging){
        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:touchNode.physicsBody bodyB:nodeDragging.physicsBody anchor:touchNode.position];
        [self.scene.physicsWorld addJoint:joint];
    }
    
    //UI
    if (self.allowsJointCreation){
        for (ARPart *part in self.parts){
            part.physicsBody.collisionBitMask = categoryNone;
        }
    }
    
    if (self.allowsDeletion) spriteHide.alpha = 0.5;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateTouchNodesForTouches:touches block:^(ARTouchNode *touchNode, UITouch *touch) {
        touchNode.position = [touch locationInNode:self.scene];
        touchNode.lastPosition = touchNode.position;
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateTouchNodesForTouches:touches block:^(ARTouchNode *touchNode, UITouch *touch) {
        
        if (self.allowsDeletion)
        {
            //Hiding parts
            if (ABS(spriteHide.position.x - touchNode.position.x) < 40 && ABS(spriteHide.position.y - touchNode.position.y) < 40)
            {
                //Get topmost node
                ARPart *nodeDragging = [[self partsAtTouchNode:touchNode] lastObject];
                [self.scene hideCharacterWithPart:nodeDragging];
            }
        }
        
        if (self.allowsJointCreation)
        {
            //Linking of parts
            NSArray *partsToConnect = [self partsToConnectAtTouchNode:touchNode];
            
            if (partsToConnect)
            {
                ARPart *partA = partsToConnect[0];
                ARPart *partB = partsToConnect[1];
                
                SKPhysicsJointPin *connector = [SKPhysicsJointPin jointWithBodyA:partA.physicsBody bodyB:partB.physicsBody anchor:touchNode.position];
                [self.scene.physicsWorld addJoint:connector];
                
                
                ARPinJoint *pinJoint = [ARPinJoint jointWithPartA:partA partB:partB anchorPoint:touchNode.position];
                if (!self.pinJoints) self.pinJoints = [NSMutableArray array];
                [self.pinJoints addObject:pinJoint];
            }
        }
        
        [self removeTouchNode:touchNode];
        
        if (self.touchNodes.count == 0){
            //Last touch - make all nodes back into parts so they can intersect
            if (self.allowsJointCreation)
            {
                for (ARPart *part in self.parts){
                    part.physicsBody.collisionBitMask = categoryPart;
                }
            }
            
            if (self.allowsDeletion) spriteHide.alpha = 0;
        }
    }];
}

-(void)removeTouchNode:(ARTouchNode *)touchNode
{
    for (SKPhysicsJointPin *pin in touchNode.physicsBody.joints)
        [self.scene.physicsWorld removeJoint:pin];
    
    [touchNode removeFromParent];
    [self.touchNodes removeObject:touchNode];
    touchNode = nil;
}

-(NSArray *)partsAtTouchNode:(ARTouchNode *)touchNode
{
    NSMutableArray *partsAtPoint = [[self.scene nodesAtPoint:touchNode.position] mutableCopy];
    
    if ([partsAtPoint containsObject:touchNode]) [partsAtPoint removeObject:touchNode];
    
    return partsAtPoint;
}

-(NSArray *)partsToConnectAtTouchNode:(ARTouchNode *)touchNode
{
    NSArray *partsAtPoint = [self partsAtTouchNode:touchNode];
    
    if (partsAtPoint.count >= 2){
        int c = partsAtPoint.count;
        return @[partsAtPoint[c-2], partsAtPoint[c-1]];
    }
    
    return nil;
}

@end

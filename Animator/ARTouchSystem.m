//
//  ARTouchSystem.m
//  Animator
//
//  Created by Jon Como on 1/15/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARTouchSystem.h"

#import "ARPart.h"

@implementation ARTouchSystem
{
    NSMutableArray *touchNodes;
}

+(ARTouchSystem *)touchSystemWithScene:(SKScene *)scene parts:(NSMutableArray *)parts
{
    ARTouchSystem *system = [ARTouchSystem new];
    
    system.scene = scene;
    system.parts = parts;
    
    return system;
}

-(void)update:(NSTimeInterval)currentTime
{
    if (!self.allowsJointCreation) return;
    
    //Highlight parts that will get jointed
    for (ARPart *part in self.parts)
        part.alpha = 1;
    
    for (ARTouchNode *touchNode in touchNodes)
    {
        NSArray *partsToConnect = [self partsToConnectAtTouchNode:touchNode];
        
        for (ARPart *part in partsToConnect)
            part.alpha = 0.5;
    }
}

-(void)didSimulatePhysics
{
    for (ARTouchNode *touchNode in touchNodes)
        touchNode.position = touchNode.lastPosition;
}

-(void)enumerateTouchNodesForTouches:(NSSet *)touches block:(void(^)(ARTouchNode *touchNode, UITouch *touch))block
{
    for (UITouch *touch in touches){
        ARTouchNode *touchNode;
        for (ARTouchNode *testNode in touchNodes){
            if ([testNode.key isEqualToString:[NSString stringWithFormat:@"%d", (int)touch]]) touchNode = testNode;
        }
        
        if (block) block(touchNode, touch);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!touchNodes) touchNodes = [NSMutableArray array];
    
    UITouch *touch = [touches anyObject];
    
    ARTouchNode *touchNode = [ARTouchNode touchNodeForTouch:touch position:[touch locationInNode:self.scene]];
    
    touchNode.lastPosition = touchNode.position;
    [touchNodes addObject:touchNode];
    [self.scene addChild:touchNode];
    
    //Get topmost node
    ARPart *nodeDragging = [[self partsAtTouchNode:touchNode] lastObject];
    
    if (nodeDragging){
        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:touchNode.physicsBody bodyB:nodeDragging.physicsBody anchor:touchNode.position];
        [self.scene.physicsWorld addJoint:joint];
    }
    
    for (ARPart *part in self.parts){
        part.physicsBody.collisionBitMask = categoryNone;
    }
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
        
        if (touchNodes.count == 0){
            //Last touch
            for (ARPart *part in self.parts){
                part.physicsBody.collisionBitMask = categoryPart;
            }
        }
    }];
}

-(void)removeTouchNode:(ARTouchNode *)touchNode
{
    for (SKPhysicsJointPin *pin in touchNode.physicsBody.joints)
        [self.scene.physicsWorld removeJoint:pin];
    
    [touchNode removeFromParent];
    [touchNodes removeObject:touchNode];
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

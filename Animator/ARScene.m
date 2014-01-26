//
//  ARScene.m
//  Animator
//
//  Created by Jon Como on 1/25/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARScene.h"

@implementation ARScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        //init
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
    for (SKPhysicsJoint *joint in part.physicsBody.joints) [self.physicsWorld removeJoint:joint];
    [self.parts removeObject:part];
    [part removeFromParent];
}

-(void)hideCharacterWithPart:(ARPart *)part
{
    NSMutableArray *workingNodes = [self nodesConnectedToNode:part];
    NSMutableArray *allNodes = [NSMutableArray arrayWithArray:workingNodes];
    
    BOOL lastNodeFound = NO;
    
    do {
        NSMutableArray *nextLevel = [NSMutableArray array];
        
        for (SKNode *node in workingNodes)
        {
            NSMutableArray *foundNodes = [self nodesConnectedToNode:(SKSpriteNode *)node];
            
            if (foundNodes.count != 0)
            {
                for (SKNode *foundNode in foundNodes)
                {
                    if (![allNodes containsObject:foundNode])
                    {
                        [nextLevel addObjectsFromArray:foundNodes];
                        [allNodes addObjectsFromArray:foundNodes];
                    }
                }
            }
        }
        
        if (nextLevel.count == 0){
            lastNodeFound = YES;
        }else{
            workingNodes = nextLevel;
        }
        
    } while (!lastNodeFound);
    
    for (SKNode *node in allNodes){
        node.position = CGPointMake(node.position.x, node.position.y + 4000);
    }
}

-(NSMutableArray *)nodesConnectedToNode:(SKSpriteNode *)node
{
    NSMutableArray *nodesInvolved = [NSMutableArray array];

    for (SKPhysicsJoint *joint in node.physicsBody.joints)
    {
        SKNode *nodeA = joint.bodyA.node;
        SKNode *nodeB = joint.bodyB.node;
        
        if (![nodesInvolved containsObject:nodeA]) [nodesInvolved addObject:nodeA];
        if (![nodesInvolved containsObject:nodeB]) [nodesInvolved addObject:nodeB];
    }
    
    return nodesInvolved;
}

@end
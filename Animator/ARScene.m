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
    NSMutableArray *nodesInvolved = [NSMutableArray array];
    
    
}

@end
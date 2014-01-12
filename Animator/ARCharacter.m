//
//  ARCharacter.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacter.h"
#import "ARPinJoint.h"

#import "ARAnimationScene.h"

@implementation ARCharacter

-(id)init
{
    if (self = [super init]) {
        //init
        _parts = [NSMutableArray array];
        _joints = [NSMutableArray array];
    }
    
    return self;
}

-(NSArray *)loadAll
{
    return nil;
}

-(void)saveWithThumbnail:(UIImage *)image
{
    
}

-(void)spawnInScene:(ARAnimationScene *)scene
{
    for (ARPart *part in self.parts){
        [scene addPart:part];
    }
    
    for (ARPinJoint *joint in self.joints)
    {
        //Calculate new anchor point
        CGPoint anchor = [joint newAnchor];
        
        SKPhysicsJointPin *pin = [SKPhysicsJointPin jointWithBodyA:joint.partA.physicsBody bodyB:joint.partB.physicsBody anchor:anchor];
        [scene.physicsWorld addJoint:pin];
    }
}

@end

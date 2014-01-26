//
//  ARCharacterScene.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacterScene.h"

#import "ARTouchSystem.h"

@implementation ARCharacterScene
{
    //Dragging system
    ARTouchSystem *touchSystem;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //init
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-40, -40, size.width + 80, size.height + 80)];
        
        touchSystem = [ARTouchSystem touchSystemWithScene:self parts:self.parts];
        touchSystem.allowsJointCreation = YES;
    }
    
    return self;
}

-(void)addPartFromImage:(UIImage *)image
{
    ARPart *part = [ARPart partWithImage:image];
    [self.parts addObject:part];
    [self addChild:part];
    
    part.position = CGPointMake(self.size.width/2, self.size.height/2);
    
    part.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:MIN(part.size.width/2, part.size.height/2)];
    part.physicsBody.angularDamping = 0.8;
    part.physicsBody.categoryBitMask = categoryPart;
    part.physicsBody.collisionBitMask = categoryPart;
}

-(void)clear
{
    [self.physicsWorld removeAllJoints];
    
    for (ARPart *part in self.parts)
        [part removeFromParent];
    
    [self.parts removeAllObjects];
    [touchSystem.pinJoints removeAllObjects];
}

-(void)undo
{
    if (self.parts.count == 0) return;
    
    ARPart *lastAdded = [self.parts lastObject];
    
    for (SKPhysicsJointPin *pin in lastAdded.physicsBody.joints)
        [self.physicsWorld removeJoint:pin];
    
    NSMutableArray *pinsToRemove = [NSMutableArray array];
    for (ARPinJoint *pin in touchSystem.pinJoints){
        if (pin.partA == lastAdded || pin.partB == lastAdded){
            [pinsToRemove addObject:pin];
        }
    }
    
    [touchSystem.pinJoints removeObjectsInArray:pinsToRemove];
    
    [self.parts removeObject:lastAdded];
    [lastAdded removeFromParent];
}

-(ARCharacter *)character
{
    //copy all parts and joints
    ARCharacter *character = [ARCharacter new];
    
    //Add back collisions to other parts
    for (ARPart *part in self.parts)
        part.physicsBody.collisionBitMask = categoryPart;
    
    [character.parts addObjectsFromArray:self.parts];
    
    character.joints = touchSystem.pinJoints;
    
    for (ARPart *part in self.parts)
        [part removeFromParent];
    
    [self.parts removeAllObjects];
    
    return character;
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
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchSystem touchesEnded:touches withEvent:event];
}

@end

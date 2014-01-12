//
//  ARCharacterScene.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacterScene.h"

#import "ARPinJoint.h"

static const uint32_t categoryNone = 0x1 << 0;
static const uint32_t categoryTouch = 0x1 << 1;
static const uint32_t categoryPart = 0x1 << 3;

@implementation ARCharacterScene
{
    NSMutableArray *parts;
    NSMutableArray *joints;
    
    //Dragging system
    SKPhysicsJointPin *joint;
    SKSpriteNode *nodeTouch;
    ARPart *nodeToDrag;
    CGPoint touchPosition;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //init
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-40, -40, size.width + 80, size.height + 80)];
        
        parts = [NSMutableArray array];
        joints = [NSMutableArray array];
    }
    
    return self;
}

-(void)addPartFromImage:(UIImage *)image
{
    ARPart *part = [ARPart partWithImage:image];
    [parts addObject:part];
    [self addChild:part];
    
    part.position = CGPointMake(self.size.width/2, self.size.height/2);
    part.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:MIN(part.size.width/2, part.size.height/2)];
    part.physicsBody.mass = 0.05;
    part.physicsBody.angularDamping = 0.2;
    part.physicsBody.categoryBitMask = categoryPart;
    part.physicsBody.collisionBitMask = categoryPart;
}

-(void)clear
{
    [self.physicsWorld removeAllJoints];
    
    for (ARPart *part in parts)
        [part removeFromParent];
    
    [parts removeAllObjects];
    [joints removeAllObjects];
}

-(void)undo
{
    if (parts.count == 0) return;
    
    ARPart *lastAdded = [parts lastObject];
    
    for (SKPhysicsJointPin *pin in lastAdded.physicsBody.joints)
        [self.physicsWorld removeJoint:pin];
    
    [parts removeObject:lastAdded];
    [lastAdded removeFromParent];
}

-(ARCharacter *)character
{
    //copy all parts and joints
    ARCharacter *character = [ARCharacter new];
    
    [character.parts addObjectsFromArray:parts];
    
    character.joints = joints;
    
    for (ARPart *part in parts)
        [part removeFromParent];
    
    return character;
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
    
    if (![parts containsObject:topNode]) return;
    
    nodeToDrag = topNode;
    
    nodeToDrag.physicsBody.collisionBitMask = categoryNone;
    
    nodeTouch = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)];
    nodeTouch.position = touchPosition;
    nodeTouch.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nodeTouch.size];
    nodeTouch.physicsBody.mass = 10;
    nodeTouch.physicsBody.categoryBitMask = categoryTouch;
    nodeTouch.physicsBody.collisionBitMask = categoryNone;
    
    [self addChild:nodeTouch];
    
    joint = [SKPhysicsJointPin jointWithBodyA:nodeToDrag.physicsBody bodyB:nodeTouch.physicsBody anchor:touchPosition];
    [self.physicsWorld addJoint:joint];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    nodeTouch.position = touchPosition;
    
    for (ARPart *part in parts)
        part.alpha = 1;
    
    ARPart *partToConnect = [self partToConnectAtLocation:touchPosition];
    
    if (partToConnect){
        partToConnect.alpha = 0.8;
        nodeToDrag.alpha = 0.8;
    }else{
        nodeToDrag.alpha = 1;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPosition = [touch locationInNode:self];
    
    [nodeTouch removeFromParent];
    nodeTouch = nil;
    
    [self.physicsWorld removeJoint:joint];
    joint = nil;
    
    //Experimental linking of parts
    ARPart *partToConnect = [self partToConnectAtLocation:touchPosition];
    
    if (partToConnect)
    {
        SKPhysicsJointPin *connector = [SKPhysicsJointPin jointWithBodyA:nodeToDrag.physicsBody bodyB:partToConnect.physicsBody anchor:touchPosition];
        [self.physicsWorld addJoint:connector];
        
        ARPinJoint *pinJoint = [ARPinJoint jointWithPartA:nodeToDrag partB:partToConnect anchorPoint:touchPosition];
        [joints addObject:pinJoint];
    }
    
    nodeToDrag.physicsBody.collisionBitMask = categoryPart;
    
    nodeToDrag = nil;
    
    for (ARPart *part in parts)
        part.alpha = 1;
}

-(ARPart *)partToConnectAtLocation:(CGPoint)location
{
    NSArray *allNodes = [self nodesAtPoint:touchPosition];
    NSMutableArray *partNodes = [NSMutableArray array];
    for (SKSpriteNode *node in allNodes){
        if ([parts containsObject:node] && node != nodeToDrag) [partNodes addObject:node];
    }
    
    ARPart *topNode;
    
    if (partNodes.count > 0)
        topNode = [partNodes lastObject];
    
    return topNode;
}

@end

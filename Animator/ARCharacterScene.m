//
//  ARCharacterScene.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacterScene.h"

#import "ARTouchNode.h"
#import "ARPinJoint.h"

static const uint32_t categoryNone = 0x1 << 0;

static const uint32_t categoryTouch = 0x1 << 1;
static const uint32_t categoryPart = 0x1 << 3;
static const uint32_t categoryDragged = 0x1 << 4;


@implementation ARCharacterScene
{
    NSMutableArray *parts;
    NSMutableArray *joints;
    
    //Dragging system
    NSMutableArray *touchNodes;
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
    
    NSMutableArray *pinsToRemove = [NSMutableArray array];
    for (ARPinJoint *pin in joints){
        if (pin.partA == lastAdded || pin.partB == lastAdded){
            [pinsToRemove addObject:pin];
        }
    }
    
    [joints removeObjectsInArray:pinsToRemove];
    
    [parts removeObject:lastAdded];
    [lastAdded removeFromParent];
}

-(ARCharacter *)character
{
    //copy all parts and joints
    ARCharacter *character = [ARCharacter new];
    
    //Add back collisions to other parts
    for (ARPart *part in parts)
        part.physicsBody.collisionBitMask = categoryPart;
    
    [character.parts addObjectsFromArray:parts];
    
    character.joints = joints;
    
    for (ARPart *part in parts)
        [part removeFromParent];
    
    return character;
}

-(void)update:(NSTimeInterval)currentTime
{
    //Highlight parts that will get jointed
    for (ARPart *part in parts)
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
    
    ARTouchNode *touchNode = [ARTouchNode touchNodeForTouch:touch position:[touch locationInNode:self]];
    
    touchNode.lastPosition = touchNode.position;
    [touchNodes addObject:touchNode];
    [self addChild:touchNode];
    
    //Get topmost node
    ARPart *nodeDragging = [[self partsAtTouchNode:touchNode] lastObject];
    
    if (nodeDragging){
        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:touchNode.physicsBody bodyB:nodeDragging.physicsBody anchor:touchNode.position];
        [self.physicsWorld addJoint:joint];
    }
    
    for (ARPart *part in parts){
        part.physicsBody.collisionBitMask = categoryNone;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateTouchNodesForTouches:touches block:^(ARTouchNode *touchNode, UITouch *touch) {
        touchNode.position = [touch locationInNode:self];
        touchNode.lastPosition = touchNode.position;
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enumerateTouchNodesForTouches:touches block:^(ARTouchNode *touchNode, UITouch *touch) {
        
        //Linking of parts
        NSArray *partsToConnect = [self partsToConnectAtTouchNode:touchNode];
        
        if (partsToConnect)
        {
            ARPart *partA = partsToConnect[0];
            ARPart *partB = partsToConnect[1];
            
            SKPhysicsJointPin *connector = [SKPhysicsJointPin jointWithBodyA:partA.physicsBody bodyB:partB.physicsBody anchor:touchNode.position];
            [self.physicsWorld addJoint:connector];
            
            ARPinJoint *pinJoint = [ARPinJoint jointWithPartA:partA partB:partB anchorPoint:touchNode.position];
            [joints addObject:pinJoint];
        }
        
        [self removeTouchNode:touchNode];
        
        if (touchNodes.count == 0){
            //Last touch
            for (ARPart *part in parts){
                part.physicsBody.collisionBitMask = categoryPart;
            }
        }
    }];
}

-(void)removeTouchNode:(ARTouchNode *)touchNode
{
    for (SKPhysicsJointPin *pin in touchNode.physicsBody.joints)
        [self.physicsWorld removeJoint:pin];
    
    [touchNode removeFromParent];
    [touchNodes removeObject:touchNode];
    touchNode = nil;
}

-(NSArray *)partsAtTouchNode:(ARTouchNode *)touchNode
{
    NSMutableArray *partsAtPoint = [[self nodesAtPoint:touchNode.position] mutableCopy];
    
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

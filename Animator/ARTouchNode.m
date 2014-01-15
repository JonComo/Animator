//
//  ARTouchNode.m
//  Animator
//
//  Created by Jon Como on 1/14/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARTouchNode.h"

static const uint32_t categoryNone = 0x1 << 0;
static const uint32_t categoryTouch = 0x1 << 1;
static const uint32_t categoryPart = 0x1 << 3;
static const uint32_t categoryDragged = 0x1 << 4;

@implementation ARTouchNode

+(ARTouchNode *)touchNodeForTouch:(UITouch *)touch position:(CGPoint)position
{
    ARTouchNode *touchNode = [[ARTouchNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(20, 20)];
    
    touchNode.key = [NSString stringWithFormat:@"%d", (int)touch];
    NSLog(@"key: %@", touchNode.key);
    
    touchNode.position = position;
    touchNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:touchNode.size];
    touchNode.physicsBody.mass = 10;
    touchNode.physicsBody.categoryBitMask = categoryTouch;
    touchNode.physicsBody.collisionBitMask = categoryNone;
    
    return touchNode;
}

@end
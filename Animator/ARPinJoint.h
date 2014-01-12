//
//  ARPinJoint.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class ARPart;

@interface ARPinJoint : SKSpriteNode

@property (nonatomic, weak) ARPart *partA;
@property (nonatomic, weak) ARPart *partB;

@property float rotation;
@property float distance;

+(ARPinJoint *)jointWithPartA:(ARPart *)a partB:(ARPart *)b anchorPoint:(CGPoint)anchor;

-(CGPoint)newAnchor;

@end
//
//  ARPinJoint.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARPinJoint.h"
#import "ARPart.h"
#import "JCMath.h"

@implementation ARPinJoint

+(ARPinJoint *)jointWithPartA:(ARPart *)a partB:(ARPart *)b anchorPoint:(CGPoint)anchor
{
    ARPinJoint *joint = [ARPinJoint new];
    
    joint.partA = a;
    joint.partB = b;
    
    //calculate rotation and distance
    joint.rotation = [JCMath angleFromPoint:a.position toPoint:anchor] - a.zRotation;
    joint.distance = [JCMath distanceBetweenPoint:a.position andPoint:anchor sorting:NO];
    
    return joint;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //init
        _distance = [aDecoder decodeFloatForKey:@"distance"];
        _rotation = [aDecoder decodeFloatForKey:@"rotation"];
        
        _partA = [aDecoder decodeObjectForKey:@"partA"];
        _partB = [aDecoder decodeObjectForKey:@"partB"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:self.distance forKey:@"distance"];
    [aCoder encodeFloat:self.rotation forKey:@"rotation"];
    
    [aCoder encodeObject:self.partA forKey:@"partA"];
    [aCoder encodeObject:self.partB forKey:@"partB"];
}

-(CGPoint)newAnchor
{
    CGPoint anchor = [JCMath pointFromPoint:self.partA.position pushedBy:self.distance inDirection:self.rotation + self.partA.zRotation];
    
    return anchor;
}

@end
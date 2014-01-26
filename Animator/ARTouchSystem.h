//
//  ARTouchSystem.h
//  Animator
//
//  Created by Jon Como on 1/15/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARTouchNode.h"
#import "ARPinJoint.h"

#import "ARPhysicsCategories.h"

@import SpriteKit;

@class ARScene;

@interface ARTouchSystem : NSObject

@property (nonatomic, weak) ARScene *scene;
@property (nonatomic, weak) NSMutableArray *parts;
@property (nonatomic, strong) NSMutableArray *pinJoints;

@property (nonatomic, strong) NSMutableArray *touchNodes;

+(ARTouchSystem *)touchSystemWithScene:(ARScene *)scene parts:(NSMutableArray *)parts;

@property BOOL allowsJointCreation;
@property BOOL allowsDeletion;

-(void)update:(NSTimeInterval)currentTime;
-(void)didSimulatePhysics;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
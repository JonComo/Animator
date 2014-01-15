//
//  ARTouchSystem.h
//  Animator
//
//  Created by Jon Como on 1/15/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARTouchNode.h"
#import "ARPhysicsCategories.h"

@import SpriteKit;

@interface ARTouchSystem : NSObject

@property (nonatomic, weak) SKScene *scene;
@property (nonatomic, weak) NSMutableArray *parts;
@property (nonatomic, strong) NSMutableArray *pinJoints;

+(ARTouchSystem *)touchSystemWithScene:(SKScene *)scene parts:(NSMutableArray *)parts;

-(void)update:(NSTimeInterval)currentTime;
-(void)didSimulatePhysics;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
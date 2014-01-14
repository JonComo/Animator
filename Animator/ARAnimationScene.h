//
//  ARAnimationScene.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ARAnimation.h"
#import "ARPart.h"

@interface ARAnimationScene : SKScene

@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong) ARAnimation *animation;

@property BOOL shouldRecord;

-(void)addPart:(ARPart *)part;
-(void)restart;

@end
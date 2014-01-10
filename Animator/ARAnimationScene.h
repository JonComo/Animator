//
//  ARAnimationScene.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ARPart.h"

typedef void (^RenderBlock)(NSMutableArray *images);

@interface ARAnimationScene : SKScene

@property int currentFrame;

-(void)addPart:(ARPart *)part;

-(void)play;
-(void)reset;

-(void)renderCompletion:(RenderBlock)block;

@end
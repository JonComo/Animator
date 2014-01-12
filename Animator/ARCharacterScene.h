//
//  ARCharacterScene.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "ARCharacter.h"

@interface ARCharacterScene : SKScene

-(void)addPartFromImage:(UIImage *)image;
-(void)clear;
-(void)undo;

-(ARCharacter *)character;

@end
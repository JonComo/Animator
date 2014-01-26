//
//  ARScene.h
//  Animator
//
//  Created by Jon Como on 1/25/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "ARPart.h"

@interface ARScene : SKScene

@property (nonatomic, strong) NSMutableArray *parts;
-(void)addPart:(ARPart *)part;
-(void)removePart:(ARPart *)part;
-(void)hideCharacterWithPart:(ARPart *)part;

@end

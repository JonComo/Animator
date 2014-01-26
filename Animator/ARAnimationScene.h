//
//  ARAnimationScene.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARScene.h"
#import "ARAnimation.h"

@interface ARAnimationScene : ARScene

@property (nonatomic, strong) ARAnimation *animation;

@property BOOL shouldRecord;

-(void)restart;

@end
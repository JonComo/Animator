//
//  ARTouchNode.h
//  Animator
//
//  Created by Jon Como on 1/14/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ARTouchNode : SKSpriteNode

+(ARTouchNode *)touchNodeForTouch:(UITouch *)touch position:(CGPoint)position;

@property (nonatomic, strong) NSString *key;
@property CGPoint lastPosition;

@end
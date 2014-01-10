//
//  ARPart.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ARPart : SKSpriteNode

-(void)snapshotAtFrame:(int)frame;
-(void)layoutForFrame:(int)frame;

-(void)removeFramesInRange:(NSRange)range;
-(void)removeAllFrames;

@end
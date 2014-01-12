//
//  ARCharacter.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARPart.h"

@class ARAnimationScene;

@interface ARCharacter : NSObject <NSCoding>

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong) NSMutableArray *joints;

-(void)spawnInScene:(ARAnimationScene *)scene;

+(NSMutableArray *)loadAll;
-(void)saveWithThumbnail:(UIImage *)image;

@end
//
//  ARMovieComposer.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARMovieComposer : NSObject

+(void)renderImages:(NSArray *)images completion:(void(^)(void))block;

@end

//
//  ARMovieComposer.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MovieComposerImages @"image"
#define MovieComposerAudio @"audio"

typedef void (^RenderMovieBlock)(NSURL *URL);

@interface ARMovieComposer : NSObject

+(void)renderData:(NSDictionary *)data completion:(RenderMovieBlock)block;

@end

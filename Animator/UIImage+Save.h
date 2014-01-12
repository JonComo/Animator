//
//  UIImage+Save.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Save)

+(NSMutableArray *)loadAll;
+(void)saveImage:(UIImage *)image;

@end

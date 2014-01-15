//
//  EADrawView.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EALineDisplayView.h"

@interface EADrawView : UIView

@property float zoomScale;
@property (nonatomic, strong) EALineDisplayView *viewPaths;

-(void)setImage:(UIImage *)image;

-(UIImage *)transparentImageInRect:(CGRect)rect;
-(NSArray *)getImages;

-(void)undo;
-(void)clearDrawing;

@end
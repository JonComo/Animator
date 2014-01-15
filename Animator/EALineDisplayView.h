//
//  EALineDisplayView.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARBezierPath;

@interface EALineDisplayView : UIView

@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) ARBezierPath *pathToRender;

-(void)rasterize;

@end
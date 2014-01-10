//
//  EAScrollView.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EADrawView;

@interface EAScrollView : UIScrollView

@property (nonatomic, weak) EADrawView *drawView;

@end

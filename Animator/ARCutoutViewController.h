//
//  ARCutoutViewController.h
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARCutoutViewController;

@protocol ARCutoutViewControllerDelegate <NSObject>

-(void)cutoutViewController:(ARCutoutViewController *)cutoutVC didPickImages:(NSArray *)images;

@end

@interface ARCutoutViewController : UIViewController

@property (nonatomic, weak) id <ARCutoutViewControllerDelegate> delegate;

@end

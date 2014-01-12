//
//  ARCharactersViewController.h
//  Animator
//
//  Created by Jon Como on 1/12/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARCharacter.h"

@protocol ARCharactersViewControllerDelegate <NSObject>

-(void)characterPicked:(ARCharacter *)character;

@end

@interface ARCharactersViewController : UIViewController

@property (nonatomic, weak) id<ARCharactersViewControllerDelegate> delegate;

@end

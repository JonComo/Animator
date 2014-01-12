//
//  ARCharacterCreatorViewController.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARCharacter.h"

@class ARCharacterCreatorViewController;

@protocol ARCharacterCreatorViewControllerDelegate <NSObject>

-(void)characterCreator:(ARCharacterCreatorViewController *)characterVC createdCharacter:(ARCharacter *)character;

@end

@interface ARCharacterCreatorViewController : UIViewController

@property (nonatomic, weak) id <ARCharacterCreatorViewControllerDelegate> delegate;

@end

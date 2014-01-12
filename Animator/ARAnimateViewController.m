//
//  ARAnimateViewController.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimateViewController.h"

#import "ARCharactersViewController.h"

#import "ARMovieComposer.h"

@interface ARAnimateViewController () <ARCharactersViewControllerDelegate>
{
    ARAnimationScene *scene;
    
    __weak IBOutlet SKView *sceneView;
    __weak IBOutlet UIButton *buttonPlay;
}

@end

@implementation ARAnimateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Load scene
    scene = [[ARAnimationScene alloc] initWithSize:CGSizeMake(320, 320)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [sceneView presentScene:scene];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    scene.paused = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    scene.paused = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    [scene.animation play];
}

- (IBAction)done:(id)sender
{
    [scene.animation renderCompletion:^(NSMutableArray *images) {
        /* [ARMovieComposer renderImages:images completion:^{
            NSLog(@"REndered");
        }]; */
    }];
}

- (IBAction)restart:(id)sender
{
    [scene restart];
}

- (IBAction)undo:(id)sender
{
    [scene.animation undo];
}

- (IBAction)addCharacter:(id)sender
{
    ARCharactersViewController *charactersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"charactersVC"];
    
    charactersVC.delegate = self;
    
    [self presentViewController:charactersVC animated:YES completion:nil];
}

-(void)characterPicked:(ARCharacter *)character
{
    //Add it
    [character spawnInScene:scene];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
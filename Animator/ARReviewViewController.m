//
//  ARReviewViewController.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARReviewViewController.h"

@import MediaPlayer;
@import Social;

@interface ARReviewViewController ()
{
    MPMoviePlayerController *player;
}

@end

@implementation ARReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:self.URL];
    player.view.frame = CGRectMake(0, 0, 320, 320);
    [self.view addSubview:player.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)share:(id)sender
{
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[self.URL] applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

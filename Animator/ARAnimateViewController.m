//
//  ARAnimateViewController.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAnimateViewController.h"
#import "ARCutoutViewController.h"
#import "ARAnimationScene.h"
#import "ARMovieComposer.h"

@interface ARAnimateViewController () <ARCutoutViewControllerDelegate>
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
    scene = [[ARAnimationScene alloc] initWithSize:CGSizeMake(320, 400)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [sceneView presentScene:scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cutoutViewController:(ARCutoutViewController *)cutoutVC didPickImage:(UIImage *)image
{
    SKTexture *texture = [SKTexture textureWithCGImage:image.CGImage];
    
    ARPart *part = [[ARPart alloc] initWithTexture:texture];
    
    [scene addPart:part];
}

- (IBAction)play:(id)sender {
    [scene play];
}

- (IBAction)done:(id)sender {
    [scene renderCompletion:^(NSMutableArray *images) {
        [ARMovieComposer renderImages:images completion:^{
            NSLog(@"REndered");
        }];
    }];
}

- (IBAction)restart:(id)sender {
    [scene reset];
}

- (IBAction)addCharacter:(id)sender
{
    ARCutoutViewController *cutoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cutoutVC"];
    
    cutoutVC.delegate = self;
    
    [self presentViewController:cutoutVC animated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
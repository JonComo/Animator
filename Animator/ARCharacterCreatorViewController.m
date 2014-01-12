//
//  ARCharacterCreatorViewController.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacterCreatorViewController.h"

#import "ARCutoutViewController.h"
#import "ARCharacterScene.h"

#import "UIImage+Save.h"

@interface ARCharacterCreatorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ARCutoutViewControllerDelegate>
{
    ARCharacterScene *sceneCharacter;
    
    NSMutableArray *partImages;
    
    __weak IBOutlet SKView *viewScene;
    __weak IBOutlet UICollectionView *collectionViewParts;
}

@end

@implementation ARCharacterCreatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    sceneCharacter = [[ARCharacterScene alloc] initWithSize:CGSizeMake(320, 320)];
    sceneCharacter.scaleMode = SKSceneScaleModeAspectFit;
    
    [viewScene presentScene:sceneCharacter];
    
    //Load saved images
    partImages = [UIImage loadAll];
    [collectionViewParts reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPart:(id)sender
{
    ARCutoutViewController *cutoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cutoutVC"];
    
    cutoutVC.delegate = self;
    
    [self presentViewController:cutoutVC animated:YES completion:nil];
}

-(void)cutoutViewController:(ARCutoutViewController *)cutoutVC didPickImage:(UIImage *)image
{
    //Add to parts collectionview
    [UIImage saveImage:image];
    
    [partImages addObject:image];
    
    [collectionViewParts reloadData];
    [collectionViewParts scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:MAX(partImages.count-1, 0) inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clear:(id)sender {
    [sceneCharacter clear];
}

- (IBAction)undo:(id)sender {
    [sceneCharacter undo];
}

- (IBAction)done:(id)sender
{    
    ARCharacter *character = [sceneCharacter character];
    
    [self.delegate characterCreator:self createdCharacter:character];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//collection view

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImage *image = partImages[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = image;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return partImages.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = partImages[indexPath.row];
    
    [sceneCharacter addPartFromImage:image];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

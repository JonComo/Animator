//
//  ARCharactersViewController.m
//  Animator
//
//  Created by Jon Como on 1/12/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharactersViewController.h"

#import "ARCharacterCreatorViewController.h"

#import "ARCharacter.h"

@interface ARCharactersViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ARCharacterCreatorViewControllerDelegate>
{
    NSMutableArray *characters;
    
    
    __weak IBOutlet UICollectionView *collectionViewCharacters;
}

@end

@implementation ARCharactersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    characters = [ARCharacter loadAll];
    [collectionViewCharacters reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createnew:(id)sender
{
    //present new
    ARCharacterCreatorViewController *creatorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"characterCreatorVC"];
    
    creatorVC.delegate = self;
    
    [self presentViewController:creatorVC animated:YES completion:nil];
}

-(void)characterCreator:(ARCharacterCreatorViewController *)characterVC createdCharacter:(ARCharacter *)character
{
    //Save the character and reload data
    [characters addObject:character];
    [collectionViewCharacters reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    ARCharacter *character = characters[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = character.thumbnail;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return characters.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ARCharacter *character = characters[indexPath.row];
    
    [self.delegate characterPicked:character];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

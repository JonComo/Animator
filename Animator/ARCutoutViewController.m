//
//  ARCutoutViewController.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCutoutViewController.h"

#import "EADrawView.h"
#import "EAScrollView.h"

@interface ARCutoutViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
{
    BOOL didAutoShowImagePicker;
    
    __weak IBOutlet EAScrollView *scrollView;
    __weak IBOutlet EADrawView *drawView;
}

@end

@implementation ARCutoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    scrollView.contentSize = CGSizeMake(320, 320);
    scrollView.drawView = drawView;
    
    drawView.zoomScale = 1;
    
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {
        if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)gestureRecognizer;
            panGR.minimumNumberOfTouches = 2;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!didAutoShowImagePicker)
    {
        [self choosePicture:nil];
        didAutoShowImagePicker = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)choosePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *largeEdited = info[UIImagePickerControllerEditedImage];
    
    [drawView clearDrawing];
    [drawView setImage:largeEdited];
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    __weak ARCutoutViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)clear:(id)sender {
    [drawView clearDrawing];
}

- (IBAction)undo:(id)sender
{
    [drawView undo];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    NSArray *transparentImages = [drawView getImages];
    
    //feed back as new character piece
    if ([self.delegate respondsToSelector:@selector(cutoutViewController:didPickImages:)])
        [self.delegate cutoutViewController:self didPickImages:transparentImages];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return drawView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    drawView.zoomScale = scrollView.zoomScale;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

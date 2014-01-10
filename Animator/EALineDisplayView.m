//
//  EALineDisplayView.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EALineDisplayView.h"

@implementation EALineDisplayView
{
    UIImage *image;
}

-(void)rasterize
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ref, 1, -1);
    CGContextTranslateCTM(ref, 0, -self.bounds.size.height);
    
    float alpha = self.alpha;
    self.alpha = 1;
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    self.alpha = alpha;
    
    //[self.paths removeAllObjects];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    //if (image)
    //    CGContextDrawImage(context, rect, image.CGImage);
    
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    for (UIBezierPath *path in self.paths){
        [path stroke];
        [path fill];
    }
}

@end

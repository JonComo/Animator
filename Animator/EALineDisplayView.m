//
//  EALineDisplayView.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EALineDisplayView.h"
#import "ARBezierPath.h"

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
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    //[self.paths removeAllObjects];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    //if (image)
    //    CGContextDrawImage(context, rect, image.CGImage);
    
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    if (self.pathToRender)
    {
        NSLog(@"Rendered one path");
        [self.pathToRender stroke];
        [self.pathToRender fill];
    }else{
        NSLog(@"Rendered multipaths");
        for (ARBezierPath *path in self.paths){
            [path stroke];
            [path fill];
        }
    }
}

@end

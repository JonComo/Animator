//
//  EADrawView.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EADrawView.h"
#import "ARBezierPath.h"
#import "EALineDisplayView.h"

@implementation EADrawView
{
    ARBezierPath *currentPath;
    
    UIImage *imageSource;
    
    UIImageView *imageView;
    
    int lineResolution;
}

-(void)setImage:(UIImage *)image
{
    imageSource = image;
    
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        self.viewPaths = [[EALineDisplayView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.viewPaths.backgroundColor = [UIColor clearColor];
        [self addSubview:self.viewPaths];
        
        self.viewPaths.alpha = 0.5;
        lineResolution = 0;
    }
    
    imageView.image = imageSource;
}

-(UIImage *)transparentImageInRect:(CGRect)rect
{
    //Make mask
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float alpha = self.viewPaths.alpha;
    self.viewPaths.alpha = 1;
    [self.viewPaths setNeedsDisplay];
    [self.viewPaths drawViewHierarchyInRect:CGRectMake(-rect.origin.x, -rect.origin.y, 320, 320) afterScreenUpdates:YES];
    self.viewPaths.alpha = alpha;
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    
    context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGContextClipToMask(context, CGRectMake(0, 0, rect.size.width, rect.size.height), mask.CGImage);
    
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextTranslateCTM(context, 0, -320);
    
    CGContextDrawImage(context, CGRectMake(-rect.origin.x, rect.origin.y, 320, 320), imageSource.CGImage);
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return outputImage;
}

-(NSArray *)getImages
{
    NSMutableArray *images = [NSMutableArray array];
    
    float p = 4.0f; //padding
    
    for (ARBezierPath *path in self.viewPaths.paths)
    {
        //get image for each rect
        CGRect rect = CGRectMake(path.minX - p, path.minY - p, path.maxX-path.minX + p*2, path.maxY-path.minY + p*2);
        
        self.viewPaths.pathToRender = path;
        UIImage *image = [self transparentImageInRect:rect];
        if (image)
            [images addObject:image];
    }
    
    self.viewPaths.pathToRender = nil;
    
    return images;
}

-(void)undo
{
    [self.viewPaths.paths removeLastObject];
    [self.viewPaths setNeedsDisplay];
}

-(void)clearDrawing
{
    [self.viewPaths.paths removeAllObjects];
    
    [self.viewPaths setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (!self.viewPaths.paths)
        self.viewPaths.paths = [NSMutableArray array];
    
    currentPath = [[ARBezierPath alloc] init];
    
    currentPath.minX = 320.0f;
    currentPath.minY = 320.0f;
    currentPath.maxX = 0.0f;
    currentPath.maxY = 0.0f;
    
    currentPath.lineWidth = 6 / self.zoomScale;
    currentPath.lineCapStyle = kCGLineCapRound;
    
    [currentPath moveToPoint:location];
    
    [self.viewPaths.paths addObject:currentPath];
    
    [self.viewPaths setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    lineResolution ++;
    
    if (lineResolution > 4)
    {
        lineResolution = 0;
        
        [currentPath addLineToPoint:location];
        
        if (location.x > currentPath.maxX) currentPath.maxX = location.x;
        if (location.x < currentPath.minX) currentPath.minX = location.x;
        if (location.y > currentPath.maxY) currentPath.maxY = location.y;
        if (location.y < currentPath.minY) currentPath.minY = location.y;
        
        [self.viewPaths setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.viewPaths setNeedsDisplay];
    //[self.viewPaths rasterize];
    
    currentPath = nil;
}

@end

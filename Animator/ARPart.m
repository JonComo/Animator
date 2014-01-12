//
//  ARPart.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARPart.h"

@interface ARPart () <NSCoding>

@end

@implementation ARPart

+(ARPart *)partWithImage:(UIImage *)img
{
    ARPart *part = [[ARPart alloc] initWithTexture:[SKTexture textureWithCGImage:img.CGImage]];
    part.image = img;
    
    return part;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //init
        NSLog(@"Init with decoder");
        
        UIImage *img = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"image"]];
        self.texture = [SKTexture textureWithCGImage:img.CGImage];
        self.image = img;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"Encoding with coder");
    [super encodeWithCoder:aCoder];
    
    NSData *imageData = UIImagePNGRepresentation(self.image);
    if (imageData)
        [aCoder encodeObject:imageData forKey:@"image"];
}

@end

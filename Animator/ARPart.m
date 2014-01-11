//
//  ARPart.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARPart.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]

@interface ARPart () <NSCoding>

@end

@implementation ARPart
{
    NSMutableArray *frameInfo;
}

+(ARPart *)partWithImage:(UIImage *)img
{
    ARPart *part = [[ARPart alloc] initWithTexture:[SKTexture textureWithCGImage:img.CGImage]];
    part.image = img;
    part.isNew = YES;
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

+(NSArray *)loadParts
{
    NSMutableArray *loadedParts = [NSMutableArray array];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS error:nil];
    
    for (NSString *filename in filenames)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", DOCUMENTS, filename]];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        
        ARPart *part = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
        
        if (part)
            [loadedParts addObject:part];
    }
    
    return loadedParts;
}

-(void)save
{
    if (!self.isNew) return; //Only archive newly created parts/characters
    
    NSURL *unique = [ARPart unique];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToURL:unique atomically:YES];
}

+(NSURL *)unique
{
    NSString *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    int count = 0;
    
    NSURL *URL;
    
    do {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@part%i", documents, count]];
        
        count ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    return URL;
}

-(void)snapshotAtFrame:(int)frame
{
    if (!frameInfo){
        frameInfo = [NSMutableArray array];
    }
    
    NSValue *position = [NSValue valueWithCGPoint:self.position];
    NSNumber *rotation = @(self.zRotation);
    
    NSDictionary *info = @{@"f": @(frame), @"p": position, @"r": rotation};
    
    [frameInfo addObject:info];
}

-(void)layoutForFrame:(int)frame
{
    NSDictionary *info;
    
    for (NSDictionary *testInfo in frameInfo){
        if ([testInfo[@"f"] intValue] == frame){
            info = testInfo;
            break;
        }
    }
    
    if (!info){
        
        self.position = CGPointMake(0, -2000.0f); //hide piece
        
        return;
    }
    
    self.position = [info[@"p"] CGPointValue];
    self.zRotation = [info[@"r"] floatValue];
}

-(void)removeFramesInRange:(NSRange)range
{
    for (int i = frameInfo.count-1; i>0; i--) {
        NSDictionary *info = frameInfo[i];
        
        int infoFrame = [info[@"f"] intValue];
        
        if (infoFrame > range.location && infoFrame < range.location + range.length){
            //remove it
            [frameInfo removeObject:info];
        }
    }
}

-(void)removeAllFrames
{
    [frameInfo removeAllObjects];
}

@end

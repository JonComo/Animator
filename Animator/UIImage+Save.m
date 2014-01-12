//
//  UIImage+Save.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "UIImage+Save.h"
#import "NSURL+Unique.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
#define IMG_DIR [DOCUMENTS URLByAppendingPathComponent:@"images"]

@implementation UIImage (Save)

+(void)saveImage:(UIImage *)image
{
    NSURL *URL = [NSURL uniqueWithName:@"image" inDirectory:IMG_DIR];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [data writeToURL:URL atomically:YES];
}

+(NSMutableArray *)loadAll
{
    NSMutableArray *loadedImages = [NSMutableArray array];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[IMG_DIR path] error:nil];
    
    for (NSString *filename in filenames)
    {
        NSURL *url = [IMG_DIR URLByAppendingPathComponent:filename];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:fileData];
        
        if (image)
            [loadedImages addObject:image];
    }
    
    return loadedImages;
}

@end

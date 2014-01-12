//
//  NSURL+Unique.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "NSURL+Unique.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]

@implementation NSURL (Unique)

+(NSURL *)uniqueWithName:(NSString *)name inDirectory:(NSURL *)directory
{
    int count = 0;
    NSURL *URL;
    
    do {
        URL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%i", name, count]];
        count ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    return URL;
}

@end

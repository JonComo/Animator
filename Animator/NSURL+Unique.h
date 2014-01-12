//
//  NSURL+Unique.h
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Unique)

+(NSURL *)uniqueWithName:(NSString *)name inDirectory:(NSURL *)directory;

@end

//
//  ARPart.m
//  Animator
//
//  Created by Jon Como on 1/10/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARPart.h"

@implementation ARPart
{
    NSMutableArray *frameInfo;
}

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture])
    {
        //init
        
    }
    
    return self;
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

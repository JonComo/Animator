//
//  ARCharacter.m
//  Animator
//
//  Created by Jon Como on 1/11/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARCharacter.h"
#import "ARPinJoint.h"

#import "NSURL+Unique.h"

#import "ARAnimationScene.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
#define CHAR_DIR [DOCUMENTS URLByAppendingPathComponent:@"character"]

@implementation ARCharacter

-(id)init
{
    if (self = [super init]) {
        //init
        _parts = [NSMutableArray array];
        _joints = [NSMutableArray array];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _parts = [aDecoder decodeObjectForKey:@"parts"];
        _joints = [aDecoder decodeObjectForKey:@"joints"];
        _thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parts forKey:@"parts"];
    [aCoder encodeObject:self.joints forKey:@"joints"];
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];
}

+(NSMutableArray *)loadAll
{
    NSMutableArray *loaded = [NSMutableArray array];
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CHAR_DIR path] error:nil];
    
    for (NSString *filename in filenames)
    {
        NSURL *url = [CHAR_DIR URLByAppendingPathComponent:filename];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        
        ARCharacter *character = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
        
        if (character)
            [loaded addObject:character];
    }
    
    return loaded;
}

-(void)saveWithThumbnail:(UIImage *)image
{
    NSURL *URL = [NSURL uniqueWithName:@"character" inDirectory:CHAR_DIR];
    
    self.thumbnail = image;
    
    NSData *characterData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [characterData writeToURL:URL atomically:YES];
}

-(void)spawnInScene:(ARAnimationScene *)scene
{
    for (ARPart *part in self.parts){
        [scene addPart:part];
    }
    
    for (ARPinJoint *joint in self.joints)
    {
        //Calculate new anchor point
        CGPoint anchor = [joint newAnchor];
        
        SKPhysicsJointPin *pin = [SKPhysicsJointPin jointWithBodyA:joint.partA.physicsBody bodyB:joint.partB.physicsBody anchor:anchor];
        [scene.physicsWorld addJoint:pin];
    }
}

@end

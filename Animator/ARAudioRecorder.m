//
//  ARAudioRecorder.m
//  Animator
//
//  Created by Jon Como on 1/12/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "ARAudioRecorder.h"

#import "NSURL+Unique.h"
#import "ARTimedURL.h"

#define DOCUMENTS [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0]
#define AUDIO_DIR [DOCUMENTS URLByAppendingPathComponent:@"audio"]

@import AVFoundation;

@interface ARAudioRecorder () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
}

@end

@implementation ARAudioRecorder

+(ARAudioRecorder *)audioRecorder
{
    ARAudioRecorder *audioRecorder = [[self alloc] init];
    
    return audioRecorder;
}

+(void)enableAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    [audioSession setActive:YES error:nil];
}

-(id)init
{
    if (self = [super init]) {
        //init
        _URLs = [NSMutableArray array];
    }
    
    return self;
}

-(void)recordAtFrame:(int)frame
{
    ARTimedURL *timedURL = [ARTimedURL new];
    
    timedURL.URL = [NSURL uniqueWithName:@"audio.caf" inDirectory:AUDIO_DIR];
    timedURL.frame = frame;
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    [recordSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSError *error = nil;
    
    recorder = [[AVAudioRecorder alloc]
                initWithURL:timedURL.URL
                settings:recordSettings
                error:&error];
    
    recorder.delegate = self;
    
    if (error)
        NSLog(@"AUDIO ERROR: %@", error);
    
    [self.URLs addObject:timedURL];
    
    [recorder record];
}

-(void)stop
{
    [recorder stop];
}

-(void)clear
{
    [self.URLs removeAllObjects];
    [self.player stop];
    [recorder stop];
}

-(void)undo
{
    if (self.URLs.count > 0)
        [self.URLs removeLastObject];
}

-(void)playAudioAtFrame:(int)frame
{
    ARTimedURL *audioURL;
    
    for (ARTimedURL *testURL in self.URLs){
        if (testURL.frame == frame) audioURL = testURL;
    }
    
    if (!audioURL) return;
    
    NSError *playerError;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL.URL error:&playerError];
    
    if (playerError)
    {
        NSLog(@"Error: %@", playerError);
    }
    
    self.player.delegate = self;
    
    [self.player play];
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (!flag)
        NSLog(@"WOOPS");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    player.delegate = nil;
    player = nil;
}

@end

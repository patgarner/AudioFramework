//
//  FileConverter.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/8/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

/*import Foundation

-(void) convertToWav
{
// set up an AVAssetReader to read from the iPod Library

NSString *cafFilePath=[[NSBundle mainBundle]pathForResource:@"test" ofType:@"caf"];

NSURL *assetURL = [NSURL fileURLWithPath:cafFilePath];
AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];

NSError *assetError = nil;
AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                           error:&assetError]
;
if (assetError) {
    NSLog (@"error: %@", assetError);
    return;
}

AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                          assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                          audioSettings: nil];
if (! [assetReader canAddOutput: assetReaderOutput]) {
    NSLog (@"can't add reader output... die!");
    return;
}
[assetReader addOutput: assetReaderOutput];

NSString *title = @"MyRec";
NSArray *docDirs = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
NSString *docDir = [docDirs objectAtIndex: 0];
NSString *wavFilePath = [[docDir stringByAppendingPathComponent :title]
                         stringByAppendingPathExtension:@"wav"];
if ([[NSFileManager defaultManager] fileExistsAtPath:wavFilePath])
{
    [[NSFileManager defaultManager] removeItemAtPath:wavFilePath error:nil];
}
NSURL *exportURL = [NSURL fileURLWithPath:wavFilePath];
AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                      fileType:AVFileTypeWAVE
                                                         error:&assetError];
if (assetError)
{
    NSLog (@"error: %@", assetError);
    return;
}

AudioChannelLayout channelLayout;
memset(&channelLayout, 0, sizeof(AudioChannelLayout));
channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                nil];
AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                          outputSettings:outputSettings];
if ([assetWriter canAddInput:assetWriterInput])
{
    [assetWriter addInput:assetWriterInput];
}
else
{
    NSLog (@"can't add asset writer input... die!");
    return;
}

assetWriterInput.expectsMediaDataInRealTime = NO;

[assetWriter startWriting];
[assetReader startReading];

AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
[assetWriter startSessionAtSourceTime: startTime];

__block UInt64 convertedByteCount = 0;
dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);

[assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                        usingBlock: ^
 {

     while (assetWriterInput.readyForMoreMediaData)
     {
         CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
         if (nextBuffer)
         {
             // append buffer
             [assetWriterInput appendSampleBuffer: nextBuffer];
             convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
             CMTime progressTime = CMSampleBufferGetPresentationTimeStamp(nextBuffer);

             CMTime sampleDuration = CMSampleBufferGetDuration(nextBuffer);
             if (CMTIME_IS_NUMERIC(sampleDuration))
                 progressTime= CMTimeAdd(progressTime, sampleDuration);
             float dProgress= CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(songAsset.duration);
             NSLog(@"%f",dProgress);
         }
         else
         {

             [assetWriterInput markAsFinished];
             //              [assetWriter finishWriting];
             [assetReader cancelReading];

         }
     }
 }];
}
share  edit  follow  flag */

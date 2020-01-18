//
//  RNMusicMetadata.m
//  RNMusicMetadata
//
//  Created by venepe on 5/06/17.
//  Copyright © 2017 venepe. All rights reserved.
//

#import "RNMusicMetadata.h"
#import <AVFoundation/AVFoundation.h>

@implementation RNMusicMetadata

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(getMetadata:(NSArray *)uris resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSMutableArray *songArray = [NSMutableArray array];
    for (int i = 0; i < uris.count; i++) {
        NSDictionary *songDictionary = [self getData:uris[i]];
        [songArray addObject:songDictionary];
    }

    NSArray *result = [songArray copy];

    resolve(result);
}

-(NSDictionary *) getData:(NSString *)uri
{
    AVAsset *asset;
    NSDictionary *songDictionary = [NSMutableDictionary dictionary];
    NSURL *fileURL = [NSURL fileURLWithPath:uri];

    asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    for (NSString *format in [asset availableMetadataFormats]) {
        for (AVMetadataItem *item in [asset metadataForFormat:format]) {
            if ([[item commonKey] isEqualToString:@"title"]) {
                [songDictionary setValue:[NSString stringWithString:(NSString *)[item value]] forKey:@"title"];
            }
            if ([[item commonKey] isEqualToString:@"artist"]) {
                [songDictionary setValue:[NSString stringWithString:(NSString *)[item value]] forKey:@"artist"];
            }
            if ([[item commonKey] isEqualToString:@"albumName"]) {
                [songDictionary setValue:[NSString stringWithString:(NSString *)[item value]] forKey:@"albumName"];
            }
            if ([[item commonKey] isEqualToString:@"albumArtist"]) {
                [songDictionary setValue:[NSString stringWithString:(NSString *)[item value]] forKey:@"albumArtist"];
            }
            if ([[item commonKey] isEqualToString:@"artwork"]) {
              UIImage *img = nil;
              if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                img = [UIImage imageWithData:[item.value copyWithZone:nil]];
              }
              else { // if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                NSData *data = [(NSDictionary *)[item value] objectForKey:@"data"];
                img = [UIImage imageWithData:data]  ;
              }
              [songDictionary setValue:[NSString stringWithString:(NSString *)[img]] forKey:@"artwork"];
            }
        }
    }

    NSURL *assetURL = [NSURL fileURLWithPath:uri];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:nil];
    NSNumber *duration = [NSNumber numberWithDouble:[audioPlayer duration]];
    [songDictionary setValue:duration forKey:@"duration"];

    [songDictionary setValue:uri forKey:@"uri"];

    return songDictionary;
}

@end

//
//  DebugDataManager.m
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "DebugDataManager.h"
#import "MusicStoreManager.h"
#import "PlaylistEntity+CoreDataClass.h"
@implementation DebugDataManager

+ (instancetype)shared {
    static DebugDataManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    self = [super init];
    if (self){
    }
    return self;
}

/*
 
 */

- (void)createPlaylist:(NSString *)name mode:(DataMode)mode {
    PlaylistEntity *entity = [[MusicStoreManager sharedManager] managedObjectClass:[PlaylistEntity class]];
    entity.name = name;
    //    entity.flag = [NSNumber numberWithInt:_dataMode];
    entity.flag = @(mode);
    entity.detail = @"";
    
    [[MusicStoreManager sharedManager] commit];
}

@end

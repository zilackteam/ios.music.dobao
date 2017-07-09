//
//  DebugDataManager.h
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicStoreManager.h"

@interface DebugDataManager : NSObject

+ (instancetype)shared;

- (void)createPlaylist:(NSString *)name mode:(DataMode) mode;
@end

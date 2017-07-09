//
//  MediaActionManagement.h
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "BaseList.h"

// media_actions.plist
typedef NS_ENUM(NSUInteger, MediaActionType) {
    MediaActionDownload             = 0,
    MediaActionAddFavourite         = 1,
    MediaActionAddPlaylist          = 2,
    MediaActionDelete               = 3,
    MediaActionSharing              = 4,
    MediaActionRemoveFromPlaylist   = 5
};

#pragma mark - Action Object
@interface MediaActionObject : NSObject<BaseObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *actionid;
@property (strong, nonatomic) NSString *iconHighlight;
@property (assign, nonatomic) MediaActionType type;

@end

#pragma mark - Media Action List
@interface MediaActionList : BaseList<BaseObject>
@end;


@interface MediaActionManager : NSObject

@end

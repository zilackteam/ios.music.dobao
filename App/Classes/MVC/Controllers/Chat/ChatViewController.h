//
//  ChatViewController.h
//  music.application
//
//  Created by thanhvu on 6/5/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "BaseViewController.h"
#import "MQTTClient.h"

typedef NS_OPTIONS(NSInteger, ChatViewState) {
    ChatViewState_None,
    ChatViewState_Connecting,
    ChatViewState_Connected,
    ChatViewState_Closed,
    ChatViewState_Avaiable,
    ChatViewState_UnAvaiable
};

@interface ChatViewController : BaseViewController

// reload data
- (void)reloadData;

// setup chat
- (void)setupChatMQTTAddress:(NSString *)address;

// send message
- (void)sendMessage:(NSData *)data;

- (void)closeChat;

@end

//
//  ChatViewController.m
//  music.application
//
//  Created by thanhvu on 6/5/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCollectionViewCell.h"
#import "UIImage+Utilities.h"
#import "ZLUtilities.h"
#import "Message.h"

#define APPLICATION_BUNDLE_IDENTIFIER_CHAT_TOPIC_ID     [[NSBundle mainBundle] bundleIdentifier]

@interface ChatViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, MQTTSessionDelegate>
{
    MQTTSession *session;
    ChatViewState state;
    NSString *topic;
}

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)p_subscribe;

- (NSString *)p_reuseIdentiferWithMessageType:(MessageType)type;

@end

@implementation ChatViewController

- (void)setupChatMQTTAddress:(NSString *)address {
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = address;
    transport.port = 1883;
    
    session = [[MQTTSession alloc] init];
    session.transport = transport;
    session.delegate = self;
    
    state = ChatViewState_Connecting;
    
    // init topic
    topic = [NSString stringWithFormat:@"topic/%@", APPLICATION_BUNDLE_IDENTIFIER_CHAT_TOPIC_ID];
    [session connectAndWaitTimeout:15];  //this is part of the synchronous API
}

- (void)p_subscribe {
    [session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            state = ChatViewState_UnAvaiable;
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            state = ChatViewState_Avaiable;
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
    }]; // this is part of the block API
}

- (NSString *)p_reuseIdentiferWithMessageType:(MessageType)type {
    switch (type) {
        case MessageTypeText:
            return @"messagetext_cell";
            break;
        case MessageTypeGift:
            return @"messagegift_cell";
            break;
        default:
            break;
    }
    return @"messagetext_cell";
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (!error && dict) {
        Message *message = [Message parseObject:dict];
        
        if (message && [message valid]) {
            [_messages addObject:message];
            [_collectionView performBatchUpdates:^{
                [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:([_messages count] - 1) inSection:0]]];
            } completion:^(BOOL finished) {
                
                NSInteger section = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
                
                NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:section] - 1;
                
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                
                [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            }];
        }
    }
}

- (void)sendMessage:(NSData *)data {
    [session publishAndWaitData:data
                        onTopic:topic
                         retain:NO
                            qos:MQTTQosLevelAtLeastOnce];
}

- (void)closeChat {
    if (session) {
        [session unsubscribeTopic:topic];
        [session close];
    }
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messages = [NSMutableArray array];
    
    state = ChatViewState_None;
    
    // Do any additional setup after loading the view.
    {
        UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
        currentLayout.minimumLineSpacing = 15;
        currentLayout.minimumInteritemSpacing = 0;
        self.collectionView.contentInset = UIEdgeInsetsMake(10.0f, 0, 0.0f, 0);
        self.collectionView.allowsSelection = YES;
        [currentLayout invalidateLayout];
    }
    
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (session) {
        [session disconnect];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    [_collectionView reloadData];
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_messages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_messages objectAtIndex:indexPath.item];
    
    ChatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self p_reuseIdentiferWithMessageType:message.type]
                                                                             forIndexPath:indexPath];
    [cell setMessage:message];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame);
    
    Message *message = [_messages objectAtIndex:indexPath.item];
    
    CGSize size;
    if (message.type == MessageTypeText) {
        NSString *txt = message.content;
        
        CGRect r = [ZLUtilities boundingRectForString:txt font:[UIFont fontWithName:APPLICATION_FONT size:14] width:(width - 40)];
        
        size = CGSizeMake(width, ceil((MAX(20, r.size.height) + 12 + 20)));
    } else {
        size = CGSizeMake(width, 70.0f);
    }
    
    return size;
}

#pragma mark - MQTTSessionDelegate

- (void)connected:(MQTTSession *)session {
    DLog(@"MQTT::CONNECTED");
    
    state = ChatViewState_Connected;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_subscribe];
    });
}

- (void)connectionClosed:(MQTTSession *)session {
    state = ChatViewState_Closed;
    DLog(@"MQTT::CLOSED");
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error {
    DLog(@"MQTT::ERROR");
    state = ChatViewState_UnAvaiable;
}
@end

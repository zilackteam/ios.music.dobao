#import "BaseViewController.h"
#import "ChatViewController.h"
#import "LiveStreamDefined.h"

@class MQTTSession;
@interface LiveStreamingViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *chatContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlHeightConstraint;

- (void)sendTextMessage:(NSString *)message;

- (void)sendGiftMessage:(NSString *)message;

- (void)setupChatMQTTAddress:(NSString *)address;

@end

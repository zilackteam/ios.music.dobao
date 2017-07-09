#import "LiveStreamingViewController.h"
#import "Message.h"

@interface LiveStreamingViewController () {
}

@property (strong, nonatomic) ChatViewController *chatViewController;

@end

@implementation LiveStreamingViewController

- (void)dealloc {
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBA(100, 100, 100, 1);
    
    {
        self.chatViewController = [UIStoryboard viewController:SB_ChatViewController storyBoard:StoryBoardLive];
        
        UIView *chatView = self.chatViewController.view;
        
        chatView.translatesAutoresizingMaskIntoConstraints = NO;
        chatView.backgroundColor = [UIColor clearColor];
        
        self.chatContainerView.backgroundColor = [UIColor clearColor];
        [self.chatContainerView addSubview:chatView];
        
        NSLayoutConstraint *top_constraint = [NSLayoutConstraint constraintWithItem:chatView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.chatContainerView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:0];
        
        NSLayoutConstraint *bot_constraint = [NSLayoutConstraint constraintWithItem:chatView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.chatContainerView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0];
        
        
        NSLayoutConstraint *lead_constraint = [NSLayoutConstraint constraintWithItem:chatView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.chatContainerView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:0];
        
        NSLayoutConstraint *trail_constraint = [NSLayoutConstraint constraintWithItem:chatView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.chatContainerView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                           multiplier:1.0
                                                                             constant:0];
        
        // Add constraints
        [self.chatContainerView addConstraints:@[top_constraint, bot_constraint, lead_constraint, trail_constraint]];
        //
        [chatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackground:)]];
//        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackground:)]];
        
        [self.contentView layoutIfNeeded];
        
        [chatView layoutIfNeeded];
    }
    
    [self registerForKeyboardNotifications];
    
    [self.view layoutIfNeeded];
}

- (void)tapOnBackground:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.chatViewController closeChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self adjustConstraintWithInfo:notification.userInfo isShown:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self adjustConstraintWithInfo:notification.userInfo isShown:NO];
}

- (void)adjustConstraintWithInfo:(NSDictionary *)info isShown:(BOOL)show {
    UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat height = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    NSString *identifier = show ? @"keyboard_show" : @"keyboard_height";
    
    [UIView beginAnimations:identifier context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    float constant = show ? height : self.bottomHeight;
    self.controlBottomConstraint.constant = constant;
    self.contentBottomConstraint.constant = constant;
    
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)sendTextMessage:(NSString *)message {
    if (message) {
        NSMutableDictionary *msgDict = [[NSMutableDictionary alloc] init];
        [msgDict setValue:message forKey:API_PARAM_CONTENT];
        [msgDict setValue:[[Session shared].user name] forKey:API_PARAM_NAME];
        [msgDict setValue:@(MessageTypeText) forKey:API_PARAM_TYPE];
        
        NSError *error;
        NSData *jsonmsgdata = [NSJSONSerialization dataWithJSONObject:msgDict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (!error) {
            [self.chatViewController sendMessage:jsonmsgdata];
        }
    }
}

- (void)sendGiftMessage:(NSString *)message {
    if (message) {
        NSMutableDictionary *msgDict = [[NSMutableDictionary alloc] init];
        [msgDict setValue:message forKey:API_PARAM_CONTENT];
        [msgDict setValue:[[Session shared].user name] forKey:API_PARAM_NAME];
        [msgDict setValue:@(MessageTypeGift) forKey:API_PARAM_TYPE];
        
        NSError *error;
        NSData *jsonmsgdata = [NSJSONSerialization dataWithJSONObject:msgDict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (!error) {
            [self.chatViewController sendMessage:jsonmsgdata];
        }
    }
}

- (void)setupChatMQTTAddress:(NSString *)address {
    if (address) {
        [self.chatViewController setupChatMQTTAddress:address];
    }
}
@end

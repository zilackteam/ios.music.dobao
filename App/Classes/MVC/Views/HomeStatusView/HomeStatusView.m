//
//  HomeStatusView.m
//  music.application
//
//  Created by thanhvu on 4/2/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "HomeStatusView.h"
#import "Post.h"
#import "NSDate+TimeDif.h"
#import "UIImage+Utilities.h"

@interface HomeStatusView() {
}
@property (weak, nonatomic) IBOutlet UIImageView *imageBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *artistLogoView;
@property (weak, nonatomic) IBOutlet UIImageView *artistSignalView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIView *statusContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *artistLogoWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView *inforView;

- (void)p_updatePost:(Post *)post;

- (void)setHidden:(BOOL)hidden;

@end

@implementation HomeStatusView

// override
- (void)setHidden:(BOOL)hidden {
    _likeCountLabel.hidden = hidden;
    _commentCountLabel.hidden = hidden;
    _likeImageView.hidden = hidden;
    _commentImageView.hidden = hidden;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews {
    NSString *className = NSStringFromClass([self class]);
    
    [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    
    [self addSubview:self.view];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeTop]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeLeft]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeBottom]];
    [self addConstraint:[self pin:self.view attribute:NSLayoutAttributeRight]];
    
    _statusContainerView.layer.cornerRadius = 5.0f;
//    _statusContainerView.alpha = 0.0f;
    _messageLabel.alpha = 0.0f;
    self.userInteractionEnabled = YES;
    
    [self setHidden:YES];
}

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(homeStatusView:performAction:)]) {
        [_delegate homeStatusView:self performAction:2];
    }
/*
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    
    BOOL touched = CGRectContainsPoint(_statusContainerView.frame, locationPoint);
    if (touched) {
        if (_delegate && [_delegate respondsToSelector:@selector(homeStatusView:performAction:)]) {
            [_delegate homeStatusView:self performAction:2];
        }
        return;
    }
*/
}

- (void)updateAlpha:(float)alpha {
    _artistLogoView.alpha = pow(alpha, 2);
    float ap = alpha - (1 - pow(alpha, 2));
    _imageBackgroundView.alpha = pow(alpha, 2);
    _artistSignalView.alpha = ap;
    _statusContainerView.alpha = ap;
    
    [self layoutIfNeeded];
}

- (void)p_updatePost:(Post *)post {
    _userLabel.text = post.user.fullName;
    _timeLabel.text = [NSDate datefromString:post.date format:APPLICATION_DATETIME_FORMAT_STRING].stringDifferenceSinceNow;
    _likeCountLabel.text = [NSString stringWithFormat:@"%ld", post.likeCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", post.commentCount];
    
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:post.user.avatarUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:_avatarView duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            float radius = MIN(image.size.width, image.size.height)/2;
                            UIImage *aImage = [UIImage roundedImage:image cornerRadius:radius];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _avatarView.image = aImage;
                            });
                            
                            _messageLabel.alpha = 1;
                        } completion:^(BOOL finished) {
//                            _statusContainerView.alpha = _artistSignalView.alpha;
                        }];
    }];
    [self updateMessage:post.content];
}

- (void)setPost:(Post *)post {
    if (!post) {
        [self setHidden:YES];
        return;
    }
    [self setHidden:NO];
    [self performSelector:@selector(p_updatePost:) withObject:post afterDelay:0.1];
}

- (void)updateMessage:(NSString *)message {
    _messageLabel.text = message;
    
    [UIView animateWithDuration:0.5 animations:^{
        _messageLabel.alpha = 1;
        [self layoutIfNeeded];
    }];
}

- (void)showLoading {
//    _statusContainerView.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView startAnimating];
    });
}

- (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView stopAnimating];
    });
}

/*
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect innerRect = CGRectInset(_inforView.frame, 2, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:innerRect byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(5, 5)];
    CGContextAddPath(context, path.CGPath);
    
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] setStroke];
    path.lineWidth = 2;
    [path stroke];
    [path fill];
}
*/
@end

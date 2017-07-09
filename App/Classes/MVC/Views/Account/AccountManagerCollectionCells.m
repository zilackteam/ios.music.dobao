#import "AccountManagerCollectionCells.h"
#import "LocalStored.h"

@implementation LoginButton
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect innerRect = CGRectInset(CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)), 1, 1);
    
    float r = innerRect.size.height/2;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:r];
    CGContextAddPath(context, path.CGPath);
    
    [[UIColor colorWithRed:127/255.0 green:181/255.0 blue:115/255.0 alpha:1] setFill];
    
    [path fill];
}

- (void)setRadius:(CGFloat)radius {
    [self setNeedsDisplay];
}

@end

@interface LoginCollectionCell() {
    __weak IBOutlet UIButton *_forgotPasswordButton;
    __weak IBOutlet ZLRoundButton *_loginButton;
    __weak IBOutlet UIButton *_facebookLoginButton;
    __weak IBOutlet UIButton *_signUpButton;
    __weak IBOutlet UIView *loginOptionContainerView;
}

@end

@implementation LoginCollectionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    UserConfig *user = [LocalStored sharedInstance].userConfig;
    if (user && user.authType == UserAuthTypeEmail) {
        _usernameTextField.text = user.secName;
        _passwordTextField.text = user.secPass;
    }
    
    loginOptionContainerView.layer.cornerRadius = 5.0f;
    loginOptionContainerView.layer.shadowOffset = CGSizeMake(0, 2);
    loginOptionContainerView.layer.shadowOpacity = 0.5;
}

- (BOOL)p_isLoginResponsable {
    return _delegate && [_delegate respondsToSelector:@selector(loginCollectionCell:loginWithType:secretName:secretPassword:)];
}

- (IBAction)loginButtonSelected:(id)sender {
    if ([self p_isLoginResponsable]) {
        [_delegate loginCollectionCell:self loginWithType:LoginTypeEmail secretName:_usernameTextField.text secretPassword:_passwordTextField.text];
    }
}

- (IBAction)forgotPasswordButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(loginCollectionCell:forgotPasswordEmail:)]) {
        [_delegate loginCollectionCell:self forgotPasswordEmail:_usernameTextField.text];
    }
}

- (IBAction)loginFacebookButtonSelected:(id)sender {
    if ([self p_isLoginResponsable]) {
        [_delegate loginCollectionCell:self loginWithType:LoginTypeFacebook secretName:nil secretPassword:nil];
    }
}

- (IBAction)signUpButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(signUp)]) {
        [_delegate signUp];
    }
}

- (void)updateLocalization {
    [_loginButton setTitle:LocalizedString(@"tlt_signin") forState:UIControlStateNormal];
    [_forgotPasswordButton setTitle:LocalizedString(@"tlt_forgot_pass") forState:UIControlStateNormal];
    [_facebookLoginButton setTitle:LocalizedString(@"tlt_facebook_login") forState:UIControlStateNormal];
    [_signUpButton setTitle:LocalizedString(@"tlt_signup_require") forState:UIControlStateNormal];
}

@end

@interface ProfileCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet ZLTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoButton;

@end

@implementation ProfileCollectionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [_photoButton setUserInteractionEnabled:YES];
    [_photoButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAvatar)]];
}

- (void)changeAvatar {
    if (_delegate && [_delegate respondsToSelector:@selector(profileCollectionCell:changeAvatarView:)]) {
        [_delegate profileCollectionCell:self changeAvatarView:_avatarView];
    }
}
- (IBAction)passwordChangeButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(changePassword)]) {
        [_delegate changePassword];
    }
}

- (IBAction)inputCard:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(openCardScreen)]) {
        [_delegate openCardScreen];
    }
}

- (void)refresh {
    User *user = [Session shared].user;
    
    if (user) {
        _nameLabel.text = user.name;
        _passwordTextField.text = user.secPass;
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                       placeholderImage:[UIImage imageNamed:@"ic_account_photo_holder"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _avatarView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
            }
        }];
    }
}

@end

@interface MasterProfileCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoButton;
@end

@implementation MasterProfileCollectionCell

- (void)refresh {
    User *user = [[Session shared] user];
    if (user) {
        _nameLabel.text = user.name;
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if (image) {
                                      _avatarView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
                                  }
                              }];
        
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[UIImage imageNamed:@"ic_account_photo_holder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _avatarView.image = [UIImage roundedImage:image cornerRadius:image.size.height/2];
            }
        }];
    }
}

@end

@interface RegisterCollectionCell()

@property (weak, nonatomic) IBOutlet ZLTextField *nameTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *emailTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

@implementation RegisterCollectionCell
- (IBAction)loginButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(signIn)]) {
        [_delegate signIn];
    }
}

- (IBAction)registerButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(registerCollectionCell:registerName:email:password:passwordConfirm:)]) {
        [_delegate registerCollectionCell:self registerName:_nameTextField.text
                                    email:_emailTextField.text password:_passwordTextField.text
                          passwordConfirm:_passwordConfirmTextField.text];
    }
}

- (UIImage *)avatar {
    return _avatarView.image;
}

@end

@implementation PasswordChangeCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateLocalization];
}

- (void)updateLocalization {
    [_updateButton setTitle:LocalizedString(@"tlt_update") forState:UIControlStateNormal];
    _passwordTextField.placeholder = LocalizedString(@"tlt_current_password");
    _createPasswordTextField.placeholder = LocalizedString(@"tlt_new_password");
    _confirmPasswordTextField.placeholder = LocalizedString(@"tlt_new_password_confirm");
}

- (void)updateStatus:(ZLTextFieldStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_passwordTextField setStatus:status];
        [_createPasswordTextField setStatus:status];
        [_confirmPasswordTextField setStatus:status];
    });
}

- (void)clear {
    _passwordTextField.text = @"";
    _createPasswordTextField.text = @"";
    _confirmPasswordTextField.text = @"";
}

- (IBAction)updateButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(passwordChangeCell:updatePassword:newPassword:confirmPassword:)]) {
        NSString *password = _passwordTextField.text;
        if (password) {
            password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        NSString *newPassword = _createPasswordTextField.text;
        if (newPassword) {
            newPassword = [newPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        NSString *retypePassword = _confirmPasswordTextField.text;
        if (retypePassword) {
            retypePassword = [retypePassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        [_delegate passwordChangeCell:self updatePassword:password newPassword:newPassword confirmPassword:retypePassword];
    }
}

@end

@interface AccountCardCollectionCell()

@end

@implementation AccountCardCollectionCell
- (IBAction)verifyButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(accountCardCell:inputCardPin:serial:)]) {
        [_delegate accountCardCell:self inputCardPin:_pinTextField.text serial:_serialTextField.text];
    }
}

- (IBAction)telproviderButtonSelected:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(openProviderList)]) {
        [_delegate openProviderList];
    }
}

- (void)updateStatus:(ZLTextFieldStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_serialTextField setStatus:status];
        [_pinTextField setStatus:status];
    });
}

@end

#import <UIKit/UIKit.h>
#import "ZLRoundButton.h"
#import "ZLTextField.h"
#import "Auth.h"
#import "UIImage+Utilities.h"

@interface LoginButton: UIButton {
}
@end

typedef NS_OPTIONS(NSInteger, LoginType) {
    LoginTypeFacebook,
    LoginTypeEmail
};
@class LoginCollectionCell;
@protocol LoginCollectionCellDelegate <NSObject>

@optional
- (void)loginCollectionCell:(LoginCollectionCell *)cell loginWithType:(LoginType)type secretName:(NSString *)email secretPassword:(NSString *)password;
- (void)loginCollectionCell:(LoginCollectionCell *)cell forgotPasswordEmail:(NSString *)email;
- (void)signUp;
@end

@interface LoginCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet ZLTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *passwordTextField;
@property (weak, nonatomic) id<LoginCollectionCellDelegate> delegate;

@end

@class RegisterCollectionCell;
@protocol RegisterCollectionCellDelegate <NSObject>
@optional
- (void)signIn;
- (void)registerCollectionCell:(RegisterCollectionCell *)cell registerName:(NSString *)name email:(NSString *)email password:(NSString *)password passwordConfirm:(NSString *)passwordConfirm;
@end

@interface RegisterCollectionCell : UICollectionViewCell
@property (weak, nonatomic) id<RegisterCollectionCellDelegate> delegate;

- (UIImage *)avatar;
@end

@class ProfileCollectionCell;
@protocol ProfileCollectionCellDelegate <NSObject>
@optional
- (void)profileCollectionCell:(ProfileCollectionCell *)cell changeAvatarView:(UIImageView *)imageView;
- (void)profileCollectionCell:(ProfileCollectionCell *)cell changePassword:(NSString *)password;
- (void)openCardScreen;
- (void)changePassword;
@end

@interface ProfileCollectionCell : UICollectionViewCell
- (void)refresh;
@property (weak, nonatomic) id<ProfileCollectionCellDelegate> delegate;
@end

@interface MasterProfileCollectionCell : UICollectionViewCell
- (void)refresh;
@end

@class PasswordChangeCell;
@protocol PasswordChangeCellDelegate <NSObject>
- (void)passwordChangeCell:(PasswordChangeCell *)cell updatePassword:(NSString *)password newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword;
@end

@interface PasswordChangeCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ZLTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *createPasswordTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet ZLRoundButton *updateButton;

@property (weak, nonatomic) id<PasswordChangeCellDelegate> delegate;

- (void)updateStatus:(ZLTextFieldStatus)status;

- (void)clear;

@end

@class AccountCardCollectionCell;
@protocol AccountCardCollectionCellDelegate <NSObject>
- (void)openProviderList;
- (void)accountCardCell:(AccountCardCollectionCell *)cell inputCardPin:(NSString *)pin serial:(NSString *)serial;
@end

@interface AccountCardCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ZLTextField *serialTextField;
@property (weak, nonatomic) IBOutlet ZLTextField *pinTextField;

@property (weak, nonatomic) id<AccountCardCollectionCellDelegate> delegate;

- (void)updateStatus:(ZLTextFieldStatus)status;

@end

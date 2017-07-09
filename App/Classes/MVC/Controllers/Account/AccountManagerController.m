//
//  AccountManagerController.m

//
//  Created by thanhvu on 3/25/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "AccountManagerCollectionCells.h"
#import "AccountManagerController.h"
#import "JDStatusBarNotification.h"
#import "Session.h"
#import "APIClient.h"
#import "SCLAlertView.h"
#import "AppActions.h"
#import "AppDelegate.h"
#import "Auth.h"
#import "UIImage+Utilities.h"

@interface AccountManagerController ()<UITextFieldDelegate, UICollectionViewDataSource
, LoginCollectionCellDelegate, RegisterCollectionCellDelegate, UIImagePickerControllerDelegate
, UINavigationControllerDelegate, ProfileCollectionCellDelegate, PasswordChangeCellDelegate, AccountCardCollectionCellDelegate> {
    AccountScreenState state;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)p_updateState:(AccountScreenState) aState;

@end

@implementation AccountManagerController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLeftNavButton:Menu];
    [self updateLocalization];
    [self useMainBackgroundOpacity:0.5];
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    currentLayout.minimumLineSpacing = 0;
    currentLayout.minimumInteritemSpacing = 0;
    CGFloat edge = 0;
    currentLayout.sectionInset = UIEdgeInsetsMake(edge, edge, edge, edge);
    [currentLayout invalidateLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocalization)
                                                 name:kLanguageChangedNotification object:nil];
    if ([Session shared].signedIn) { //logined already123456
        [self p_updateState:AccountScreenStateProfile];
    } else { // not yet
        [self p_updateState:AccountScreenStateLogin];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)p_updateState:(AccountScreenState) aState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideKeyboard];
        if (state == aState) {
            return;
        }
        state = aState;
        
        NSString *title = @"";
        switch (state) {
            case AccountScreenStateLogin: {
                title = LocalizedString(@"tlt_signin");
                [self setLeftNavButton:Menu];
            }
                break;
            case AccountScreenStateProfile: {
                title = LocalizedString(@"tlt_account_info");
                [self setLeftNavButton:Menu];
            }
                break;
            case AccountScreenStateRegister: {
                title = LocalizedString(@"tlt_register");
                [self setLeftNavButton:Menu];
            }
                break;
            case AccountScreenStateChangePassword: {
                title = LocalizedString(@"tlt_password_change");
                [self setLeftNavButton:Back];
                [self showLeftButtonWithImage:[UIImage imageNamed:@"ic_navigation_back"] target:self selector: @selector(backToPrevious)];
            }
                break;
            case AccountScreenStateInputTelCard: {
                title = LocalizedString(@"tlt_charging");
                [self setLeftNavButton:Back];
                [self showLeftButtonWithImage:[UIImage imageNamed:@"ic_navigation_back"] target:self selector: @selector(backToPrevious)];
            }
                break;
            default:
                break;
        }
        [_collectionView reloadData];
        
        self.title = title;
        [UIView animateWithDuration:0.4 delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                         } completion:^(BOOL finished) {
                         }];
    });
}

- (void)backToPrevious {
    switch (state) {
        case AccountScreenStateChangePassword:
        case AccountScreenStateInputTelCard: {
            [self p_updateState:AccountScreenStateProfile];
        }
        break;
        default:
        break;
    }
}

#pragma mark - Handle Events
- (IBAction)closeButtonSelected:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)p_fetchUserInfo {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture.width(200).height(200)"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [Session shared].user.avatarUrl = [result valueForKeyPath:@"picture.data.url"];
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FACEBOOK_USER_INFO object:nil];
                 
                 if (state == AccountScreenStateProfile) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                     });
                 }
             } else {
             }
         }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (state == AccountScreenStateUnknow) {
        return 0;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (state) {
        case AccountScreenStateLogin: {
            LoginCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"login_cell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
            break;
        case AccountScreenStateRegister: {
            RegisterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"signup_cell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
            break;
            
        case AccountScreenStateProfile: {
            if ([Session shared].user.level == UserLevelMaster){ // master
                MasterProfileCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"master_profile_cell" forIndexPath:indexPath];
                [cell refresh];
                return cell;
            } else { // user
                ProfileCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profile_cell" forIndexPath:indexPath];
                [cell refresh];
                cell.delegate = self;
                return cell;
            }
        }
            break;
        case AccountScreenStateChangePassword: {
            PasswordChangeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"passchange_cell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
            break;
        case AccountScreenStateInputTelCard: {
            AccountCardCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"card_cell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
        default:
            break;
        
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"login_cell" forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float w = CGRectGetWidth(self.view.frame);
    float h = SCREEN_HEIGHT_PORTRAIT - 64.0f;
    switch (state) {
        case AccountScreenStateLogin: //login
            return CGSizeMake(w, MAX(h, 568));
            break;
        case AccountScreenStateRegister:
            return CGSizeMake(w, MAX(h, 568));
            break;
        case AccountScreenStateProfile:
            return CGSizeMake(w, MAX(h, 480));
            break;
        case AccountScreenStateChangePassword:
        case AccountScreenStateInputTelCard:
            return CGSizeMake(w, h);
            break;
        default:
            break;
    }
    return CGSizeZero;
}

#pragma mark - LoginCollectionCellDelegate
- (void)loginCollectionCell:(LoginCollectionCell *)cell loginWithType:(LoginType)type secretName:(NSString *)email secretPassword:(NSString *)password {
    switch (type) {
        case LoginTypeFacebook: {
//            [AppActions showLoading];
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logInWithReadPermissions: @[@"public_profile"] fromViewController:[[AppDelegate sharedInstance] topViewController] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                 if (error) {
                 } else if (result.isCancelled) {
                 } else {
                     NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
                     
                     [[Auth shared] loginWithFacebookToken:facebookToken completion:^(BOOL success) {
                         if (success) {
                             [self p_updateState:AccountScreenStateProfile];
                             [self p_fetchUserInfo];
                         }
                     }];
                 }
             }];
        }
            break;
        case LoginTypeEmail: {
            if (![AppUtils validateEmail:email]) {
                [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_email_invalid_format") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
                return;
            }
            
            if (![AppUtils validatePassword:password]) {
                [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_password_length") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
                return;
            }
            [self hideKeyboard];
            [self showLoading:YES];
            [[Auth shared] loginWithEmail:email password:password completion:^(BOOL success) {
                if (success) {
                    [self p_updateState:AccountScreenStateProfile];
                    
                    [[AppDelegate sharedInstance] fetchUserStatus:^(BOOL success) {
                    }];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Login failed" message:LocalizedString(@"msg_error_wrong_email_pass") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
                }
                
                [self showLoading:NO];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)loginCollectionCell:(LoginCollectionCell *)cell forgotPasswordEmail:(NSString *)email {
    SCLAlertView *alert = [SCLAlertView new];
    
    UITextField *textField = [alert addTextField:LocalizedString(@"tlt_input_email_require")];
    
    [alert addButton:LocalizedString(@"tlt_send") actionBlock:^(void) {
        NSString *inputEmail = textField.text;
        if (inputEmail) {
            inputEmail = [inputEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            textField.text = inputEmail;
        }
        
        if ([AppUtils validateEmail:inputEmail]) {
            
            [AppActions showLoading];
            [[APIClient shared] forgotPasswordEmail:inputEmail completion:^(BOOL success, id responseObject) {
                [AppActions hideLoading];
                if (success) {
                    success = [AppUtils validAPICode:responseObject];
                }
                
                if (success) {
                    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"msg_success_forgot_password") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil];
                    [messageAlert show];
                } else {
                    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"msg_error_normal") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil];
                    
                    [messageAlert show];
                }
            }];
        }
    }];
    
    [alert showQuestion:[[AppDelegate sharedInstance] topViewController] title:nil
               subTitle:LocalizedString(@"msg_email_checking_confirm")
       closeButtonTitle:LocalizedString(@"tlt_cancel") duration:0];
}

- (void)signUp {
    [self p_updateState:AccountScreenStateRegister];
}


#pragma mark - RegisterCollectionCellDelegate
- (void)signIn {
    [self p_updateState:AccountScreenStateLogin];
}

- (void)registerCollectionCell:(RegisterCollectionCell *)cell registerName:(NSString *)name email:(NSString *)email password:(NSString *)password passwordConfirm:(NSString *)passwordConfirm {
    
    if (name != nil) {
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if ([name length] == 0) {
        [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_display_name_blank") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
        return;
    }
    
    if (![AppUtils validateEmail:email]) {
        [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_email_invalid_format") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
        return;
    }
    
    if (![AppUtils validatePassword:password]) {
        [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_password_length") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
        return;
    }
    
    if (![password isEqualToString: passwordConfirm]) {
        //msg_error_password_match
        [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:LocalizedString(@"msg_error_password_match") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
        return;
    }
    
    [self hideKeyboard];
    
    [self showLoading:YES];
    
    [[Auth shared] registerWithEmail:email password:password name:name completion:^(User *user, NSError *error) {
        if (error) {
            NSString *errorDescription = error.localizedDescription;
            if (error.code == -1011) {
                errorDescription = LocalizedString(@"msg_error_email_exist");
            }
            [[[UIAlertView alloc] initWithTitle:LocalizedString(@"tlt_error") message:errorDescription delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil] show];
            [self showLoading:NO];
        }else{
            if (user) {
                [Session shared].user = user;
                UIImage *avatar = [cell avatar];
                if (avatar) {
                    [[APIClient shared] updateAvatar:avatar forAuthId:user.identifier completion:^(NSString *avatarUrl) {
                        user.avatarUrl = avatarUrl;
                        [self showLoading:NO];
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                } else {
                    [self showLoading:NO];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                [alert addButton:LocalizedString(@"tlt_ok") actionBlock:^(void) {
                }];
                
                id vc = [[AppDelegate sharedInstance] topViewController];
                [alert showSuccess:vc title:LocalizedString(@"tlt_register") subTitle:LocalizedString(@"msg_success_register_account") closeButtonTitle:nil duration:0.0];
            }
        }
    }];
}

#pragma mark - ProfileCollectionCellDelegate
- (void)profileCollectionCell:(ProfileCollectionCell *)cell changeAvatarView:(UIImageView *)imageView {
    BOOL isSocial = [[Session shared].user isSocial];
    if (isSocial) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:LocalizedString(@"msg_error_avatar_cannot_change") delegate:nil cancelButtonTitle:LocalizedString(@"tlt_ok") otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)openCardScreen {
    [self p_updateState:AccountScreenStateInputTelCard];
}

- (void)changePassword {
    [self hideKeyboard];
    if ([Session shared].user.type == UserAuthTypeEmail) {
        [self p_updateState:AccountScreenStateChangePassword];
    }
}

#pragma mark - AccountCardCollectionCellDelegate
- (void)openProviderList {
    id vc = [UIStoryboard viewController:SB_CardListCollectionViewController storyBoard:StoryBoardAccount];
    [[[AppDelegate sharedInstance] topViewController] presentViewController:vc animated:NO completion:^{
    }];
}

- (void)accountCardCell:(AccountCardCollectionCell *)cell inputCardPin:(NSString *)pin serial:(NSString *)serial {
    serial = [AppUtils numberString:serial];
    if (serial) {
        cell.serialTextField.text = serial;
    } else {
        cell.serialTextField.text = @"";
        [cell.serialTextField resignFirstResponder];
        return;
    }
    
    pin = [AppUtils numberString:pin];
    if (pin) {
        cell.pinTextField.text = pin;
    } else {
        cell.pinTextField.text = @"";
        [cell.pinTextField resignFirstResponder];
        return;
    }
    
    [AppActions showLoading];
    
    NSString *code = @"";//_card[@"code"]
    [cell updateStatus:ZLTextFieldDisable];
    
    [[APIClient shared] cardChargingProvider:code
                                  cardSerial:serial
                                     cardPin:pin completion:^(BOOL success, id responseObject, NSInteger statusCode) {
                                         [AppActions hideLoading];
                                         
                                         [cell updateStatus:ZLTextFieldNormal];
                                         
                                         if (success && responseObject) {
                                             success = [AppUtils validAPICode:responseObject];
                                         }
                                         
                                         NSString *msg = success?LocalizedString(@"msg_success_charging"):LocalizedString(@"msg_error_charging");
                                         SCLAlertView *alert = [[SCLAlertView alloc] init];
                                         
                                         NSString *title = LocalizedString(@"tlt_charging");
                                         id vc = [[AppDelegate sharedInstance] topViewController];
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (success) {
                                                 [alert showSuccess:vc title:title subTitle:msg closeButtonTitle:LocalizedString(@"tlt_ok") duration:0.0];
                                                 
                                                 cell.pinTextField.text = @"";
                                                 cell.serialTextField.text = @"";
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ACCOUNT_CHARGING object:nil];
                                             } else {
                                                 [alert showError:vc title:title subTitle:msg closeButtonTitle:LocalizedString(@"tlt_ok") duration:0.0];
                                             }
                                         });
                                     }];
}

#pragma mark - PasswordChangeCellDelegate
- (void)passwordChangeCell:(PasswordChangeCell *)cell updatePassword:(NSString *)password newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword {
    NSString *msg = nil;
    if (![AppUtils validatePassword:password]) {
        msg = LocalizedString(@"msg_error_password_length");
        [cell.passwordTextField resignFirstResponder];
    }
    
    if (msg == nil && ![AppUtils validatePassword:newPassword]) {
        msg = LocalizedString(@"msg_error_password_length");
        [cell.createPasswordTextField resignFirstResponder];
    }
    
    if (msg == nil && ![AppUtils validatePassword:confirmPassword]) {
        msg = LocalizedString(@"msg_error_password_length");
        [cell.confirmPasswordTextField resignFirstResponder];
    }
    
    if (msg == nil  && ![newPassword isEqualToString:confirmPassword]) {
        msg = LocalizedString(@"msg_error_password_match");
        cell.confirmPasswordTextField.text = @"";
    }
    
    if (msg == nil) {
        [AppActions showLoading];
        [cell updateStatus:ZLTextFieldDisable];
        [[APIClient shared] changePassword:password newPassword:newPassword passworConfirm:confirmPassword completion:^(BOOL success, id responseObject) {
            if (success && responseObject) {
                success = [AppUtils validAPICode:responseObject];
            }
            
            if (success) {
                // Update password
                User *user = [Session shared].user;
                user.secPass = newPassword;
            }
            
            NSString *message = success?LocalizedString(@"msg_success_password_changed"): LocalizedString(@"msg_error_password_changed");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:LocalizedString(@"tlt_yes") otherButtonTitles: nil];
            
            [alertView show];
            
            [cell clear];
            
            [AppActions hideLoading];
            [cell updateStatus:ZLTextFieldNormal];
            
            [self backButtonSelected];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:LocalizedString(@"tlt_yes") otherButtonTitles: nil];
        [alertView show];
        return;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *imgOrg = info[UIImagePickerControllerOriginalImage];
    UIImage *img = [imgOrg resizeToSize:CGSizeMake(250, 250)];
    if (img == nil) {
        return;
    }
    NSString *originalImage = [Session shared].user.avatarUrl;
    [self showLoading:YES];
    [[APIClient shared] updateAvatar:img forAuthId:[Session shared].user.identifier completion:^(NSString *avatarUrl) {
        if (avatarUrl) {
            [Session shared].user.avatarUrl = avatarUrl;
            if (state == AccountScreenStateProfile) {
                [_collectionView reloadData];
            }
            [[Auth shared] sessionChanged];
        } else {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:originalImage] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            }];
        }
        [self showLoading:NO];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

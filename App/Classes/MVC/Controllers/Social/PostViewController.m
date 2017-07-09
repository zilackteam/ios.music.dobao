//
//  PostViewController.m

//
//  Created by Toan Nguyen on 3/28/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PostViewController.h"
#import "Session.h"
#import "UIImage+Utilities.h"
#import "APIClient.h"
#import "AppActions.h"
#import "ZLRoundButton.h"

@protocol CustomInputTextViewDelegate <NSObject>
@optional
- (void)tapOnCameraButton:(UIButton *)sender;
- (void)tapOnPhotoLibraryButton:(UIButton *)sender;
@end
@interface CustomInputTextView : UITextView
@property (weak, nonatomic) IBOutlet id<CustomInputTextViewDelegate> inputViewDelegate;
@end

@implementation CustomInputTextView

-(UIView *)inputAccessoryView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, -1);
    view.layer.shadowRadius = 1.0;
    view.layer.shadowOpacity = 0.8;
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:[UIImage imageNamed:@"ic_camera"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(tapOnCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.frame = CGRectMake(8, 0, 30, 30);
    [view addSubview:cameraButton];
    
    UIButton *libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [libraryButton setImage:[UIImage imageNamed:@"ic_photo_library"] forState:UIControlStateNormal];
    [libraryButton addTarget:self action:@selector(tapOnLibraryButton:) forControlEvents:UIControlEventTouchUpInside];
    libraryButton.frame = CGRectMake(CGRectGetMaxX(cameraButton.frame) + 8, 0, 30, 30);
    [view addSubview:libraryButton];
    return view;
}

- (void)tapOnCameraButton:(id)sender{
    [_inputViewDelegate tapOnCameraButton:sender];
}
- (void)tapOnLibraryButton:(id)sender{
    [_inputViewDelegate tapOnPhotoLibraryButton:sender];
}
@end

@interface PostViewController ()<UITextViewDelegate, CustomInputTextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet CustomInputTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation PostViewController

- (void)dealloc{
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setups];
}

- (void)setups{
    [self registerForKeyboardNotifications];
    
    {// back button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ic_navigation_back"] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0, 0, 30, 30)];
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonSelected)]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    {// post button
        ZLRoundButton *button = [ZLRoundButton buttonWithType:UIButtonTypeCustom];
        button.borderWidth = 1.0f;
        button.borderColor = APPLICATION_COLOR_TEXT;
        button.cornerRadius = 3.0f;
        button.fillColor = [UIColor clearColor];
        [button.titleLabel setFont:[UIFont fontWithName:APPLICATION_FONT size:16.0]];
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonSelected)]];
        [button setFrame:CGRectMake(0, 0, 50, 30)];
        [button setTitle:LocalizedString(@"tlt_public_post") forState:UIControlStateNormal];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postButtonSelected)];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[Session shared].user.avatarUrl]];
    self.fullnameLabel.text = [Session shared].user.fullName;
    _contentTextView.tag = 100;
    
    if (_mode == PostViewModeEditing && _post) {
        _contentTextView.text = _post.content;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_contentImageView sd_setImageWithURL:[NSURL URLWithString:_post.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    CGFloat height = _contentImageView.bounds.size.width * image.size.height / image.size.width;
                    _contentImageViewHeightConstraint.constant = height;
                }
            }];
        });
        
    }
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
    self.bottomConstraint.constant = show ? height : 0;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)backButtonSelected {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)postButtonSelected {
    [_contentTextView resignFirstResponder];
    
    NSString *content = @"";
    if (_contentTextView.tag != 100 && [_contentTextView hasText]) {
        content = _contentTextView.text;
    }
    
    if (!content || ([content length] == 0 && _contentImageView.image == nil)) {
        return;
    }
    
    [AppActions showLoading];
    if (_mode == PostViewModeEditing) {
        [[APIClient shared] updatePost:_post.identifier content:content image:_contentImageView.image completion:^(Post *aPost) {
            [AppActions hideLoading];
            if (aPost) {
                aPost.user = [Session shared].user;
                _post.imageUrl = aPost.imageUrl;
                _post.content = aPost.content;
                [_delegate postViewController:self updateCompletedWithPost:_post];
            }
        }];
    } else {
        [[APIClient shared] postContent:content image:_contentImageView.image completion:^(Post *aPost) {
            [AppActions hideLoading];
            if (aPost) {
                aPost.user = [Session shared].user;
                aPost.content = content;
                [_delegate postViewController:self updateCompletedWithPost:aPost];
            }
        }];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *img = [info[UIImagePickerControllerOriginalImage] resizeToSize:CGSizeMake(1000, 1000)];
    if (img) {
        _contentImageView.image = img;
        CGFloat height = _contentImageView.bounds.size.width * img.size.height / img.size.width;
        _contentImageViewHeightConstraint.constant = height;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if (textView.tag == 100) {
        textView.textColor = RGB(128, 128, 128);
        if (_mode == PostViewModeAdd) {
            textView.text = @"";
        }
    }
    textView.tag = 101;
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView {
    if(textView.text.length == 0) {
        textView.tag = 100;
        textView.textColor = RGB(200, 200, 200);
        textView.text = @"Say something...";
        [textView resignFirstResponder];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if(textView.text.length == 0){
        textView.tag = 100;
        textView.textColor = RGB(200, 200, 200);
        textView.text = @"Say something...";
    }
    return YES;
}

#pragma mark - CustomInputTextViewDelegate

- (void)tapOnCameraButton:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)tapOnPhotoLibraryButton:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end

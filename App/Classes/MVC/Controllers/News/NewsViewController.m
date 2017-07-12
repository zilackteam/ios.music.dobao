//
//  NewsViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "NewsViewController.h"
#import "APIClient.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface NewsViewController()<UIWebViewDelegate>{
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *wBackButton;
@property (weak, nonatomic) IBOutlet UIButton *wShareButton;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setups];
    
    _webView.delegate = self;
    
    _wShareButton.hidden = APPLICATION_MODE_DEMO;
}

- (void)updateLocalization {
    self.title = LocalizedString(@"tlt_news");    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[APIClient shared] newsUrl]]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_webView loadRequest:request];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setups {
    self.title = LocalizedString(@"tlt_news");
    [self useMainBackgroundOpacity:1];
    _wBackButton.hidden = YES;
    _wBackButton.alpha = 0.8;
}

- (IBAction)goNews:(id)sender {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[APIClient shared] newsUrl]]];
    
    [_webView loadRequest:request];
}

- (IBAction)goSharing:(id)sender {
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentURL = _webView.request.URL;
    [AppActions sharingFacebookWithTitle:self.title description:nil link:_webView.request.URL.absoluteString];
}

/*
#pragma mark - Overide BaseVc's methods
- (void)backButtonSelected {
    [_webView goBack];
}
*/

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [AppDelegate showLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self setLeftNavButton:webView.canGoBack ? Back : Menu];
//    [AppDelegate hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [AppDelegate hideLoading];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    
    if ([[[APIClient shared] newsUrl] isEqualToString:url]) {
        [UIView animateWithDuration:0.2 animations:^{
            _wBackButton.alpha = 0;
            _wShareButton.alpha = 0;
        } completion:^(BOOL finished) {
            _wBackButton.hidden = YES;
            _wShareButton.hidden = APPLICATION_MODE_DEMO?APPLICATION_MODE_DEMO:YES;
        }];
    } else {
        [UIView animateWithDuration:1 animations:^{
            _wBackButton.hidden = NO;
            _wBackButton.alpha = 1;
            
            _wShareButton.hidden = APPLICATION_MODE_DEMO?APPLICATION_MODE_DEMO:NO;
            _wShareButton.alpha = 1;
        }];
    }
    return YES;
}

@end

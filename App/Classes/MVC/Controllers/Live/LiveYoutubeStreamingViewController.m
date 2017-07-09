#import "LiveYoutubeStreamingViewController.h"
#import "GTLRYouTubeService.h"
#import "GTLRYouTubeQuery.h"
#import "GTLRYouTubeObjects.h"
#import "GTLROauth2.h"
#import "GTLRUtilities.h"
#import "GTMSessionUploadFetcher.h"
#import "GTMSessionFetcherLogging.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "MemoryTicker.h"
#import "MediaStreamPlayer.h"
#import "VideoPlayer.h"
#import "MPMediaDecoder.h"


//#import "WowzaGoCoder.h"

#define LIVE_STREAMING_TITLE            @"Thu Phuong Live Streaming"
#define GG_API_CLIENT_SECRET            @""

@interface LiveYoutubeStreamingViewController ()
{
    GTLRYouTubeService *service;
    __weak IBOutlet UIWebView *webView;
}

// The top level GoCoder API interface
//@property (nonatomic, strong) WowzaGoCoder *goCoder;

//@property (nonatomic, strong) WZCameraPreview *goCoderCameraPreview;

- (void)authorize;
- (void)createBroadCast:(NSString *)title;
- (void)retrieveLiveStream;
- (void)retrieveListBroadCast;

@end

@implementation LiveYoutubeStreamingViewController

-(void)embedYouTube:(NSString *)iframe {
    NSString *embedHTML = [NSString stringWithFormat:@"%@", iframe];
    // Initialize the html data to webview
    [webView loadHTMLString:embedHTML baseURL:nil];
}

- (void)authorize {
    service = [self youTubeService];
    service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:LIVE_GG_NAME
                                                          clientID:LIVE_GG_CLIENT_ID
                                                      clientSecret:GG_API_CLIENT_SECRET];
    
    if (![self isAuthorized]) {
        [[self navigationController] pushViewController:[self createAuthController] animated:YES];
    } else {
        [self retrieveListBroadCast];
    }
}

- (void)retrieveLiveStream {
//    service = [self youTubeService];
    GTLRYouTubeQuery_LiveStreamsList *query = [GTLRYouTubeQuery_LiveStreamsList queryWithPart:@"snippet,status"];
    [service executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        if (callbackError) {
            NSLog(@"ERROR:%@", callbackError.debugDescription);
        } else {
            GTLRYouTube_LiveStreamListResponse *response = object;
            NSLog(@"LIVE STREAM COUNT:%lu", [response.items count]);
        }
    }];
}

- (void)retrieveListBroadCast {
    GTLRYouTubeQuery_LiveBroadcastsList *query = [GTLRYouTubeQuery_LiveBroadcastsList queryWithPart:@"snippet,status,contentDetails"];//cdn.ingestionInfo
    
//    [query setBroadcastType:kGTLRYouTubeBroadcastTypeEvent];
    [query setBroadcastStatus:kGTLRYouTubeBroadcastStatusAll];
//    [query setMine:NO];
    [service executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        GTLRYouTube_LiveBroadcastListResponse *response = object;
        NSLog(@"RESPONSE:%@", response.JSON);
        //GTLRYouTube_IngestionInfo *ingestionInfo;
        NSLog(@"EVENT COUNT:%lu", [response.items count]);
        
        for (GTLRYouTube_LiveBroadcast *broadcast in [response items]) {
            GTLRYouTube_LiveBroadcastSnippet *snippet = broadcast.snippet;
            NSLog(@"TITLE:%@", snippet.title);
            
            NSLog(@"%@", broadcast.contentDetails.JSONString);
            
            [self embedYouTube:broadcast.contentDetails.monitorStream.embedHtml];
            break;
        }
//        GTLRYouTube_IngestionInfo
    }];
}

// Helper to check if user is authorized
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)service.authorizer) canAuthorize];
}

- (void)startOAuthFlow:(id)sender {
    GTMOAuth2ViewControllerTouch *viewController;
    
    viewController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:kGTLRAuthScopeYouTube
                      clientID:LIVE_GG_CLIENT_ID
                      clientSecret:GG_API_CLIENT_SECRET
                      keychainItemName:LIVE_GG_NAME
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self hideSearchButton];
    
    self.title = LocalizedString(@"tlt_live_streaming");
    
//    [self authorize];
//    [self retrieveLiveStream];
    
/*
    // Register the GoCoder SDK license key
    NSError *goCoderLicensingError = [WowzaGoCoder registerLicenseKey:@"GOSK-FF42-0103-E5DE-01EF-D562"];
    if (goCoderLicensingError != nil) {
        // Log license key registration failure
        NSLog(@"%@", [goCoderLicensingError localizedDescription]);
    } else {
        // Initialize the GoCoder SDK
        self.goCoder = [WowzaGoCoder sharedInstance];
        
        if (self.goCoder != nil) {
            // Associate the U/I view with the SDK camera preview
            self.goCoder.cameraView = self.view;
            
            // Get a copy of the active config
            WowzaConfig *broadcastConfig = self.goCoder.config;
            
            // Set the defaults for 720p video
            [broadcastConfig loadPreset:WZFrameSizePreset1280x720];
            // Set the address for the Wowza Streaming Engine server or Wowza Cloud
            broadcastConfig.hostAddress = @"rtmp://192.168.1.5:1935/live";
            // Set the name of the stream
            broadcastConfig.streamName = @"myStream";
            
            // Update the active config
            self.goCoder.config = broadcastConfig;
        }
    }
*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBroadCast:(NSString *)title {
    GTLRYouTubeService *service_ = [self youTubeService];
    
    // Snippet
    GTLRYouTube_LiveBroadcastSnippet *snippet_ = [[GTLRYouTube_LiveBroadcastSnippet alloc] init];
    [snippet_ setTitle:title];
    NSDate *date = [NSDate date];
    [snippet_ setScheduledStartTime:[GTLRDateTime dateTimeWithDate:date]];
    [snippet_ setScheduledEndTime:[GTLRDateTime dateTimeWithDate:[date dateByAddingTimeInterval: 10 * 60]]];
    
    // status
    GTLRYouTube_LiveBroadcastStatus *status_ = [[GTLRYouTube_LiveBroadcastStatus alloc] init];
    [status_ setPrivacyStatus:kGTLRYouTube_LiveBroadcastStatus_PrivacyStatus_Public];
    
    // broadcast
    GTLRYouTube_LiveBroadcast *broadcast_ = [[GTLRYouTube_LiveBroadcast alloc] init];
    [broadcast_ setSnippet:snippet_];
    [broadcast_ setStatus:status_];
    [broadcast_ setKind:@"youtube#liveBroadcast"];
    
//    GTLRYouTube_LiveStreamSnippet *streamSnippet_ = [[GTLRYouTube_LiveStreamSnippet alloc] init];
//    [streamSnippet_ setTitle:@"Live Streaming - XXX"];
    
//    GTLRYouTube_CdnSettings *cdn = [[GTLRYouTube_CdnSettings alloc] init];
//    [cdn setFormat:@""];
//    [cdn setIngestionType:@"rtmp"];
    
    
    
    GTLRYouTubeQuery *query = [GTLRYouTubeQuery_LiveBroadcastsInsert queryWithObject:broadcast_ part:@"snippet,status"];
    
    [service_ executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        NSLog(@"ERROR:%@", callbackError.description);
        
        if (!callbackError) {
            
        }
    }];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLRAuthScopeYouTube
                                                                clientID:LIVE_GG_CLIENT_ID
                                                            clientSecret:GG_API_CLIENT_SECRET
                                                        keychainItemName:LIVE_GG_NAME
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the YouTube service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        service.authorizer = nil;
    } else {
        service.authorizer = authResult;
//        [self createBroadCast:@"Thu Phuong Live Streaming"];
    }
}

- (GTLRYouTubeService *)youTubeService {
    static GTLRYouTubeService *service_;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service_ = [[GTLRYouTubeService alloc] init];
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service_.shouldFetchNextPages = YES;
        [service_ setAPIKey:LIVE_API_KEY];
        [service_ setRetryEnabled:YES];
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service_.retryEnabled = YES;
    });
    return service_;
}

/*
- (void) onSuccess:(WZStatus *) goCoderStatus {
    // A successful status transition has been reported by the GoCoder SDK
    NSString *statusMessage = nil;
    
    switch (goCoderStatus.state) {
        case WZStateIdle:
            statusMessage = @"The broadcast is stopped";
            break;
            
        case WZStateStarting:
            statusMessage = @"Broadcast initialization";
            break;
            
        case WZStateRunning:
            statusMessage = @"Streaming is active";
            break;
            
        case WZStateStopping:
            statusMessage = @"Broadcast shutting down";
            break;
    }
    
    if (statusMessage != nil)
        NSLog(@"Broadcast status: %@", statusMessage);
}

- (void) onError:(WZStatus *) goCoderStatus {
    // If an error is reported by the GoCoder SDK, display an alert dialog
    // containing the error details using the U/I thread
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertDialog =
        [[UIAlertView alloc] initWithTitle:@"Streaming Error"
                                   message:goCoderStatus.description
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alertDialog show];
    });
}
*/
@end

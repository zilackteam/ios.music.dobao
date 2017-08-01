//
//  PhotoViewController.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController() <AppPhotoViewProtocol> {
}
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:0.05];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSString *)photoCellIdentifier {
    return @"PhotoCollectionCell";
}

- (AppPhotoPreviewViewController *) previewViewController {
    return [UIStoryboard viewController:SB_PhotoPreviewViewController storyBoard:StoryBoardOther];
}

@end

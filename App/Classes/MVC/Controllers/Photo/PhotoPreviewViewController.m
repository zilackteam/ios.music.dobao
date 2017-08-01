//
//  PhotoPreviewViewController.m

//
//  Created by Toan Nguyen on 2/25/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "PhotoPreviewViewController.h"
@interface PhotoPreviewViewController ()<AppPhotoPreviewProtocol>

@end

@implementation PhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AppPhotoPreviewProtocol
- (NSString *)photoCellIdentifier {
    return @"cell";
}

@end

//
//  PhotoZoomCell.h
//  Singer-Thuphuong
//
//  Created by thanhvu on 10/18/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoZoomCell : UICollectionViewCell<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (void)setImageUrl:(NSString *)url;
@end

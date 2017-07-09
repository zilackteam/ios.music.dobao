//
//  MediaActionViewController.h
//  music.application
//
//  Created by thanhvu on 3/22/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"
#import "MediaActionManager.h"

@class MediaActionViewController;

@interface MediaInfoHeaderReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@interface MediaActionCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

#pragma mark - MediaActionViewControllerDelegate
@protocol MediaActionViewControllerDelegate <NSObject>

- (void)mediaActionViewController:(MediaActionViewController *)viewController actionWithView:(UIView *)cell performAction:(MediaActionType)actionType;

@end

@interface MediaActionViewController : UIViewController

@property (strong, nonatomic) NSString *mediaTitle;
@property (strong, nonatomic) NSString *mediaDetail;
@property (weak, nonatomic) UIView *mediaView;

@property (assign, nonatomic) BOOL highlightFavourite;

@property (strong, nonatomic, readonly) NSString *configurationPlistFile;

@property (weak, nonatomic) id<MediaActionViewControllerDelegate> delegate;

- (void)setActionsConfigureFile:(NSString *)configurationFile;
- (void)dissmis:(void (^ __nullable)(void))completion;

@end

//
//  SearchViewController.h

//
//  Created by thanhvu on 1/10/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@protocol SearchViewControllerDelegate <NSObject>

@optional
- (void)searchViewController:(SearchViewController *)viewController searchWithKeyword:(NSString *)keyword;

@end

@interface SearchViewController : UIViewController

@property (nonatomic, retain) id<SearchViewControllerDelegate> delegate;

- (void)setDefaultKeyword:(NSString *)keyword;

@end

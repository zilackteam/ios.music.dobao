//
//  AlbumHeaderReusableView.h
//  music.application
//
//  Created by thanhvu on 3/28/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumHeaderReusableView : UICollectionReusableView

- (void)setTitle:(NSString *)title detail:(NSString *)detail description:(NSString *)description imageUrl:(NSString *)imageUrl;

@end

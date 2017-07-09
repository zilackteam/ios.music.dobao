//
//  DownloadingCollectionCell.h

//
//  Created by thanhvu on 2/18/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "CollectionBaseCell.h"

@class DownloadTaskObject;

@protocol DownloadingViewCellDelegate <NSObject>

@optional
- (void)downloadingViewCell:(id)downloadingViewCell removeTask:(DownloadTaskObject *) task;

@end

@interface DownloadingCollectionCell : CollectionBaseCell

- (void)setTaskObject:(DownloadTaskObject *)task;

@property(nonatomic, weak) id<DownloadingViewCellDelegate> delegate;

@end

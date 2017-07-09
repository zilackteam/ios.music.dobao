//
//  DownloadingCollectionCell.m

//
//  Created by thanhvu on 2/18/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "DownloadingCollectionCell.h"
#import "ZLDownloadManager.h"

@interface DownloadingCollectionCell()<DownloadTaskObjectDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *storageLabel;

@property (weak, nonatomic) DownloadTaskObject *task;

- (IBAction)removeTask:(id)sender;

@end

@implementation DownloadingCollectionCell

#pragma mark - Init
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

#pragma mark - Task Implementation
- (void)setTaskObject:(DownloadTaskObject *)task {
    _task = task;
    task.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [task.progress.userInfo valueForKey:@"userInfo"];

        _progressView.progress = task.progress.fractionCompleted;
        
        if (info) {
            _titleLabel.text = info[@"name"];
            _detailLabel.text = info[@"performer"];
        }
        
        int64_t bytes = task.progress.totalUnitCount;
        _storageLabel.text = [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];

    });
}

- (void)downloadTaskObject:(DownloadTaskObject *)taskObject fractionCompleted:(float)fractionCompleted totalUnit:(int64_t)total{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView setProgress:fractionCompleted animated:YES];
        
        _storageLabel.text = [[NSString stringWithFormat:@"%.01f", fractionCompleted * 100] stringByAppendingString:@"%"];
    });
}

- (void)downloadTaskObject:(DownloadTaskObject *)taskObject completedWithError:(NSError *)error {    
}

- (IBAction)removeTask:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadingViewCell:removeTask:)]) {
        [_delegate downloadingViewCell:self removeTask:_task];
    }
}
@end

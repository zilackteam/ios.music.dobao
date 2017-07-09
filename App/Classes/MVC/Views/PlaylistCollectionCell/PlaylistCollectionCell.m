//
//  PlaylistCollectionCell.m
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistCollectionCell.h"
#import "PlaylistEntity+CoreDataClass.h"

@implementation PlaylistCollectionCell

@synthesize imageView = _imageView;
@synthesize titleView = _titleView;
@synthesize detailView = _detailView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setItem:(id<MediaItem>)item {
    if (item) {
        _titleView.text = item.name;
        _detailView.text = item.detail;
    }
}

- (void)setValue:(id<BaseObject>)object {
    if (_imageView) {
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = [UIImage imageNamed:@"ic_song_playlist"];
    }
    
    id obj = object;
    
    NSString *name = [obj valueForKey:@"name"];
    _titleView.text = name?name:@"";
    
    NSString *detail = [obj valueForKey:@"detail"];
    if (detail) {
        detail = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([detail isEqualToString:@""]) {
            detail = nil;
        }
    }
    _detailView.numberOfLines = 1;
    
    NSInteger cnt = 0;
    if ([object isKindOfClass:[PlaylistEntity class]]) {
        cnt = [((PlaylistEntity*)object).songs count];
    }
    _detailView.text = [NSString stringWithFormat:LocalizedString(@"tlt_playlist_cnt_format"), cnt];
}

@end

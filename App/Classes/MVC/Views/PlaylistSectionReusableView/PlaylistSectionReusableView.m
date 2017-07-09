//
//  PlaylistSectionReusableView.m
//  music.application
//
//  Created by thanhvu on 3/20/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlaylistSectionReusableView.h"
#import "BaseObject.h"
#import "PlaylistEntity+CoreDataClass.h"

@interface PlaylistSectionReusableView()

@property(assign, nonatomic) id<BaseObject> objValue;
@end

@implementation PlaylistSectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (UINib *) nib {
    UINib *_nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    return _nib;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setValue:(id<BaseObject>)object {
    _objValue = object;
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playlistSectionResableView:selectedObject:)]) {
        [(id<PlaylistSectionReusableViewDelegate>)self.delegate playlistSectionResableView:self selectedObject:_objValue];
    }
}

@end

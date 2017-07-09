//
//  PlayingPlaylistViewCell.m
//  music.application
//
//  Created by thanhvu on 3/27/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "PlayingPlaylistViewCell.h"
#import "PlaylistSongCollectionViewCell.h"

@interface PlayingPlaylistViewCell()<MediaBaseCellDelegate> {
    NSIndexPath *PlayingItem;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PlayingPlaylistViewCell
- (void)p_initDefault {
    // default setting
    PlayingItem = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _collectionView.backgroundColor = [UIColor clearColor];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubviews];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return self;
}
 
- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (void)initializeSubviews {
    [self.collectionView registerClass:[PlaylistSongCollectionViewCell class] forCellWithReuseIdentifier:@"song_playlist_cell"];
    
    [self p_initDefault];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[AudioPlayer shared].allItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistSongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"song_playlist_cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    AudioItem *item = [AudioPlayer shared].allItems[indexPath.row];
    cell.titleView.text = item.name;
    cell.detailView.text = item.detail;
    cell.delegate = self;
    [cell setItemNo:indexPath.item + 1];
    
    if (PlayingItem == indexPath) {
        [cell setPlayingState:YES];
    } else {
        [cell setPlayingState:NO];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, 80.0f);
}

- (void)didSelectedCell:(MediaBaseCell *)cell {
    NSInteger index = [_collectionView indexPathForCell:cell].item;
    [[AudioPlayer shared] playItemAtIndex:index];
//    [[AudioPlayer shared] playItemAtIndex:indexPath.row];
}

- (void)updatePlayingState {
    
    NSArray *items = [AudioPlayer shared].allItems;
    for (int i = 0; i < [items count]; i++) {
        AudioItem *item = items[i];
        
        BOOL playing = ([[AudioPlayer shared].currentItem identifier] == item.identifier);
        if (playing) {
            PlaylistSongCollectionViewCell *cell = nil;
            if (PlayingItem != nil) {
                PlaylistSongCollectionViewCell *cell = (PlaylistSongCollectionViewCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
                if (cell) {
                    [cell setPlayingState:NO];
                }
            }
            
            PlayingItem = [NSIndexPath indexPathForItem:i inSection:0];
            cell = (PlaylistSongCollectionViewCell *)[_collectionView cellForItemAtIndexPath:PlayingItem];
            [cell setPlayingState:YES];
            break;
        }
    }
}

@end

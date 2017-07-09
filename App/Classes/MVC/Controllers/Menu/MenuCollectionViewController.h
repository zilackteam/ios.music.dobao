//
//  MenuCollectionViewController.h
//  music.application
//
//  Created by thanhvu on 3/21/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCollectionViewController : UICollectionViewController

@end

#import "BaseList.h"
#import "BaseObject.h"

#pragma mark - Menu Item Object
@interface MenuObject : NSObject<BaseObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *optionValue;
@property (strong, nonatomic) NSString *storyBoard;
@property (assign, nonatomic) BOOL enableDirection;

@end

#pragma mark - Menu Section Object
@interface MenuSection : NSObject<BaseObject>

@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) BOOL collape;
@property (strong, nonatomic) NSMutableArray *items;

- (NSInteger)numberOfItems;

- (MenuObject *)itemAtIndex:(NSInteger)index;

@end



#pragma mark - Menu Section List
@interface MenuSectionList : BaseList<BaseObject>
@end;

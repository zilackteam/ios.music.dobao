//
//  MediaActionManagement.m
//  music.application
//
//  Created by thanhvu on 3/23/17.
//  Copyright © 2017 Zilack. All rights reserved.
//

#import "MediaActionManager.h"

#pragma mark - MediaActionObject
@implementation MediaActionObject
+ (id)parseObject:(id)obj {
    if (!obj || [NSNull null] == obj) {
        return nil;
    }
    
    MediaActionObject *action = [MediaActionObject new];
    
    action.name = [obj stringValueKey:@"name"];
    action.icon = [obj stringValueKey:@"icon"];
    action.iconHighlight = [obj stringValueKey:@"iconhl"];
    action.type = (int)[obj intValueKey:@"actiontype"];
    
    return action;
}
@end

#pragma mark - MediaActionList
@implementation MediaActionList
+ (id)parseObject:(id)obj {
    if (obj && [NSNull null] != obj && [obj isKindOfClass:[NSArray class]]) {
        
        MediaActionList *actionList = [MediaActionList new];
        actionList.items = [NSMutableArray array];
        
        for (int i = 0; i < [obj count]; i++) {
            id tmp = [obj objectAtIndex:i];
            
            MediaActionObject *action = [MediaActionObject parseObject:tmp];
            if (action != nil) {
                [actionList.items addObject:action];
            }
        }
        return actionList;
    }
    return nil;
}

- (MediaActionObject *)objectByIdentifier:(NSString *)identifier {
    NSString* filter = @"actionid CONTAINS[cd] %@";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filter, identifier];
    NSArray *filtered = [self.items filteredArrayUsingPredicate:predicate];
    
    if (filtered && [filtered count] > 0) {
        return filtered[0];
    }
    return nil;
}

@end

@interface MediaActionManager()
@property (strong, nonatomic) MediaActionList *actionList;
@end

@implementation MediaActionManager

@end

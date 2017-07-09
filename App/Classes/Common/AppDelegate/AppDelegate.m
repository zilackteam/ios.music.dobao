//
//  AppDelegate.m

//
//  Created by thanhvu on 11/25/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()<AppBaseInitProtocol>
{
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL success = [super application:application didFinishLaunchingWithOptions:launchOptions];
    if (!success) {
        return NO;
    }
    
    return YES;
}

#pragma mark - AppBaseInit Protocol : App General Configuration
// !!!: BEGIN

- (void)AppInit_UIBarsStyle {
    [super AppInit_UIBarsStyle];
    
    [[UINavigationBar appearance] setBarTintColor:APPLICATION_COLOR];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:APPLICATION_COLOR_TEXT,
                                                        NSForegroundColorAttributeName, [UIFont fontWithName:APPLICATION_FONT size:16], NSFontAttributeName, nil];
    
    // tab bar
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [UITabBar appearance].tintColor = APPLICATION_COLOR;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB(222, 186, 74), NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APPLICATION_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

- (void)AppInit_Observers {
    [super AppInit_Observers];
}

- (NSString *)AppInit_ApiHost {
    return APPLICATION_API_HOST;
}

// !!!: END
@end

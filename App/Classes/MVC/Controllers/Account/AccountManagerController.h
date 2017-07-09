//
//  AccountManagerController.h

//
//  Created by thanhvu on 3/25/17.
//  Copyright © 2017 Zilack. All rights reserved.
//


#import "BaseViewController.h"

typedef NS_OPTIONS(NSInteger, AccountScreenState) {
    AccountScreenStateUnknow            = 0,
    AccountScreenStateLogin             = 1,
    AccountScreenStateRegister          = 2,
    AccountScreenStateProfile           = 3,
    AccountScreenStateChangePassword    = 4,
    AccountScreenStateInputTelCard      = 5
    
};

@interface AccountManagerController : BaseViewController

@end

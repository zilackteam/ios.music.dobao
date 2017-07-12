//
//  Constants.h

//
//  Created by thanhvu on 11/28/15.
//  Copyright © 2015 Zilack. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define NOTIF_ACCOUNT_CHARGING              @"NOTIF_ACCOUNT_CHARGING"
#define NOTIF_FACEBOOK_USER_INFO            @"NOTIF_FACEBOOK_USER_INFO"

#define INVALID_INDEX   -1

#define TIME_MINUTE_REFRESH                 360 // 6 hours

enum PageState {
    PageStateNone,
    PageStateLoading
} PageState;

typedef struct {
    int index;
    int numberOfPage;
    enum PageState state;
} DataPage;

#endif /* Constants_h */

//
//  Config.h
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ColorBackground 0xFFE773
#define ColorNavigationBar 0xFF9640

#define kSelectedOfflineModeKey @"Offline Mode"
#define kSelectedSiteUrlKey @"Selected Site Url"
#define kSelectedSiteTokenKey @"Selected Site Token"
#define kSelectedSiteNameKey @"Selected Site Name"
#define kSelectedUserIdKey @"Selected User ID"
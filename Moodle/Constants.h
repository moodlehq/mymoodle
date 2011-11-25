//
//  Constants.h
//  Moodle
//
//  Created by Dongsheng Cai on 24/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

// Handy macroes
#define DOCUMENTS_FOLDER        [NSHomeDirectory () stringByAppendingPathComponent:@"Documents"]
#define AUDIO_FOLDER            [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Audio"]
#define PHOTO_FOLDER            [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Photo"]
#define VIDEO_FOLDER            [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Video"]
#define DOWNLOADS_FOLDER        [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Downloads"]


#define OFFLINE_FOLDER          [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Offline"]

#define UIColorFromRGB(rgbValue) [UIColor \
 colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
 green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
 blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]

#define DEBUGMODE

#ifdef DEBUGMODE
#define MLog                    NSLog
#else
#define MLog                    // NSLog
#endif

// NSUserDefaults keys
#define kSelectedOfflineModeKey @"Offline Mode"
#define kAutoSync               @"AutoSync"
#define kSelectedSiteUrlKey     @"Selected Site Url"
#define kSelectedSiteTokenKey   @"Selected Site Token"
#define kSelectedSiteNameKey    @"Selected Site Name"
#define kSelectedUserIdKey      @"Selected User ID"
#define kLastUpdateDate         @"LastUpdateDate"

#define kResetSite              @"ResetActiveSite"
#define kUpdateSiteInterval     60 * 60 * 24

// Color scheme
#define ColorBackground         0xFFE773
#define RootBackground          0xF0F0F0
#define ColorToolbar            0xE59304
#define LoginBackground         0xF08C2E
#define ColorNavigationBar      0x000000

#define URL_MOODLE_HELP         @"http://docs.moodle.org/"


#define FONT_SIZE               14.0f
#define CELL_CONTENT_WIDTH      300.0f
#define CELL_CONTENT_MARGIN     5.0f


#define LOTSOFENROLLEDUSERS     100

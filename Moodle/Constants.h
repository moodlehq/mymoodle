//
// This file is part of My Moodle - https://github.com/moodlehq/mymoodle
//
// My Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Moodle.  If not, see <http://www.gnu.org/licenses/>.
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

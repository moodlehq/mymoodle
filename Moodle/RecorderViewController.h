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
//  RecorderViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import <Three20/Three20.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MoodleMedia.h"

@interface RecorderViewController : TTViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MoodleUploadDelegate> {
    NSString *recorderFilePath;
    NSString *recorderFileName;
    AppDelegate *appDelegate;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    TTStyledTextLabel *timerLabel;
    UIImageView *uv;
    NSTimer *timer;
    BOOL recording;
    BOOL playing;
    UIToolbar *_toolbar;
    UIButton *buttonRecord;
    UIBarButtonItem *buttonReplay;
    UIBarButtonItem *buttonUpload;
    MBProgressHUD *HUD;
}

@end

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

@interface RecorderViewController : TTViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    NSString *recorderFilePath;
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

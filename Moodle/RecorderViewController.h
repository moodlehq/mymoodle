//
//  RecorderViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface RecorderViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MBProgressHUDDelegate> {
    NSString *recorderFilePath;
    AVAudioRecorder *recorder;
    IBOutlet UILabel *timerLabel;
    NSTimer *timer;
    BOOL recording;
    BOOL playing;
    IBOutlet UIBarButtonItem *buttonRecord;
    IBOutlet UIBarButtonItem *buttonReplay;
    IBOutlet UIBarButtonItem *buttonUpload;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) UIBarButtonItem *buttonRecord;
@property (nonatomic, retain) UIBarButtonItem *buttonReplay;
@property (nonatomic, retain) UIBarButtonItem *buttonUpload;

- (IBAction) startRecording: (id)sender;
- (IBAction) replayAudio: (id)sender;
- (IBAction) uploadAudio;
@end

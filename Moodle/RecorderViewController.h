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

@interface RecorderViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, MBProgressHUDDelegate> {
    AVAudioRecorder *recorder;
    NSString *recorderFilePath;
    IBOutlet UIBarButtonItem *buttonRecord;
    IBOutlet UIBarButtonItem *buttonStop;
    IBOutlet UIBarButtonItem *buttonReplay;
    IBOutlet UIBarButtonItem *buttonUpload;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) UIBarButtonItem *buttonRecord;
@property (nonatomic, retain) UIBarButtonItem *buttonStop;
@property (nonatomic, retain) UIBarButtonItem *buttonReplay;
@property (nonatomic, retain) UIBarButtonItem *buttonUpload;
- (IBAction) stopRecording: (id)sender;
- (IBAction) startRecording: (id)sender;
- (IBAction) replayAudio: (id)sender;
- (IBAction) uploadAudio;
@end

//
//  RecorderViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RecorderViewController.h"
#import "Constants.h"

@implementation RecorderViewController
- (void)toggleRecordButton {
    if (recording) {
        buttonReplay.enabled = NO;
        buttonUpload.enabled = NO;
        [buttonRecord setTitle:@"Saving..." forState:UIControlStateHighlighted];
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@"stop_no_icon.png"] forState:UIControlStateNormal];
        [buttonRecord setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        buttonReplay.enabled = YES;
        buttonUpload.enabled = YES;
        [buttonRecord setTitle:@"Initializing..." forState:UIControlStateHighlighted];
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@"record_no_icon.png"] forState:UIControlStateNormal];
        [buttonRecord setTitle:@"Record" forState:UIControlStateNormal];
    }
}


- (void)loadView {
    [super loadView];
    
    UIImageView *appBg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"screen_bg.png"]];
    appBg.frame = CGRectMake(0, 0, 320, 416);
    [self.view addSubview:appBg];
    [appBg release];

    recording = NO;
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);

    UILabel *title = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, 320, 60)];
    [title setText: @"Record Audio"];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextAlignment:UITextAlignmentCenter];
//    [title setFont:[UIFont boldSystemFontOfSize:28]];
    [title setFont: [UIFont fontWithName:@"SoulPapa" size:40]];
    [self.view addSubview:title];
    [title release];

    UIImageView *recordBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_bg.png"]];
    recordBG.frame = CGRectMake((320-276)/2, 65, 276, 299);
    [self.view addSubview: recordBG];
    [recordBG release];

    uv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_1.png"]];
    [uv setFrame:CGRectMake((320-222)/2, 70, 222, 222)];
    [self.view addSubview:uv];
    [uv release];

    buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self toggleRecordButton];
//    [buttonRecord settit
    [buttonRecord.titleLabel setFont:[UIFont boldSystemFontOfSize:28]];
    [buttonRecord.titleLabel setTextAlignment:UITextAlignmentCenter];
    [buttonRecord setFrame:CGRectMake((320-225)/2, 280, 225, 73)];
    [buttonRecord addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRecord];

    buttonReplay = [[UIBarButtonItem alloc] initWithTitle:@"Replay" style:UIBarButtonItemStylePlain target:self action:@selector(replayAudio)];
    buttonReplay.tag = 2;
    buttonReplay.enabled = NO;


    buttonUpload = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(uploadPressed)];
    buttonUpload.tag = 3;
    buttonUpload.enabled = NO;

    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];


    _toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 40, self.view.frame.size.width-20, 33)] autorelease];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_toolbar.bounds 
                                                   byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _toolbar.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    _toolbar.layer.mask = maskLayer;
    _toolbar.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _toolbar.tintColor = UIColorFromRGB(ColorToolbar);
    _toolbar.items = [NSArray arrayWithObjects:
                      buttonReplay,
                      space,
                      buttonUpload,
                      nil];
    [self.view addSubview:_toolbar];
}


- (void)uploadAudio
{
    NSLog(@"Uploading audio");
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat:@"%@/files/upload.php", host];

    NSURL *url = [NSURL URLWithString:uploadurl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:token forKey:@"token"];
    [request setFile:recorderFilePath forKey:@"thefile"];
    [request startSynchronous];
    NSLog(@"end uploading");
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://upload/"] applyAnimated:YES]];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    [fm removeItemAtPath:recorderFilePath error:&err];
}

- (void)onTimer: (NSTimer *)theTimer {
    static int count = 0;
    count += 1;
//    int seconds_in_minute = count % 60;
//    int minutes_in_hour = (count / 60) % 60;
//    int hour_in_day = (count / 3600) %24;
    [recorder updateMeters];
    
    float power =  [recorder peakPowerForChannel:0];

    int  level = (int)((power+40)/2);
    if (level > 20) {
        level = 20;
    }
    if (level < 1) {
        level = 1;
    }
    [uv setImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_%d.png", level]]];
}

- (IBAction) startRecording {
    if (recording == NO) {

        timer = [NSTimer scheduledTimerWithTimeInterval:(0.2) target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err) {
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }
        [audioSession setActive:YES error:&err];
        err = nil;
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }

        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

        [settings setValue: [NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [settings setValue: [NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [settings setValue: [NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        recorderFilePath = [[NSString stringWithFormat:@"%@/%@.mp4", DOCUMENTS_FOLDER, caldate] retain];

        NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
        err = nil;
        recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
        recorder.meteringEnabled = YES;
        if(!recorder){
            NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: [err localizedDescription]
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        [settings release];

        //prepare to record
        [recorder setDelegate:self];
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;

        BOOL audioHWAvailable = audioSession.inputIsAvailable;
        if (! audioHWAvailable) {
            UIAlertView *cantRecordAlert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: @"Audio input hardware not available"
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [cantRecordAlert show];
            [cantRecordAlert release];
            return;
        }

        // start recording
        [recorder record];
        recording = YES;
        buttonReplay.enabled = NO;
    } else {
        [recorder stop];
        [timer invalidate];
        recording = NO;
        NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
        NSError *err = nil;
        NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
        if(!audioData) {
            NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
    }
    [self toggleRecordButton];
}


- (IBAction) replayAudio {
    AVAudioPlayer* player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderFilePath] error:NULL];
    player.delegate = self;
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    [player play];
}

- (IBAction)uploadPressed {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [self.view.window addSubview:HUD];

    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(uploadAudio) onTarget:self withObject:nil animated:YES];
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate method
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    [aRecorder release];
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player release];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}
         
#pragma mark - View lifecycle
 - (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[timerLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:36.0]];
    recording = NO;
    playing = NO;
}
 
 - (void)viewDidUnload
{
    buttonReplay = nil;
    buttonUpload = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
 
 
 - (void)dealloc
{
    [buttonReplay release];
    [buttonUpload release];
    [super dealloc];
}
 
 - (void)viewWillAppear:(BOOL)animated {
     NSLog(@"AppFrame: %@", NSStringFromCGRect([UIScreen mainScreen].applicationFrame));
     NSLog(@"ViewBounds: %@", NSStringFromCGRect(self.view.bounds));
     NSLog(@"view : %@", NSStringFromCGRect(self.view.frame));
     [super viewWillAppear:animated];
 }
 
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

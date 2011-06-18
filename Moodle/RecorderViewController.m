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

- (void)dealloc
{
    [buttonRecord release];
    [buttonReplay release];
    [buttonUpload release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)loadView {
    [super loadView];
    UIImage *image = [ UIImage imageNamed: @"microphone.jpg" ];
    UIImageView *imageView = [ [ UIImageView alloc ] initWithImage:image ];
    imageView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - TTToolbarHeight() - self.navigationController.navigationBar.frame.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: imageView];

    
    self.view.backgroundColor = UIColorFromRGB(ColorBackground);
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);

    buttonRecord = [[UIBarButtonItem alloc] initWithTitle:@"Record"
                                                    style:UIBarButtonItemStyleBordered target:self action:@selector(startRecording)];
    buttonRecord.tag = 1;
    buttonRecord.enabled = YES;


    buttonReplay = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                    UIBarButtonSystemItemPlay target:self action:@selector(replayAudio)];
    buttonReplay.tag = 2;
    buttonReplay.enabled = NO;


    buttonUpload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                    UIBarButtonSystemItemDone target:self action:@selector(uploadPressed)];
    buttonUpload.tag = 3;
    buttonUpload.title = @"Upload";
    buttonUpload.enabled = NO;

    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];


    _toolbar = [[UIToolbar alloc] initWithFrame:
                CGRectMake(0, self.view.bounds.size.height - TTToolbarHeight(),
                           self.view.bounds.size.width, TTToolbarHeight())];
    _toolbar.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
    _toolbar.items = [NSArray arrayWithObjects:
                      buttonRecord,
                      space,
                      buttonReplay,
                      buttonUpload,
                      nil];
    [self.view addSubview:_toolbar];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[timerLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:36.0]];    recording = NO;
    playing = NO;
}

- (void)viewDidUnload
{
    buttonRecord = nil;
    buttonReplay = nil;
    buttonUpload = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
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
    int seconds_in_minute = count % 60;
    int minutes_in_hour = (count / 60) % 60;
    int hour_in_day = (count / 3600) %24;
    [recorder updateMeters];
    
    for (int k=0; k < 2; k++) {
        float peak = [recorder peakPowerForChannel:k];
        float average = [recorder averagePowerForChannel:k];
        NSLog(@"Peak power for channel %i: %4.2f",k,peak);
        NSLog(@"Average power for channel %i:%4.2f",k,average);
        NSLog(@"%@", [NSString stringWithFormat:@"%4.2f", peak]);
        //peakLabel.text = aString ;
    }
    
    timerLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour_in_day, minutes_in_hour, seconds_in_minute];
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
        [buttonRecord setTitle:@"Stop"];
    } else {
        [recorder stop];
        [timer invalidate];
        recording = NO;
        [buttonRecord setTitle:@"Record"];
        buttonReplay.enabled = YES;
        buttonUpload.enabled = YES;
        NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
        NSError *err = nil;
        NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
        if(!audioData) {
            NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
    }
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
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];

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

@end

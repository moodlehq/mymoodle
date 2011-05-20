//
//  RecorderViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RecorderViewController.h"


@implementation RecorderViewController

@synthesize buttonRecord;
@synthesize buttonReplay;
@synthesize buttonUpload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[timerLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:36.0]];
	timerLabel.text = @"00:00:00";
    recording = NO;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)uploadAudio
{
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat:@"%@/files/upload.php", host];
    
    NSURL *url = [NSURL URLWithString:uploadurl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:token forKey:@"token"];
    [request setFile:recorderFilePath forKey:@"thefile"];
    [request startSynchronous];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    [fm removeItemAtPath:recorderFilePath error:&err];
    if(err) {
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onTimer: (NSTimer *)theTimer {
    static int count = 0;
    count += 1;
    int seconds_in_minute = count % 60;
    int minutes_in_hour = (count / 60) % 60;
    int hour_in_day = (count / 3600) %24;
    
    timerLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour_in_day, minutes_in_hour, seconds_in_minute];
}

- (IBAction) startRecording: (id)sender {
    if (recording == NO) {
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
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
        
        [settings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [settings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
        [settings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        [settings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        recorderFilePath = [[NSString stringWithFormat:@"%@/%@.aac", DOCUMENTS_FOLDER, caldate] retain];
        
        NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
        err = nil;
        recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
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
        [buttonReplay setTitle:@"test"];
        [buttonRecord setTitle:@"Stop"];
    } else {
        [recorder stop];
        [timer invalidate];
        recording = NO;
        [buttonRecord setTitle:@"Record"];
        NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
        NSError *err = nil;
        NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
        if(!audioData) {
            NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        } 
    }
}

- (IBAction) replayAudio: (id)sender {
    AVAudioPlayer* player =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderFilePath] error:NULL];
    player.delegate = self;
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    [player play];
}

- (IBAction)uploadPressed: (id)sender {
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

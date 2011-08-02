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

- (NSString *)getFilepath
{
    return recorderFilePath;
}
- (void)uploadCallback:(id)data
{
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Completed";
}

- (void)toggleRecordButton
{
    if (recording)
    {
        buttonReplay.enabled = NO;
        buttonUpload.enabled = NO;
        [buttonRecord setTitle:NSLocalizedString(@"saving", @"Saving...") forState:UIControlStateHighlighted];
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@"stop_no_icon.png"] forState:UIControlStateNormal];
        [buttonRecord setTitle:NSLocalizedString(@"stop", @"Stop") forState:UIControlStateNormal];
    }
    else
    {
        buttonReplay.enabled = YES;
        buttonUpload.enabled = YES;
        [buttonRecord setTitle:NSLocalizedString(@"initializing", @"Initializing...") forState:UIControlStateHighlighted];
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@"record_no_icon.png"] forState:UIControlStateNormal];
        [buttonRecord setTitle:NSLocalizedString(@"record", @"Record") forState:UIControlStateNormal];
    }
}

- (void)cleanupFiles
{
    // delete all files
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [fileManager removeItemAtPath:AUDIO_FOLDER error:NULL];
    // recreate folder
    if (![fileManager createDirectoryAtPath:AUDIO_FOLDER withIntermediateDirectories:YES attributes:nil error:nil])
    {
        NSLog(@"Error: Create folder failed");
    }
}

- (void)loadView
{
    [super loadView];

    UIImageView *appBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_bg.png"]];
    appBg.frame = CGRectMake(0, 0, 320, 416);
    [self.view addSubview:appBg];
    [appBg release];

    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 60)];
    [title setText:NSLocalizedString(@"recordaudio", @"Record Audio")];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextAlignment:UITextAlignmentCenter];
//    [title setFont:[UIFont boldSystemFontOfSize:28]];
    [title setFont:[UIFont fontWithName:@"SoulPapa" size:40]];
    [self.view addSubview:title];
    [title release];

    UIImageView *recordBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_bg.png"]];
    recordBG.frame = CGRectMake((320 - 276) / 2, 70, 276, 299);
    [self.view addSubview:recordBG];
    [recordBG release];

    uv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_1.png"]];
    [uv setFrame:CGRectMake((320 - 222) / 2, 70, 222, 222)];
    [self.view addSubview:uv];
    [uv release];

    buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self toggleRecordButton];
    [buttonRecord.titleLabel setFont:[UIFont boldSystemFontOfSize:28]];
    [buttonRecord.titleLabel setTextAlignment:UITextAlignmentCenter];
    [buttonRecord setFrame:CGRectMake((320 - 225) / 2, 280, 225, 73)];
    [buttonRecord addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRecord];

    buttonReplay = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"replay", @"Replay") style:UIBarButtonItemStylePlain target:self action:@selector(replayAudio:)];
    buttonReplay.tag = 2;
    buttonReplay.enabled = NO;

    buttonUpload = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"send", @"Send") style:UIBarButtonItemStylePlain target:self action:@selector(uploadPressed:)];
    buttonUpload.tag = 3;
    buttonUpload.enabled = NO;

    UIBarItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace           target:nil action:nil] autorelease];


    _toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 40, self.view.frame.size.width - 20, 33)] autorelease];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_toolbar.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
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

- (void)onTimer:(NSTimer *)theTimer
{
    [recorder updateMeters];

    float power = [recorder peakPowerForChannel:0];

    int level = (int)((power + 40) / 2);
    if (level > 20)
    {
        level = 20;
    }
    if (level < 1)
    {
        level = 1;
    }
    [uv setImage:[UIImage imageNamed:[NSString stringWithFormat:@"level_%d.png", level]]];
}

- (void)startRecording
{
    if (recording == NO)
    {
        [self cleanupFiles];
        timer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err)
        {
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }
        [audioSession setActive:YES error:&err];
        err = nil;
        if (err)
        {
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }

        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

        [settings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [settings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [settings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        recorderFileName = [[NSString stringWithFormat:@"%@.mp4", caldate] retain];
        recorderFilePath = [[NSString stringWithFormat:@"%@/%@", AUDIO_FOLDER, recorderFileName] retain];
        NSLog(@"Filename: %@", recorderFileName);
        NSLog(@"Filepath: %@", recorderFilePath);

        NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
        err = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
        recorder.meteringEnabled = YES;
        if (!recorder)
        {
            NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", @"Warning")
                                           message:[err localizedDescription]
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                 otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        [settings release];

        // prepare to record
        [recorder setDelegate:self];
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;

        BOOL audioHWAvailable = audioSession.inputIsAvailable;
        if (!audioHWAvailable)
        {
            UIAlertView *cantRecordAlert =
                [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", @"Warning")
                                           message:NSLocalizedString(@"audionotavailable", @"Audio input hardware not available")
                                          delegate:nil
                                 cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                 otherButtonTitles:nil];
            [cantRecordAlert show];
            [cantRecordAlert release];
            return;
        }

        // start recording
        [recorder record];
        recording = YES;
        buttonReplay.enabled = NO;
    }
    else
    {
        [uv setImage:[UIImage imageNamed:@"level_1.png"]];
        [recorder stop];
        [timer invalidate];
        recording = NO;
        NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
        NSError *err = nil;
        NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&err];
        if (!audioData)
        {
            NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
    }
    [self toggleRecordButton];
}


- (void)replayAudio:(id)sender
{
    if (playing == NO)
    {
        playing = YES;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderFilePath] error:NULL];
        player.delegate = self;
        UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
        [player play];
    }
    else
    {
        if ([player isPlaying])
        {
            [player stop];
        }
        playing = NO;
    }
}

- (NSString *)stringFromFileSize:(int)theSize
{
    float floatSize = theSize;

    if (theSize < 1023)
    {
        return [NSString stringWithFormat:@"%i bytes", theSize];
    }
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return [NSString stringWithFormat:@"%1.1f KB", floatSize];
    }
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return [NSString stringWithFormat:@"%1.1f MB", floatSize];
    }
    floatSize = floatSize / 1024;

    return [NSString stringWithFormat:@"%1.1f GB", floatSize];
}

- (IBAction)uploadPressed:(id)sender
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:recorderFilePath error:nil];
    NSString *filesize = [self stringFromFileSize:[[fileAttributes valueForKey:NSFileSize] intValue]];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"uploadthisfile", nil), filesize];

    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"upload", nil) otherButtonTitles:nil];

    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
    [popupQuery release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (appDelegate.netStatus == NotReachable)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

            NSString *offlineFile = [NSString stringWithFormat:@"%@/%@", OFFLINE_FOLDER, recorderFileName];
            [fileManager moveItemAtPath:recorderFilePath toPath:offlineFile error:nil];

            NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext] retain] autorelease];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
            [formatter release];
            [job setValue:@"TaskHandler"    forKey:@"target"];
            [job setValue:@"upload"         forKey:@"action"];
            [job setValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"audio", nil), stringFromDate] forKey:@"desc"];
            [job setValue:offlineFile forKey:@"data"];
            [job setValue:@"path"           forKey:@"dataformat"];
            [job setValue:@"undone"         forKey:@"status"];
            [job setValue:appDelegate.site forKey:@"site"];
            [job setValue:[NSDate date]     forKey:@"created"];

            NSError *error;
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Error saving entity: %@", [error localizedDescription]);
            }
            NSLog(@"Network not reachable");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"Network not reachable") message:NSLocalizedString(@"addedtoqueue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            // upload button
            // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
            HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
            [self.view.window addSubview:HUD];

            // Regiser for HUD callbacks so we can remove it from the window at the right time
            HUD.delegate = self;
            // Show the HUD while the provided method executes in a new thread
            [HUD showWhileExecuting:@selector(upload:) onTarget:[MoodleMedia class] withObject:self animated:YES];
        }
    }
    else if (buttonIndex == 1)
    {
        // cancel
    }
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate method
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag
{
    [aRecorder release];
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)theplayer successfully:(BOOL)flag
{
    playing = NO;
    [theplayer release];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden
{
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    buttonReplay = nil;
    buttonUpload = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [buttonReplay release];
    [buttonUpload release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self cleanupFiles];
    recording = NO;
    playing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanupFiles];
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

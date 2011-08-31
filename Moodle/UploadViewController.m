//
//  UploadViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "UploadViewController.h"
#import "Constants.h"
#import "PreviewViewController.h"
#import "RecorderViewController.h"
#import "MoodleImagePickerController.h"
#import <TargetConditionals.h>

@implementation UploadViewController

// this is an Apple function to detect if AAC is enabled
// Source: http://developer.apple.com/library/ios/#qa/qa1663/_index.html
Boolean IsAACHardwareEncoderAvailable(void)
{
    if (TARGET_IPHONE_SIMULATOR)
    {
        return true;
    }

    Boolean isAvailable = false;
    OSStatus error;

    // get an array of AudioClassDescriptions for all installed encoders for the given format
    // the specifier is the format that we are interested in - this is 'aac ' in our case
    UInt32 encoderSpecifier = kAudioFormatMPEG4AAC;
    UInt32 size;

    error = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size);
    if (error)
    {
        printf("AudioFormatGetPropertyInfo kAudioFormatProperty_Encoders error %lu %4.4s\n", error, (char *)&error); return false;
    }

    UInt32 numEncoders = size / sizeof(AudioClassDescription);
    AudioClassDescription encoderDescriptions[numEncoders];

    error = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size, encoderDescriptions);
    if (error)
    {
        printf("AudioFormatGetProperty kAudioFormatProperty_Encoders error %lu %4.4s\n", error, (char *)&error); return false;
    }

    for (UInt32 i = 0; i < numEncoders; ++i)
    {
        if (encoderDescriptions[i].mSubType == kAudioFormatMPEG4AAC && encoderDescriptions[i].mManufacturer == kAppleHardwareAudioCodecManufacturer)
        {
            isAvailable = true;
        }
    }

    return isAvailable;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"Upload", nil);

    UIImageView *appBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_bg.png"]];
    appBg.frame = CGRectMake(0, 0, 320, 416);
    [self.view addSubview:appBg];
    [appBg release];

    UIImageView *uploadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(120 - 57, 25, 57, 57)];
    [uploadIcon setImage:[UIImage imageNamed:@"upload_title.png"]];
    [self.view addSubview:uploadIcon];
    [uploadIcon release];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(130, 35, 190, 55)];
    [title setText:NSLocalizedString(@"Upload", nil)];
    [title setFont:[UIFont fontWithName:@"SoulPapa" size:40]];
    [title setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:title];
    [title release];

    int x = 15;
    int y = 90;
    int width = 290;
    int height = 90;
    TTButton *tbutton = [TTButton buttonWithStyle:@"fatButton:" title:NSLocalizedString(@"browsephotoalbums", "Browse photo albums")];
    [tbutton setImage:@"bundle://upload_photo_album.png" forState:UIControlStateNormal];
    [tbutton addTarget:self
                action:@selector(loadGallery:)
      forControlEvents:UIControlEventTouchUpInside];
    [tbutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    tbutton.frame = CGRectMake(x, y, width, height);
    [self.view addSubview:tbutton];


    tbutton = [TTButton buttonWithStyle:@"fatButton:" title:NSLocalizedString(@"takepicture", "Take a picture or video")];
    [tbutton setImage:@"bundle://upload_camera.png" forState:UIControlStateNormal];

    [tbutton addTarget:self
                action:@selector(loadCamera:)
      forControlEvents:UIControlEventTouchUpInside];
    [tbutton setTitle:NSLocalizedString(@"takepicture", @"Take a picture or video") forState:UIControlStateNormal];
    tbutton.frame = CGRectMake(x, 70 + 90 + 40, width, height);
    [self.view addSubview:tbutton];

    if (IsAACHardwareEncoderAvailable())
    {
        tbutton = [TTButton buttonWithStyle:@"fatButton:" title:NSLocalizedString(@"recordaudio", "Record audio")];
        [tbutton setImage:@"bundle://upload_audio.png" forState:UIControlStateNormal];

        [tbutton addTarget:self
                    action:@selector(loadRecorder:)
          forControlEvents:UIControlEventTouchUpInside];
        tbutton.frame = CGRectMake(x, 70 + 90 * 2 + 60, width, height);
        [self.view addSubview:tbutton];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)loadPreview:(NSString *)filepath withFilename:(NSString *)filename
{
    PreviewViewController *previewViewController = [[PreviewViewController alloc] init];
    // set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"upload", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];

    [[self navigationItem] setBackBarButtonItem:newBackButton];
    [newBackButton release];
    previewViewController.fileName = filename;
    previewViewController.filePath = filepath;
    [self.navigationController pushViewController:previewViewController animated:YES];
    [previewViewController release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *strtimestamp = [now description];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        fileName = [[NSString stringWithFormat:@"%@.jpg", strtimestamp] retain];
        filePath = [[NSString stringWithFormat:@"%@/%@", PHOTO_FOLDER, fileName] retain];
        [UIImageJPEGRepresentation (image, 0.8f) writeToFile:filePath atomically:YES];
        if ([info objectForKey:@"UIImagePickerControllerMediaMetadata"])
        {
            // Picked from camera, saving to photo album
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

            picker.view.hidden = YES;
            [picker.parentViewController dismissModalViewControllerAnimated:YES];
            [self uploadAction];
        }
        else
        {
            [picker.parentViewController dismissModalViewControllerAnimated:YES];
            [self loadPreview:filePath withFilename:fileName];
        }
    }
    else if ([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        fileName = [[NSString stringWithFormat:@"%@.mov", strtimestamp] retain];
        NSData *data = [NSData dataWithContentsOfURL:videoURL];
        filePath = [[NSString stringWithFormat:@"%@/%@", VIDEO_FOLDER, fileName] retain];
        NSLog(@"video path: %@", filePath);
        [data writeToFile:filePath atomically:YES];
        // upload now!
        picker.view.hidden = YES;
        [picker.parentViewController dismissModalViewControllerAnimated:YES];
        [self uploadAction];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;

    // Unable to save the image
    if (error)
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];

        [alert show];
        [alert release];
    }
}

- (void)loadGallery:(id)sender
{
    MoodleImagePickerController *imagePicker = [[MoodleImagePickerController alloc] init];

    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];
//    NSString *device = [[UIDevice currentDevice] model];
//    if ([device rangeOfString:@"iPad"].location == NSNotFound) {
//    } else {
//        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker] ;
//        [popover presentPopoverFromRect:CGRectMake(0, 0, 0.0, 0.0)
//                                 inView:self.view
//               permittedArrowDirections:UIPopoverArrowDirectionAny
//                               animated:YES];
//    }
    [imagePicker release];
}

- (void)loadCamera:(id)sender
{
    if ([MoodleImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        MoodleImagePickerController *imagePicker = [[MoodleImagePickerController alloc] init];
        [[[UIApplication sharedApplication] keyWindow] setRootViewController:imagePicker];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorcamera", @"Error accessing camera") message:NSLocalizedString(@"errorcameramsg", @"Device does not support a camera") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)loadRecorder:(id)sender
{
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://recorder/"] applyAnimated:YES]];
}

- (void)uploadAction
{
    if (appDelegate.netStatus == NotReachable)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

        NSString *offlineFile = [NSString stringWithFormat:@"%@/%@", OFFLINE_FOLDER, fileName];
        [fileManager moveItemAtPath:filePath toPath:offlineFile error:nil];

        NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext] retain] autorelease];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        [job setValue:@"TaskHandler"    forKey:@"target"];
        [job setValue:@"upload"         forKey:@"action"];
        [job setValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"albumpicture", nil), stringFromDate] forKey:@"desc"];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"Network not reachable") message:NSLocalizedString(@"addedtoqueue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(upload:) onTarget:[MoodleMedia class] withObject:self animated:YES];
    }
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

#pragma mark - MoodleUploadDelegate methods

- (NSString *)uploadFilepath
{
    return filePath;
}

- (void)uploadDidFinishUploading:(id)data
{
    // update HUD text
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Completed";
}

- (void)uploadFailed:(id)data {

}

@end

//
//  PreviewViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "PreviewViewController.h"
#import "MoodleJob.h"


@implementation PreviewViewController
@synthesize imageView;
@synthesize fileName;
@synthesize filePath;

-(NSString *)getFilepath {
    return filePath;
}

- (void)uploadCallback: (id)data {
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = NSLocalizedString(@"completed", @"Completed");
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"preview", nil);
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - TTToolbarHeight() - self.navigationController.navigationBar.frame.size.height);
    [self.view addSubview: imageView];

    UIBarButtonItem *buttonUpload = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"upload", nil) style:UIBarButtonItemStylePlain target:self action:@selector(uploadPressed:)];
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

    UIToolbar *_toolbar = [[UIToolbar alloc] initWithFrame:
                CGRectMake(0, self.view.bounds.size.height - TTToolbarHeight(),
                           self.view.bounds.size.width, TTToolbarHeight())];
    _toolbar.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
    _toolbar.items = [NSArray arrayWithObjects:
                      space,
                      buttonUpload,
                      space,
                      nil];
    [self.view addSubview:_toolbar];
    [buttonUpload release];
    [_toolbar release];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleBordered
                                               target:self action:@selector(backButtonPressed)] autorelease];
}

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [imageView release];
    [fileName release];
    [filePath release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    imageView = nil;
    fileName = nil;
    filePath = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    imageView.image = [UIImage imageWithContentsOfFile:filePath];
}

- (IBAction)uploadPressed: (id)sender {
    if (_appDelegate.netStatus == NotReachable) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSString *offlineFile = [NSString stringWithFormat:@"%@/%@", OFFLINE_FOLDER, fileName];
        [fileManager moveItemAtPath:filePath toPath:offlineFile error:nil];
        NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext] retain] autorelease];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        [job setValue: @"TaskHandler"    forKey: @"target"];
        [job setValue: @"upload"         forKey: @"action"];
        [job setValue: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"imagevideo", @"Image/Video"), stringFromDate]    forKey: @"desc"];
        [job setValue: offlineFile       forKey: @"data"];
        [job setValue: @"path"           forKey: @"dataformat"];
        [job setValue: @"undone"         forKey: @"status"];
        [job setValue: _appDelegate.site forKey: @"site"];
        [job setValue: [NSDate date]     forKey: @"created"];

        NSError *error;
        if (![managedObjectContext save: &error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"Network not reachable") message:NSLocalizedString(@"addedtoqueue", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        [HUD showWhileExecuting:@selector(upload:) onTarget:[MoodleMedia class] withObject:self animated:YES];
    }
}


#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //there is only one action sheet on this view, so we can check the buttonIndex against the cancel button
    if (buttonIndex == [alertView cancelButtonIndex]) {
        // delete file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    } else {
//        NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//        NSLog(@"%@", [managedObjectContext hasChanges]);
//        if (![managedObjectContext save: nil]) {
//        }
//        NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext] retain] autorelease];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
//        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
//        [formatter release];
//        [job setValue: @"MoodleMedia"    forKey: @"target"];
//        [job setValue: @"upload"         forKey: @"action"];
//        [job setValue: stringFromDate    forKey: @"desc"];
//        [job setValue: filePath          forKey: @"data"];
//        [job setValue: @"path"           forKey: @"dataformat"];
//        [job setValue: @"undone"         forKey: @"status"];
//        [job setValue: _appDelegate.site forKey: @"site"];
//        [job setValue: [NSDate date]     forKey: @"created"];
//
//        NSError *error;
//        if (![managedObjectContext save: &error]) {
//            NSLog(@"Error saving entity: %@", [error localizedDescription]);
//        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed: (id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

@end

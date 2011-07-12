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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"Preview", "Preview");
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - TTToolbarHeight() - self.navigationController.navigationBar.frame.size.height);
    [self.view addSubview: imageView];
    
    
    self.view.backgroundColor = UIColorFromRGB(ColorBackground);

    UIBarButtonItem *buttonUpload = [[UIBarButtonItem alloc] initWithTitle:@"Send to Moodle" style:UIBarButtonItemStylePlain target:self action:@selector(uploadPressed:)];
    
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

}
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
    [imageView release];
    [fileName release];
    [filePath release];
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
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    imageView.image = [UIImage imageWithContentsOfFile:filePath];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    imageView = nil;
    fileName = nil;
    filePath = nil;
}

- (IBAction)uploadPressed: (id)sender {
    if (_appDelegate.netStatus == NotReachable) {
        NSLog(@"Network not reachable");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network not reachable" message:@"Network not reachable, do you want to put this file in queen?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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

- (void)uploadCallback: (id)data {
    [self.navigationController popViewControllerAnimated:YES];
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
}

#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //there is only one action sheet on this view, so we can check the buttonIndex against the cancel button
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"Do nothing, delete file");
        // delete file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    } else {
        NSLog(@"Put file in queen");
        NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"%@", [managedObjectContext hasChanges]);
        if (![managedObjectContext save: nil]) {
        }
        NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext] retain] autorelease];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        [job setValue: @"MoodleMedia"    forKey: @"target"];
        [job setValue: @"upload"         forKey: @"action"];
        [job setValue: stringFromDate    forKey: @"desc"];
        [job setValue: filePath          forKey: @"data"];
        [job setValue: @"path"           forKey: @"dataformat"];
        [job setValue: @"undone"         forKey: @"status"];
        [job setValue: _appDelegate.site forKey: @"site"];
        [job setValue: [NSDate date]     forKey: @"created"];

        NSError *error;
        if (![managedObjectContext save: &error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
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

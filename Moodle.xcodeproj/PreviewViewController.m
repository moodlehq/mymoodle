//
//  PreviewViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "PreviewViewController.h"
#import "MoodleJob.h"
#import "CJSONDeserializer.h"

@implementation PreviewViewController
@synthesize imageView;
@synthesize fileName;
@synthesize filePath;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)uploadFile
{
    sleep(1);
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat:@"%@/files/upload.php", host];
    
    NSURL *url = [NSURL URLWithString:uploadurl];
    [uploadurl release];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:token forKey:@"token"];
    [request setFile:filePath forKey:@"thefile"];
    [request startSynchronous];
    NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsArray: [request responseData] error: nil];
    NSLog(@"result: %@", result);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    NSLog(@"Done deleted");
    [self.navigationController popViewControllerAnimated:YES];
    // Remove HUD from screen when the HUD was hidded
	// The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
	sleep(1);
}

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
        [job setValue: @"MoodleMedia" forKey: @"target"];
        [job setValue: @"upload" forKey: @"action"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        [job setValue: stringFromDate forKey: @"desc"];
        [job setValue: @"dfsdkjk" forKey: @"data"];
        [job setValue: @"path" forKey: @"dataformat"];
        [job setValue: @"undone" forKey: @"status"];
        [job setValue: _appDelegate.site forKey: @"site"];
        NSLog(@"%@", [_appDelegate.site valueForKey:@"url"]);
        [job setValue: [NSDate date] forKey: @"created"];

        NSError *error;
        if (![managedObjectContext save: &error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
        [formatter release];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadPressed: (id)sender {

    if (_appDelegate.netStatus == NotReachable) {
        NSLog(@"Network not reachable");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network not reachable" message:@"Network not reachable, do you want to put this file in queen?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        [alert release];
    } else {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(uploadFile) onTarget:self withObject:nil animated:YES];
    }
}

- (IBAction)cancelPressed: (id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    NSLog(@"MBProgressHUDDelegate");

    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

@end

//
//  UploadViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "UploadViewController.h"

@implementation UploadViewController


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
    [fileData release];
    [fileName release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad
//{
//   [super viewDidLoad];
//}


- (void)viewDidUnload
{
    fileName = nil;
    fileData = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)loadPreview: (id)data withFilename: (NSString *)filename {
    if (previewViewController == nil) {
        previewViewController = [[PreviewViewController alloc] init];
    }
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"upload", "upload") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:previewViewController animated:YES];
    previewViewController.imageView.image = (UIImage *)data;
    previewViewController.fileName = filename;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    NSURL *mediaUrl;
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    //HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //[self.navigationController.view addSubview:HUD];
	
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    //HUD.delegate = self;
    
    mediaUrl = (NSURL *)[info valueForKey:UIImagePickerControllerMediaURL];
    
    if (mediaUrl == nil) {
        image = (UIImage *) [info valueForKey:UIImagePickerControllerEditedImage];
        if (image == nil) {
            //---original image selected--- 
            image = (UIImage *) [info valueForKey: UIImagePickerControllerOriginalImage];
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            NSString *strtimestamp = [NSString stringWithFormat:@"%d.jpg", (int)timestamp];
            [self loadPreview:image withFilename:strtimestamp];
        } else {
            //---edited image picked---
        }
    } else {
    }

    [picker dismissModalViewControllerAnimated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
}

- (IBAction)loadGallery:(id)sender {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];  
    
}

- (IBAction)loadCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:YES];  
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing camera" message:@"Device does not support a camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)loadRecorder:(id)sender {
    NSLog(@"Load audio recorder");
}

- (IBAction)loadFileBrowser:(id)sender {
    NSLog(@"Load local file browser");
}

@end

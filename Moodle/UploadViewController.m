//
//  UploadViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "UploadViewController.h"

#import "NSStringAdditions.h"

#import "Config.h"
#import "ASIFormDataRequest.h"

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) uploadFile: (NSData *)fileData withFilename: (NSString *)filename
{
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat:@"%@/files/upload.php", host];
    
    NSURL *url = [NSURL URLWithString:uploadurl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:token forKey:@"token"];
    [request addData:fileData withFileName:filename andContentType:@"image/jpeg" forKey:@"thefile"];
    [request startSynchronous];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    NSURL *mediaUrl;
    mediaUrl = (NSURL *)[info valueForKey:UIImagePickerControllerMediaURL];
    
    if (mediaUrl == nil) {
        image = (UIImage *) [info valueForKey:UIImagePickerControllerEditedImage];
        if (image == nil) {
            //---original image selected--- 
            image = (UIImage *) [info valueForKey: UIImagePickerControllerOriginalImage];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            NSString *strtimestamp = [NSString stringWithFormat:@"%d.jpg", (int)timestamp];
            [self uploadFile:imageData withFilename:strtimestamp];
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
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:imagePicker animated:YES];  
}

- (IBAction)loadRecorder:(id)sender {
    NSLog(@"Load audio recorder");
}

- (IBAction)loadFileBrowser:(id)sender {
    NSLog(@"Load local file browser");
}
@end

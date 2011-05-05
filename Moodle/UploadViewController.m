//
//  UploadViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "UploadViewController.h"

#import "NSStringAdditions.h"

#import "WSClient.h"

@implementation UploadViewController
@synthesize imageView;
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
- (void)viewDidLoad
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [imagePicker release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    NSURL *mediaUrl;
    mediaUrl = (NSURL *)[info valueForKey:UIImagePickerControllerMediaURL];
    if (mediaUrl == nil) {
        image = (UIImage *) [info valueForKey:UIImagePickerControllerEditedImage];
        if (image == nil) { //---original image selected--- 
            image = (UIImage *) [info valueForKey: UIImagePickerControllerOriginalImage];
            //---display the image---
            imageView.image = image;
        } else { //---edited image picked---
        }
    } else {
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"f1.jpg"];
    [imageData writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    
    WSClient *client = [[WSClient alloc] init];
    NSNumber *contextid = [NSNumber numberWithInt:13];
    NSString *component = @"user";
    NSString *filearea  = @"private";
    NSNumber *itemid    = [NSNumber numberWithInt:0];
    NSString *filepath = @"/";
    NSString *filename = @"f1.jpg";
    NSString *filecontent = [NSString base64StringFromData:imageData length:[imageData length]];
    NSArray *wsparams = [[NSArray alloc] initWithObjects:
                         contextid, component, filearea, itemid,
                         filepath, filename, filecontent, nil];
    NSArray *result;
    @try {
        result = [client invoke: @"moodle_file_upload" withParams: wsparams];  
        NSLog(@"%@", result);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    
    //
    
    //---get the cropping rectangle applied to the image---
    //CGRect rect = [[info valueForKey:UIImagePickerControllerCropRect]
    //               CGRectValue]; //---display the image---
    imageView.image = image;
    //---video picked--- //--implement this later--
    //---hide the Image Picker---
    [picker dismissModalViewControllerAnimated:YES];
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //---user did not select image/video; hide the Image Picker--- 
    [picker dismissModalViewControllerAnimated:YES];
}

@end

//
//  Settings.m
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsSiteViewController.h"

#define kSiteNameTag 1;


@implementation SettingsViewController
@synthesize list;
@synthesize lastIndexPath;


#pragma mark - View lifecycle

- (void)dealloc{
    [list release];
    [lastIndexPath release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
     NSArray *array = [[NSArray alloc] initWithObjects:@"Moodle.org", @"Jerome.moodle.local", @"Dongsheng Moodle Site",nil];
     self.title = NSLocalizedString(@"selectsite", "select a site");
     
     // Set up the edit and add buttons.
     UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
     self.navigationItem.rightBarButtonItem = addButton;
     [addButton release];
      
     
     self.list = array;
     [array release];
     [super viewDidLoad];
 }

-(void)viewDidUnload {
    self.list = nil;
    self.lastIndexPath = nil;
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * SettingsCellIdentifier = @"SettingsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier] autorelease];
    }
    NSUInteger row = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row]; //for the checkmark image
    
    NSString *rowString = [list objectAtIndex:row];
    
    UIImage *image = [UIImage imageNamed:@"profilpicture.jpg"];
    cell.imageView.image = image;
    
    CGRect siteNameRect = CGRectMake(100, 5, 200, 18);
    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
    siteName.tag = kSiteNameTag;
    siteName.text = rowString;
    siteName.font = [UIFont boldSystemFontOfSize:15];
    [cell.contentView addSubview:siteName];
    [siteName release];
    
    CGRect userNameRect = CGRectMake(100, 26, 200, 12);
    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
    userName.tag = kSiteNameTag;
    userName.text = @"Jerome Mouneyrac";
    userName.font = [UIFont italicSystemFontOfSize:12];
    [cell.contentView addSubview:userName];
    [userName release];
    
    if (row == oldRow && lastIndexPath != nil) {
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(245, 0, 50, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [cell.contentView addSubview:imageView];
        [imageView release];
    }
    
 //   cell.textLabel.text = rowString;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [rowString release];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//    if (settingsSiteViewController == nil) {
//        settingsSiteViewController = [[SettingsSiteViewController alloc] initWithNibName:@"DisclosureDetail" bundle:nil];
//    }
//    
//    childController.title = @"Disclosure Button Pressed";
//    NSUInteger row = [indexPath row];
//    
//    NSString *selectedMovie = [list objectAtIndex:row];
//    NSString *detailMessage = [[NSString alloc] initWithFormat:@"You pressed the disclosure button for %@.", selectedMovie];
//    childController.message = detailMessage;
//    childController.title = selectedMovie;
//    [detailMessage release];
//    [self.navigationController pushViewController:childController animated:YES];
    
    NSUInteger row = [indexPath row];
//    President *prez = [self.list objectAtIndex:row];
    
    settingsSiteViewController = [[SettingsSiteViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    settingsSiteViewController.title = [list objectAtIndex:row];
//    childController.president = prez;
    
    [self.navigationController pushViewController:settingsSiteViewController animated:YES];
    [settingsSiteViewController release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *rowString = [list objectAtIndex:row];
    
    
    
    //TODO: remove this hacky code once the dashboard to gt the proper value for some saved settings
    NSArray *allControllers = self.navigationController.viewControllers;
    NSUInteger parentindex = [allControllers count] - 2 ;
    UITableViewController *parent = [allControllers objectAtIndex:parentindex];
    parent.title = rowString;

    [rowString release];
    
    
    
    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    
    if (newRow != oldRow) {
        
        if (lastCheckMark != nil) {
            [lastCheckMark removeFromSuperview];
        }
               
        
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(57, 0, 43, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [newCell.contentView addSubview:imageView];
        lastCheckMark = imageView;
        [imageView release];
        
        
        [self.tableView cellForRowAtIndexPath:lastIndexPath];

//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
//        UIImage *emptyImage = [UIImage imageNamed:@"profilepicture.png"];
//        CGRect checkMarkRect2 = CGRectMake(57, 0, 43, 45);
//        UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:checkMarkRect2];
//        [emptyImageView setImage:emptyImage];
//        [oldCell.contentView addSubview:emptyImageView];
//        [emptyImageView release];
        

        lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end

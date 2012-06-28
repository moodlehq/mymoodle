//
// This file is part of My Moodle - https://github.com/moodlehq/mymoodle
//
// My Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Moodle.  If not, see <http://www.gnu.org/licenses/>.
//
//  ContentsViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 11/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ContentsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ModuleTableCellView.h"
#import "RBFilePreviewer.h"
#import "ASIHTTPRequest.h"
#import "WSClient.h"
#import "Constants.h"
#import "Three20Core/NSStringAdditions.h"
#import "WebViewController.h"
#import "Module.h"
#import "Downloader.h"
#import "Section.h"
#import "FilesListViewController.h"
#import "NSURL+Additions.h"

@implementation ContentsViewController
@synthesize course;

#pragma mark helper methods

NSInteger sortBySortOrder(id m1, id m2, void *context)
{
    NSNumber *s1 = [m1 valueForKey:@"sortorder"];
    NSNumber *s2 = [m2 valueForKey:@"sortorder"];

    NSComparisonResult comparison = [s1 compare:s2];

    return comparison;
}

- (void)downloadResources:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];

    NSManagedObject *courseSection = [sections objectAtIndex:section];

    NSArray *modules = [[[courseSection valueForKey:@"modules"] allObjects] sortedArrayUsingFunction:sortBySortOrder context:NULL];

    // Module object
    NSManagedObject *module = [modules objectAtIndex:row];
    // contents
    NSSet *items = [module valueForKey:@"contents"];

    ModuleTableCellView *cell = (ModuleTableCellView *)[tableView cellForRowAtIndexPath:indexPath];

    [downloadingContents setObject:[NSNumber numberWithBool:YES] forKey:indexPath];


    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];

    NSMutableArray *files = [[NSMutableArray alloc] init];

    for (NSManagedObject *item in items)
    {

        NSURL *url = [NSURL URLWithString:[item valueForKey:@"fileurl"]];
        NSLog(@"file link: %@", url);

        NSString *filepath = [NSString stringWithFormat:@"%@/%@/%@%@%@", DOWNLOADS_FOLDER, [course valueForKey:@"id"], [module valueForKey:@"id"], [item valueForKey:@"filepath"], [item valueForKey:@"filename"]];

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:indexPath, @"indexPath", nil];

        [userInfo setValue:filepath forKey:@"localFilePath"];
        [userInfo setValue:item forKey:@"managedObject"];
        NSDictionary *downloadFile = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [url URLByAppendingQueryString:[NSString stringWithFormat:@"token=%@", token]], @"url",
                                      filepath, @"filepath",
                                      userInfo, @"userinfo",
                                      self, @"delegate",
                                      nil];
        [files addObject:downloadFile];
    }


    Downloader *downloader = [[Downloader alloc] initWithFiles:files];
    [files release];

    NSArray *requests = [downloader getRequests];

    for (ASIHTTPRequest *request in requests)
    {
        [queue addOperation:request];
    }

    // UI feedback
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(0, 0, 20, 20);
    [activityView startAnimating];
    cell.accessoryView = activityView;
    [activityView release];
}


- (BOOL)isCached:(NSManagedObject *)module
{
    NSArray *files = [[module valueForKey:@"contents"] allObjects];

    BOOL hasFile = NO;

    for (NSManagedObject *file in files)
    {
        if ([file valueForKey:@"localpath"])
        {
            // this will validate file path
            NSURL *fileURL = [NSURL fileURLWithPath:[file valueForKey:@"localpath"]];
            if (fileURL)
            {
                // does file exist
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[file valueForKey:@"localpath"]];
                NSLog(@"File exists: %@", [file valueForKey:@"localpath"]);
                hasFile = fileExists;
                break;
            }
        }
    }
    return hasFile;
}


- (void)updateCourseContents
{
    _reloading = YES;

    WSClient *client = [[WSClient alloc] init];

    NSNumber *courseid = [NSNumber numberWithInt:[[course valueForKey:@"id"] intValue]];
    NSArray *vals = [[NSArray alloc] initWithObjects:courseid, [NSArray array], nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"courseid", @"options", nil];

    NSDictionary *params = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
    NSArray *result;

    @try {
        result = [client invoke:@"core_course_get_contents" withParams:(NSArray *)params];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    NSManagedObject *currentCourse = course;
    [currentCourse retain];

    NSError *error;

    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entityDescription];
    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"(course = %@)", currentCourse];
    [request setPredicate:sectionPredicate];
    NSArray *allSections = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"sections in ws: %d", [result count]);
    NSLog(@"sections in db: %d", [allSections count]);

    NSMutableDictionary *sectionsExcludedFromDeletion = [[NSMutableDictionary alloc] init];

    if ([result isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *wssection in result)
        {
            Section *section;
            // check if the section id is already in core data
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"(id = %@ AND course = %@)", [wssection objectForKey:@"id"], currentCourse];
            [request setPredicate:predicate];
            NSArray *existingSections = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];

            if ([existingSections count] == 1)
            {
                section = (Section *)[existingSections lastObject];
            }
            else if ([existingSections count] == 0)
            {
                section = (Section *)[NSEntityDescription insertNewObjectForEntityForName:[entityDescription name]
                                                                   inManagedObjectContext:appDelegate.managedObjectContext];
            }
            else
            {
                NSLog(@"There is more than one section with id == %@", [wssection objectForKey:@"id"]);
            }

            // set the course values
            [section setValue:currentCourse forKey:@"course"];
            [section setValue:[wssection objectForKey:@"id"] forKey:@"id"];
            [section setValue:[wssection objectForKey:@"name"] forKey:@"name"];
            [section setValue:[wssection objectForKey:@"summary"] forKey:@"summary"];

            // This is modules info from web service response
            [Section addModulesFromArray:section modules:[wssection valueForKey:@"modules"]];
            // reserve this section
            [sectionsExcludedFromDeletion setObject:[NSNumber numberWithBool:YES] forKey:[wssection objectForKey:@"id"]];
        }
    }


    for (NSManagedObject *s in allSections)
    {
        NSNumber *courseExists = [sectionsExcludedFromDeletion objectForKey:[s valueForKey:@"id"]];
        if ([courseExists intValue] == 0)
        {
            NSLog(@"Deleting the section %@", s);
            [appDelegate.managedObjectContext deleteObject:s];
        }
    }

    // saving core date
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];

    [sectionsExcludedFromDeletion release];
    [vals release];
    [keys release];
    [params release];
    [client release];

    [currentCourse release];

    // re fetch all contents
    [request setEntity:entityDescription];
    [request setPredicate:sectionPredicate];
    sections = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    [sections retain];
    _reloading = NO;

    [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (id)init
{
    if ((self = [super init]))
    {
        if (!queue)
        {
            queue = [[NSOperationQueue alloc] init];
        }
    }

    downloadingContents = [[NSMutableDictionary alloc] init];
    [queue setMaxConcurrentOperationCount:2];
    [queue retain];
    sections = [[NSArray alloc] init];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath
{
    // Return whether the cell at the specified index path is selected or not
    NSNumber *selectedIndex = [downloadingContents objectForKey:indexPath];

    return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}


#pragma mark asihttprequest delegate
- (void)requestDone:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = request.userInfo;
    NSIndexPath *indexPath = (NSIndexPath *)[userInfo valueForKey:@"indexPath"];

    NSManagedObject *item = [userInfo valueForKey:@"managedObject"];

    [item setValue:[userInfo valueForKey:@"localFilePath"] forKey:@"localpath"];

    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // TODO: update core data entity
    [cell setAccessoryView:nil];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];

    NSLog(@"Request went wrong %@", error);
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSString *descString;
    NSManagedObject *courseSection = [sections objectAtIndex:section];

    CGFloat margin = 5;

    if ([courseSection valueForKey:@"name"] == nil)
    {
        title = [NSString stringWithFormat:@"Section %d", section];
    }
    else
    {
        title = [courseSection valueForKey:@"name"];
    }
    if ([courseSection valueForKey:@"summary"] == nil)
    {
        descString = @"";
    }
    else
    {
        descString = [[courseSection valueForKey:@"summary"] stringByRemovingHTMLTags];
        if (descString == nil)
        {
            descString = @"";
        }
    }

    UIView *sectionHeader = [[UIView alloc] init];

    UIFont *titleFont = [UIFont boldSystemFontOfSize:16.0f];
    CGSize titleSize = [title sizeWithFont:titleFont constrainedToSize:CGSizeMake(self.view.frame.size.width - margin * 2, 200000)];

    UILabel *sectionTitle = [[UILabel alloc] init];
    [sectionTitle setFrame:CGRectMake(margin, margin, titleSize.width, titleSize.height)];
    [sectionTitle setText:title];
    [sectionTitle setFont:titleFont];
    [sectionTitle setNumberOfLines:0];
    [sectionTitle setLineBreakMode:UILineBreakModeWordWrap];
    [sectionTitle setBackgroundColor:[UIColor clearColor]];
    [sectionHeader addSubview:sectionTitle];
    [sectionTitle release];

    CGSize descSize = [descString sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - margin * 2, 20000) lineBreakMode:UILineBreakModeWordWrap];
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(margin, titleSize.height + margin * 2, descSize.width, descSize.height)];
    [desc setText:descString];
    [desc setFont:[UIFont systemFontOfSize:14.0f]];
    desc.lineBreakMode = UILineBreakModeWordWrap;
    desc.numberOfLines = 0;
    [desc setUserInteractionEnabled:NO];
    [desc setBackgroundColor:[UIColor clearColor]];
    [desc setTextColor:[UIColor lightGrayColor]];

    [sectionHeader addSubview:desc];
    [desc release];

    [sectionHeader setFrame:CGRectMake(0, 0, descSize.width - 10, titleSize.height + descSize.height + margin * 3)];
    [sectionHeader setBackgroundColor:[UIColor whiteColor]];
    sectionHeader.layer.cornerRadius = 9.0;
    sectionHeader.layer.masksToBounds = YES;
    sectionHeader.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sectionHeader.layer.borderWidth = 1.0;

    return [sectionHeader autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSString *descString;
    NSManagedObject *courseSection = [sections objectAtIndex:section];

    if ([courseSection valueForKey:@"name"] == nil)
    {
        title = [NSString stringWithFormat:@"Section %d", section];
    }
    else
    {
        title = [courseSection valueForKey:@"name"];
    }
    if ([courseSection valueForKey:@"summary"] == nil)
    {
        descString = @"";
    }
    else
    {
        descString = [[courseSection valueForKey:@"summary"] stringByRemovingHTMLTags];
        if (descString == nil)
        {
            descString = @"";
        }
    }
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:16]];
    CGSize size = [descString sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width, 20000) lineBreakMode:UILineBreakModeWordWrap];
    return titleSize.height + size.height + 5 * 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSManagedObject *courseSection = [sections objectAtIndex:section];

    NSArray *modules = [courseSection valueForKey:@"modules"];

    return [modules count];
}
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"course-activity";
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];

    NSManagedObject *courseSection = [sections objectAtIndex:section];

    NSArray *modules = [[[courseSection valueForKey:@"modules"] allObjects] sortedArrayUsingFunction:sortBySortOrder context:NULL];
    NSManagedObject *module = [modules objectAtIndex:row];

    ModuleTableCellView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
    {
        cell = [[[ModuleTableCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }

    NSString *modName = [module valueForKey:@"modname"];

    UIColor *textColor;

    if ([modName isEqualToString:@"resource"] || [modName isEqualToString:@"folder"] || [modName isEqualToString:@"page"])
    {
        NSManagedObject *file = [[[module valueForKey:@"contents"] allObjects] lastObject];
        if (file)
        {
            if ([self isCached:module])
            {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            else
            {
                UIImage *image = [UIImage imageNamed:@"download.png"];
                UIControl *downloadIcon = [[UIControl alloc] initWithFrame:(CGRect) {CGPointZero, image.size }];
                downloadIcon.layer.contents = (id)image.CGImage;
                [downloadIcon addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = downloadIcon;
                [downloadIcon release];
            }
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.accessoryView = nil;
        }
        textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    }
    else if ([modName isEqualToString:@"url"])
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.accessoryView = nil;
        textColor = [UIColor blackColor];
        cell.userInteractionEnabled = YES;
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.accessoryView = nil;
        cell.userInteractionEnabled = NO;
        textColor = [UIColor lightGrayColor];
    }

    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:1];
    if ([self cellIsSelected:indexPath])
    {
        [progressView setHidden:YES];
    }
    else
    {
        [progressView setHidden:YES];
    }

    NSDictionary *cellData = [NSDictionary dictionaryWithObjectsAndKeys:[module valueForKey:@"name"], @"name",
                              @"", @"description",
                              [module valueForKey:@"modicon"], @"modicon",
                              [module valueForKey:@"modname"], @"modname",
                              nil];

    [cell setData:cellData color:textColor];
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];

    NSManagedObject *courseSection = [sections objectAtIndex:section];

    NSArray *modules = [[[courseSection valueForKey:@"modules"] allObjects] sortedArrayUsingFunction:sortBySortOrder context:NULL];
    NSManagedObject *module = [modules objectAtIndex:row];
    NSString *modname = (NSString *)[module valueForKey:@"modname"];

    if ([modname isEqualToString:@"folder"])
    {
        NSArray *files = [[module valueForKey:@"contents"] allObjects];
        int numberOfFiles = [files count];

        // display or download resources
        if ([self isCached:module])
        {
            NSMutableArray *fileURLs = [NSMutableArray array];
            for (NSManagedObject *file in files)
            {
                if ([file valueForKey:@"localpath"])
                {
                    NSURL *fileURL = [NSURL fileURLWithPath:[file valueForKey:@"localpath"]];
                    if (fileURL)
                    {
                        [fileURLs addObject:fileURL];
                    }
                }
            }

            NSLog(@"Folder file listing: %@", fileURLs);

            if (numberOfFiles == 1)
            {
                RBFilePreviewer *ql = [[RBFilePreviewer alloc] initWithFiles:fileURLs];
                [self.navigationController pushViewController:ql animated:YES];
                [ql release];
            }
            else
            {
                FilesListViewController *filesViewController = [[FilesListViewController alloc] initWithFiles:files module:module];
                [self.navigationController pushViewController:filesViewController animated:YES];
                [filesViewController release];
            }
        }
        else
        {
            [self downloadResources:indexPath];
        }
    }
    else if ([modname isEqualToString:@"resource"])
    {
        NSArray *files = [[module valueForKey:@"contents"] allObjects];
        if ([self isCached:module])
        {
            NSMutableArray *fileURLs = [NSMutableArray array];
            for (NSManagedObject *file in files)
            {
                if ([[file valueForKey:@"sortorder"] isEqualToNumber:[NSNumber numberWithInt:1]])
                {
                    [fileURLs addObject:[NSURL fileURLWithPath:[file valueForKey:@"localpath"]]];
                    break;
                }
            }

            RBFilePreviewer *ql = [[RBFilePreviewer alloc] initWithFiles:fileURLs];
            [self.navigationController pushViewController:ql animated:YES];
            [ql release];
        }
        else
        {
            [self downloadResources:indexPath];
        }
    }
    else if ([modname isEqualToString:@"page"])
    {
        if ([self isCached:module])
        {
            NSArray *files = [[module valueForKey:@"contents"] allObjects];

            NSURL *baseURL;
            NSString *filePath;
            for (NSManagedObject *file in files)
            {
                if ([[file valueForKey:@"sortorder"] isEqualToNumber:[NSNumber numberWithInt:1]])
                {
                    filePath = [file valueForKey:@"localpath"];
                    NSString *fileName = [filePath lastPathComponent];
                    NSRange range = [filePath rangeOfString:fileName];
                    baseURL = [NSURL fileURLWithPath:[filePath substringToIndex:range.location]];
                    break;
                }
            }

            NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            WebViewController *web = [[WebViewController alloc] init];

            [self.navigationController pushViewController:web animated:YES];
            [web loadHTMLString:htmlString baseURL:baseURL];

            [web release];
        }
        else
        {
            [self downloadResources:indexPath];
        }
    }
//    else if ([modname isEqualToString:@"page"])
//    {
//        NSManagedObject *page = [[[module valueForKey:@"contents"] allObjects] lastObject];
//
//        NSString *fn = [NSString stringWithFormat:@"%@/template.html", [[NSBundle mainBundle] bundlePath]];
//        NSError *error;
//        NSString *template =  [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:&error];
//        NSString *html = [NSString stringWithFormat:template, [page valueForKey:@"content"]];
//
//        int timestamp = [[NSDate date] timeIntervalSince1970];
//        NSString *tempFileTemplate = [NSTemporaryDirectory () stringByAppendingPathComponent:[NSString stringWithFormat:@"page_%d.html", timestamp]];
//        const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
//        char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
//        strcpy(tempFileNameCString, tempFileTemplateCString);
//        int fileDescriptor = mkstemp(tempFileNameCString);
//        if (fileDescriptor == -1)
//        {
//            // handle file creation failure
//        }
//        NSLog(@"Local page file path: %@", tempFileTemplate);
//
//        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
//        [data writeToFile:tempFileTemplate atomically:YES];
//
//        RBFilePreviewer *ql = [[RBFilePreviewer alloc] initWithFiles:[NSArray arrayWithObject:[NSURL fileURLWithPath:tempFileTemplate]]];
//        [self.navigationController pushViewController:ql animated:YES];
//        [ql release];
//    }
    else if ([modname isEqualToString:@"url"])
    {
        NSManagedObject *url = [[[module valueForKey:@"contents"] allObjects] lastObject];
        [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[url valueForKey:@"fileurl"]]];
    }
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:tableView]];

    if ( indexPath == nil )
    {
        return;
    }

    [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)updateTable
{
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)_tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self downloadResources:indexPath];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if ([self cellIsSelected:indexPath])
    //    {
    //        return 44 * 1.5;
    //    }
    return 44;
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [super loadView];
    CGRect tableViewRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height);
    tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_refreshHeaderView == nil)
    {

        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
        view.delegate = self;
        [tableView addSubview:view];
        _refreshHeaderView = view;
        [view release];

    }

    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView = nil;
    queue = nil;
    course = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSError *error;

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *sectionEntity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:sectionEntity];
    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"(course = %@)", course];
    [request setPredicate:sectionPredicate];
    sections = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    [sections retain];
    [self updateTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([sections count] == 0)
    {

        [super viewDidAppear:animated];

        if (appDelegate.netStatus == NotReachable)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"Network not reachable") message:NSLocalizedString(@"networkerrormsg", @"Network not reachable") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
            HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
            [self.view.window addSubview:HUD];
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"loading", nil);
            [HUD showWhileExecuting:@selector(updateCourseContents) onTarget:self withObject:nil animated:YES];
        }
    }
}

- (void)dealloc
{
    _refreshHeaderView = nil;

    [course release];
    [sections release];
    [sectionDescs release];
    [queue cancelAllOperations];
    [queue release];
    [tableView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods


- (void)reloadTableviewData
{
    @try {
        [self updateCourseContents];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"Continue") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    @finally {
    }
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{

    [self performSelector:@selector(reloadTableviewData) withObject:nil afterDelay:0.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;

}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - MBProgress delegate
- (void)hudWasHidden
{
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}
@end

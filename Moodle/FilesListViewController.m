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
//  FilesListViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 13/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "FilesListViewController.h"
#import "RBFilePreviewer.h"
#import "Module.h"

@implementation FilesListViewController

@synthesize files;

- (id)initWithFiles:(NSArray *)_files module:(NSManagedObject *)_module
{
    self = [super init];
    if (self)
    {
        self.files = _files;
        module = _module;
    }
    NSLog(@"init with files and module");
    return self;
}

- (BOOL)isValidFilePath:(NSManagedObject *)item
{
    if ([item valueForKey:@"localpath"])
    {
        NSLog(@"localpath: %@", [item valueForKey:@"localpath"]);
        NSURL *fileURL = [NSURL fileURLWithPath:[item valueForKey:@"localpath"]];
        NSLog(@"url: %@", fileURL);
        if (fileURL)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    CGRect tableViewRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height);

    tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)deleteContents
{
    [Module removeFilesFromModule:(Module *)module];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    int buttonWidth = 300;
    int buttonHeight = 45;
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, buttonWidth, buttonHeight)];
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDelete setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
    [btnDelete setTitle:NSLocalizedString(@"delete", "delete") forState:UIControlStateNormal];
    [btnDelete setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [btnDelete.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [btnDelete addTarget:self action:@selector(deleteContents) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:btnDelete];
    tableView.tableFooterView = buttonView;
    [buttonView release];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.files count];
}
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"file-cell";

    NSInteger row = [indexPath row];

    NSManagedObject *file = [self.files objectAtIndex:row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    [cell.textLabel setText:[file valueForKey:@"filename"]];
    if ([self isValidFilePath:file])
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return cell;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = [indexPath row];

    NSManagedObject *file = [self.files objectAtIndex:row];
    if ([file valueForKey:@"localpath"])
    {
        NSURL *fileURL = [NSURL fileURLWithPath:[file valueForKey:@"localpath"]];
        if (!fileURL)
        {
            return;
        }
    }
    else
    {
        return;
    }

    NSMutableArray *fileURLs = [NSMutableArray array];
    for (NSManagedObject *file in self.files)
    {
        if ([self isValidFilePath:file])
        {
            [fileURLs addObject:[NSURL fileURLWithPath:[file valueForKey:@"localpath"]]];
        }
    }
    RBFilePreviewer *ql = [[RBFilePreviewer alloc] initWithFiles:fileURLs atIndex:row];
    [self.navigationController pushViewController:ql animated:YES];
    [ql release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.files = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)dealloc
{
    [self.files dealloc];
    [super dealloc];
}

@end

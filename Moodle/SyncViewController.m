//
//  SyncViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 23/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//


#define SPINNER_SIZE 25

#define kTableRowHeight             40.0
#define kProgressBarLeftMargin      20.0
#define kProgressBarTopMargin       5.0
#define kProgressBarWidth           253.0
#define kProgressBarHeight          9.0   // Standard Height
#define kProgressLabelLeftMargin    20.0
#define kProgressLabelTopMargin     19.0
#define kProgressViewTag            1011
#define kProgressLabelTag           1012


#import "SyncViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TaskHandler.h"


@implementation SyncViewController
@synthesize fetchedResultsController=_fetchedResultsController;
#pragma mark - NSFetchedResultsController


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Job" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setFetchBatchSize: 10];
    //Set the predicate for only current site
//    NSLog(@"Searching unsynced items of %@", appDelegate.site);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [request setPredicate: predicate];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
                              initWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext:context sectionNameKeyPath: nil cacheName: nil];
    self.fetchedResultsController = controller;
    _fetchedResultsController.delegate = self;
    [request release];
    [controller release];
    return _fetchedResultsController;
}


#pragma mark - delloc

- (void)dealloc
{
    [self.fetchedResultsController release];
    [switchAuto release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"taskqueue", @"Task queue");
    context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    tableviewFooter = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 120)];
    tableviewFooter.userInteractionEnabled = YES;
    
    UILabel *labelAuto = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, 270, 20)];
    [labelAuto setText: @"Send immediately when online"];
    [labelAuto setFont: [UIFont systemFontOfSize: 14]];
    
    switchAuto = [[UISwitch alloc] init];
    [switchAuto setFrame:CGRectMake(5, 10, 50, 10)];
    [switchAuto setOn:YES];
    switchAuto.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [switchAuto addTarget:self action:@selector(changeAutoSync:) forControlEvents:UIControlEventTouchUpInside];
    

    [tableviewFooter addSubview:switchAuto];
    [tableviewFooter addSubview:labelAuto];
    [labelAuto release];
    [self.tableView setTableFooterView:tableviewFooter];
    [tableviewFooter release];
}

- (void)changeAutoSync: (UISwitch *)sender {
    NSLog(@"touched %d", sender.on);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: sender.on forKey: kAutoSync];
    [defaults synchronize];
    if (sender.on) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                   initWithTitle:NSLocalizedString(@"sendnow", @"Send all") style:UIBarButtonItemStyleBordered
                                                   target:self action:@selector(syncPressed)] autorelease];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = UIColorFromRGB(ColorNavigationBar);
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch: &error]) {
        NSLog(@"unresolved error %@, %@", error, [error userInfo]);
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"cancel", @"Cancel") style:UIBarButtonItemStyleBordered
                                              target:self action:@selector(dismiss)] autorelease];
 
    BOOL autosync = [[NSUserDefaults standardUserDefaults] boolForKey: kAutoSync];
    [switchAuto setOn:autosync];
    if (autosync == NO) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                   initWithTitle:NSLocalizedString(@"sendnow", @"Send all") style:UIBarButtonItemStyleBordered
                                                   target:self action:@selector(syncPressed)] autorelease];
    }
//    if (appDelegate.netStatus == NotReachable) {
//        [self.navigationItem.rightBarButtonItem setEnabled:NO];
//    } else {
//        [self.navigationItem.rightBarButtonItem setEnabled:YES];
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
    switchAuto = nil;
}

#pragma mark -
#pragma mark Table view data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)fillCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath {
    NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = [job valueForKey:@"desc"];
    NSString *detailedText = [NSString stringWithFormat:@"%@:%@", [job valueForKey:@"target"], [job valueForKey: @"action"]];
    cell.detailTextLabel.text = NSLocalizedString(detailedText, @"user friendly task explaination");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"OperationQueueCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellID] autorelease];

    }


    cell.accessoryView.tag = [indexPath row];
    [self fillCell: cell atIndexPath: indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    
//    // Get center of cell (vertically) 
//    int center = [cell frame].size.height / 2;
//    
//    // Size (width) of the text in the cell
//    CGSize size = [[[cell textLabel] text] sizeWithFont:[[cell textLabel] font]];
//    
//    // Locate spinner in the center of the cell at end of text
//    [spinner setFrame:CGRectMake(size.width + SPINNER_SIZE, center - SPINNER_SIZE / 2, SPINNER_SIZE, SPINNER_SIZE)];
//    [[cell contentView] addSubview:spinner];    
//    
//    [spinner startAnimating];
//    [spinner release];
//    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
//
//    NSLog(@"selected: %@", [job valueForKey:@"site"]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete data
        [self.tableView beginUpdates];
        NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
        [context deleteObject: job];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
        [self.tableView endUpdates];
    }
    [self.tableView reloadData];
}
#pragma mark - fetchedresult controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"deletion detected");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fillCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


#pragma mark - actions
- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)syncPressed {
    [NSThread detachNewThreadSelector: @selector(sync) toTarget: self withObject: nil];
}

- (void)sync {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Job" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setFetchBatchSize: 10];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [request setPredicate: predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
                              initWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error = nil;
    NSArray *jobs = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *job in jobs) {
        id target = NSClassFromString([job valueForKey:@"target"]);
        SEL method = NSSelectorFromString([NSString stringWithFormat:@"%@:format:", [job valueForKey:@"action"]]);
        @try {
            [target performSelector: method withObject: [job valueForKey:@"data"] withObject:[job valueForKey:@"dataformat"]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        [self performSelectorOnMainThread:@selector(updateTableView:)
                               withObject: job
                            waitUntilDone:YES];
    }

    [pool drain];
}
- (void)updateTableView: (NSManagedObject *)job {
    if (job) {
        [context deleteObject:job];
        [context save:nil];
    }
}

@end

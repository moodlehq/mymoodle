//
//  FilesListViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 13/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Module.h"

@interface FilesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableView;
    AppDelegate *appDelegate;
    NSArray *files;
    NSManagedObject *module;
}
@property (nonatomic, retain) NSArray *files;
- (id)initWithFiles:(NSArray *)_files module:(NSManagedObject *)module;
@end

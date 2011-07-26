//
//  Job.m
//  Moodle
//
//  Created by Dongsheng Cai on 3/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "MoodleJob.h"


@implementation MoodleJob
@dynamic status;
@dynamic target;
@dynamic action;
@dynamic data;
@dynamic dataformat;
@dynamic created;
@dynamic desc;
@dynamic site;

+ (NSInteger)countWithContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Job" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    [request release];
    if(count == NSNotFound) {
        count = 0;
    }
    return count;
}
@end

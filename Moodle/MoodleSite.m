//
//  MoodleSite.m
//  Moodle
//
//  Created by Dongsheng Cai on 25/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "MoodleSite.h"


@implementation MoodleSite


+ (BOOL)siteExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc andUsername:(NSString *)username{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Site"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"url like %@ AND username = %@", theURL, username]];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    fetchRequest = nil;

    return (results.count > 0);
}
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Site" inManagedObjectContext:context]];
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

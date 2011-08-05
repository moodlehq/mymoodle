//
//  MoodleSite.h
//  Moodle
//
//  Created by Dongsheng Cai on 25/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoodleSite : NSManagedObject {
}

#pragma mark -
#pragma mark Class methods
+ (BOOL)siteExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc andUsername:(NSString *)username;
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context;
+ (void)deleteSite:(NSManagedObjectContext *)context withSite:(NSManagedObject *)site;
@end

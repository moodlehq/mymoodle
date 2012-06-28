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

+ (NSInteger)countWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:[NSEntityDescription entityForName:@"Job" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    [request release];
    if (count == NSNotFound)
    {
        count = 0;
    }
    return count;
}
@end

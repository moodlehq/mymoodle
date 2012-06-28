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
//  AddressAnnotation.m
//  Moodle
//
//  Created by Dongsheng Cai on 29/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation

@synthesize coordinate;

- (NSString *)subtitle
{
    return mSubTitle;
}
- (NSString *)title
{
    return mTitle;
}
- (void)setContact:(NSString *)name withAddress:(NSString *)address
{
    mTitle = name;
    mSubTitle = address;
}


- (id)initWithCoordinate:(CLLocationCoordinate2D)c
{
    coordinate = c;
    return self;
}

@end

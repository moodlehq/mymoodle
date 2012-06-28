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
//  MoodleButtonStyleSheet.m
//  Moodle
//
//  Created by Dongsheng Cai on 23/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "MoodleStyleSheet.h"
#import "Constants.h"

@implementation MoodleStyleSheet
- (TTStyle *)notificationButton:(UIControlState)state
{
    if (state == UIControlStateNormal)
    {
        return
            [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
             [TTLinearGradientFillStyle styleWithColor1:UIColorFromRGB(0xFFB273) color2:UIColorFromRGB(0xFF9640) next:
              [TTImageStyle styleWithImageURL:@"bundle://sync.png" defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeMake(12, 12) next:
               [TTTextStyle styleWithFont:nil color:[UIColor whiteColor] shadowColor:[UIColor colorWithWhite:255 alpha:0.4] shadowOffset:CGSizeMake(0, -1) next:nil]]]];
    }
    else if (state == UIControlStateHighlighted)
    {
        return
            [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
             [TTLinearGradientFillStyle styleWithColor1:UIColorFromRGB(0xFF9640) color2:UIColorFromRGB(0xFFB273) next:
              [TTImageStyle styleWithImageURL:@"bundle://sync.png" defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeMake(12, 12) next:
               [TTTextStyle styleWithFont:nil color:UIColorFromRGB(0xCCCCCC) shadowColor:[UIColor colorWithWhite:255 alpha:0.4] shadowOffset:CGSizeMake(0, -1) next:nil]]]];
    }
    else
    {
        return nil;
    }
}

- (TTStyle *)MoodleLauncherButton:(UIControlState)state
{
    return
        [TTPartStyle styleWithName:@"image" style:TTSTYLESTATE(launcherButtonImage:, state) next:
         [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:12] color:UIColorFromRGB(0xA64B00)
                    minimumFontSize:11 shadowColor:UIColorFromRGB(0x000000)
                       shadowOffset:CGSizeZero next:nil]];
}

- (UIColor *)toolbarTintColor
{
    return UIColorFromRGB(ColorNavigationBar);
}

- (TTStyle *)fatButton:(UIControlState)state
{
    return
        [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
         [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
          [TTShadowStyle styleWithColor:[UIColor grayColor] blur:10 offset:CGSizeMake(0, 4) next:
           [TTSolidFillStyle styleWithColor:UIColorFromRGB(0xFFFFFF) next:
            [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
             [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
              [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeLeft size:CGSizeZero next:
               [TTTextStyle styleWithFont:[UIFont systemFontOfSize:15]
                                    color:[UIColor blackColor] shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
                             shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];
}


@end

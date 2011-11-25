//
//  ModuleTableCellView.h
//  Moodle
//
//  Created by Dongsheng Cai on 18/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleTableCellView : UITableViewCell {
    NSDictionary *cellData;
    UILabel *moduleName;
    UILabel *moduleDescription;
    UIImageView *moduleIcon;
}

@property (nonatomic, retain) UILabel *moduleName;
@property (nonatomic, retain) UIImageView *moduleIcon;
@property (nonatomic, retain) UILabel *moduleDescription;

- (void)setData:(NSDictionary *)dict;
- (void)setData:(NSDictionary *)dict color:(UIColor *)color;

@end

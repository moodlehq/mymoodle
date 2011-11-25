//
//  ModuleTableCellView.m
//  Moodle
//
//  Created by Dongsheng Cai on 18/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ModuleTableCellView.h"
#import "UIImageView+WebCache.h"

@implementation ModuleTableCellView

@synthesize moduleName, moduleDescription, moduleIcon;

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    // get the X pixel spot
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    /*
     * Place the title label.
     * place the label whatever the current X is plus 10 pixels from the left
     * place the label 4 pixels from the top
     * make the label 200 pixels wide
     * make the label 20 pixels high
     */
    frame = CGRectMake(boundsX + 10, 12, 16, 16);
    self.moduleIcon.frame = frame;

    frame = CGRectMake(boundsX + 30, 0, 200, 44);
    self.moduleName.frame = frame;

}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    /*
     * Create and configure a label.
     */
    UIFont *font;

    if (bold)
    {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    else
    {
        font = [UIFont systemFontOfSize:fontSize];
    }

    /*
     *   Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
     */
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.textColor = primaryColor;
    newLabel.highlightedTextColor = selectedColor;
    newLabel.font = font;

    return newLabel;
}

- (void)setData:(NSDictionary *)dict
{
    cellData = dict;
    self.moduleName.text = [cellData objectForKey:@"name"];
    self.moduleDescription.text = [cellData objectForKey:@"description"];
    [self.moduleIcon setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"modicon"]] placeholderImage:[UIImage imageNamed:@"module.gif"]];

}

- (void)setData:(NSDictionary *)dict color:(UIColor *)color
{
    cellData = dict;
    self.moduleName.text = [cellData objectForKey:@"name"];
    self.moduleName.textColor = color;
    self.moduleDescription.text = [cellData objectForKey:@"description"];
    [self.moduleIcon setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"modicon"]] placeholderImage:[UIImage imageNamed:@"module.gif"]];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {

        UIView *moduleView = self.contentView;
//        [moduleView setBackgroundColor:[UIColor greenColor]];
        self.moduleName = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
        self.moduleName.textAlignment = UITextAlignmentLeft; // default
        [moduleView addSubview:self.moduleName];
        [self.moduleName release];

        self.moduleIcon = [[UIImageView alloc] init];
        [moduleView addSubview:self.moduleIcon];
        [self.moduleIcon release];


        self.moduleDescription = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
        self.moduleDescription.textAlignment = UITextAlignmentLeft;         // default
        [moduleView addSubview:self.moduleDescription];
        [self.moduleDescription release];
    }

    return self;
}
- (void)dealloc
{
    [super dealloc];
}
@end

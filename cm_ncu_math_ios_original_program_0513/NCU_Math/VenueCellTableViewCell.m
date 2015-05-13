//
//  VenueCellTableViewCell.m
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "VenueCellTableViewCell.h"

@implementation VenueCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)venue_call_action:(UIButton *)sender {
}

- (IBAction)venue_navigate_action:(UIButton *)sender {
}

- (IBAction)venue_website_action:(UIButton *)sender {
}
@end

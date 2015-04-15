//
//  SettingLoginCellTableViewCell.m
//  SQuInt2014
//
//  Created by csjan on 9/9/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "SettingLoginCellTableViewCell.h"

@implementation SettingLoginCellTableViewCell

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

- (IBAction)login_action_button_tap:(UIButton *)sender {
}
@end

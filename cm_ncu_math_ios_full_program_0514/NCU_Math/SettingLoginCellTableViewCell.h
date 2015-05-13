//
//  SettingLoginCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/9/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingLoginCellTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *login_name_label;
@property (strong, nonatomic) IBOutlet UIButton *login_action_button;
- (IBAction)login_action_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *login_subtitle_label;


@end

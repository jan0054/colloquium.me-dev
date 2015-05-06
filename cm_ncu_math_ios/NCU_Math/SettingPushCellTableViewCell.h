//
//  SettingPushCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/9/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingPushCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *push_status_label;
@property (strong, nonatomic) IBOutlet UISwitch *push_status_switch;
- (IBAction)push_status_switch_tap:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UILabel *push_subtitle_label;

@end

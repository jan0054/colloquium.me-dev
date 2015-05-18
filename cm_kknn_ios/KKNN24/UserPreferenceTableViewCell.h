//
//  UserPreferenceTableViewCell.h
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPreferenceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *preference_main_label;
@property (weak, nonatomic) IBOutlet UILabel *preference_subtitle_label;
@property (weak, nonatomic) IBOutlet UIButton *preference_change_button;

@end

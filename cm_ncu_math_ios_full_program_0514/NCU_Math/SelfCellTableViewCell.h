//
//  SelfCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UILabel *institution_label;
@property (strong, nonatomic) IBOutlet UIButton *edit_button;
- (IBAction)edit_button_tap:(UIButton *)sender;

@end

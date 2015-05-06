//
//  CareerCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CareerCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *career_position_label;
@property (strong, nonatomic) IBOutlet UILabel *career_institution_label;
@property (strong, nonatomic) IBOutlet UILabel *career_author_label;
@property (strong, nonatomic) IBOutlet UIButton *career_detail_button;
- (IBAction)career_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *career_card_view;
@property (strong, nonatomic) IBOutlet UIView *career_trim_view;
@property (strong, nonatomic) IBOutlet UILabel *career_type_label;

@end

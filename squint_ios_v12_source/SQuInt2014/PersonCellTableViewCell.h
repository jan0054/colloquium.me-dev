//
//  PersonCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UILabel *institution_label;
@property (strong, nonatomic) IBOutlet UIButton *person_detail_button;
@property (strong, nonatomic) IBOutlet UIView *person_card_view;
@property (strong, nonatomic) IBOutlet UIView *person_trim_view;

@end

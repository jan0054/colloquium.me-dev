//
//  AbstractCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbstractCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *abstract_author_label;
@property (strong, nonatomic) IBOutlet UILabel *abstract_title_label;
@property (strong, nonatomic) IBOutlet UIButton *abstract_detail_button;
- (IBAction)abstract_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *abstract_card_view;
@property (strong, nonatomic) IBOutlet UIView *abstract_trim_view;

@end

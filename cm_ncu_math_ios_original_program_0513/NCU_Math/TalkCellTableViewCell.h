//
//  TalkCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *talk_author_label;
@property (strong, nonatomic) IBOutlet UILabel *talk_time_label;
@property (strong, nonatomic) IBOutlet UILabel *talk_location_label;
@property (strong, nonatomic) IBOutlet UILabel *talk_name_label;
@property (strong, nonatomic) IBOutlet UILabel *talk_description_label;
@property (strong, nonatomic) IBOutlet UIButton *talk_detail_button;
- (IBAction)talk_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *talk_card_view;
@property (strong, nonatomic) IBOutlet UIView *talk_trim_view;


@end

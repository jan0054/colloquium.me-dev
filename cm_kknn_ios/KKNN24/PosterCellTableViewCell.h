//
//  PosterCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PosterCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *poster_author_label;
@property (strong, nonatomic) IBOutlet UILabel *poster_location_label;
@property (strong, nonatomic) IBOutlet UILabel *poster_topic_label;
@property (strong, nonatomic) IBOutlet UILabel *poster_content_label;
@property (strong, nonatomic) IBOutlet UIButton *poster_detail_button;
- (IBAction)poster_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *poster_card_view;
@property (strong, nonatomic) IBOutlet UIView *poster_trim_view;

@end

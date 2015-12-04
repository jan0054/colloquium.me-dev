//
//  HomeCell.h
//  cm_math_one
//
//  Created by csjan on 7/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *organizerLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreLabel;
@property NSString *eventId;
@property (strong, nonatomic) IBOutlet UIImageView *flairImage;
@property (strong, nonatomic) IBOutlet UIView *backgroundCardView;

@end

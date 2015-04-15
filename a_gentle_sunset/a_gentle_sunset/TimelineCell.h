//
//  TimelineCell.h
//  a_gentle_sunset
//
//  Created by csjan on 4/8/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PFTableViewCell.h"

@interface TimelineCell : PFTableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *timeline_image;
@property (strong, nonatomic) IBOutlet UILabel *timeline_elder_name;
@property (strong, nonatomic) IBOutlet UILabel *timeline_content;
@property (strong, nonatomic) IBOutlet UILabel *timeline_author_name;
@property (strong, nonatomic) IBOutlet UILabel *timeline_time;

@end

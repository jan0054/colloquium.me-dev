//
//  PostCellTableViewCell.h
//  KKNN24
//
//  Created by csjan on 5/25/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface PostCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *author_label;
@property (strong, nonatomic) IBOutlet UILabel *time_label;
@property (strong, nonatomic) IBOutlet UILabel *content_label;
@property (strong, nonatomic) IBOutlet PFImageView *timeline_image;

@property (strong, nonatomic) IBOutlet UIView *timeline_background;
@property (strong, nonatomic) IBOutlet UIView *timeline_trim;




@end

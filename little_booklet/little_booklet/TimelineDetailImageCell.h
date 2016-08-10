//
//  TimelineDetailImageCell.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface TimelineDetailImageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *postImage;

@end

//
//  EventCell.h
//  cm_math_one
//
//  Created by csjan on 6/17/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EventCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventOrganizerLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventContentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventSelectedImage;
@property (strong, nonatomic) IBOutlet UIView *backgroundCardView;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;

@property NSString *eventId;
@property PFObject *eventObject;
@property NSString *eventName;
@end

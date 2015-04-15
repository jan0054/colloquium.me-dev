//
//  PostDetailViewController.h
//  a_gentle_sunset
//
//  Created by csjan on 4/8/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface PostDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *comment_table;
@property (strong, nonatomic) IBOutlet PFImageView *post_image;
@property (strong, nonatomic) IBOutlet UILabel *post_elder_name;
@property (strong, nonatomic) IBOutlet UILabel *post_content;
@property (strong, nonatomic) IBOutlet UILabel *post_time;
@property (strong, nonatomic) IBOutlet UILabel *post_author_name;

@property NSString *timeline_content;
@property NSString *timeline_time;
@property NSString *timeline_author;
@property NSString *timeline_elder;
@property PFObject *timeline_post;


@end

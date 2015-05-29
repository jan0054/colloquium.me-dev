//
//  TimelineDetailViewController.h
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>



@interface TimelineDetailViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>
//ui elements
@property (strong, nonatomic) IBOutlet UIView *post_background;
@property (strong, nonatomic) IBOutlet UIView *input_background;
@property (strong, nonatomic) IBOutlet UITableView *comment_table;
@property (strong, nonatomic) IBOutlet UILabel *author_label;
@property (strong, nonatomic) IBOutlet UILabel *time_label;
@property (strong, nonatomic) IBOutlet UIButton *post_comment_button;
- (IBAction)post_comment_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextField *comment_input;
@property (strong, nonatomic) IBOutlet UILabel *content_label;

//ui constraints
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_tabbar_spacing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_screen_spacing;

//data objects
@property PFObject *post;
@property NSString *post_id;
@property NSString *post_content;
@property NSString *post_author_name;
@property NSString *post_time;
@property PFUser *author;
@property UIImage *image;

@end

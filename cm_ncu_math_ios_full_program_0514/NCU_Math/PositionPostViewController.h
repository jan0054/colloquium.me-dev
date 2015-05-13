//
//  PositionPostViewController.h
//  SQuInT2015
//
//  Created by csjan on 2/5/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PositionPostViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>

@property int career_post_type; //0=offer, 1=seek

- (IBAction)confirm_post_button_tap:(UIBarButtonItem *)sender;
- (IBAction)cancel_post_button_tap:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIScrollView *background_scroll_view;

@property (strong, nonatomic) IBOutlet UILabel *contact_name_label;
@property (strong, nonatomic) IBOutlet UILabel *contact_email_label;
@property (strong, nonatomic) IBOutlet UILabel *position_label;
@property (strong, nonatomic) IBOutlet UILabel *institution_label;
@property (strong, nonatomic) IBOutlet UILabel *time_duration_label;
@property (strong, nonatomic) IBOutlet UILabel *description_label;
@property (strong, nonatomic) IBOutlet UILabel *link_label;

@property (weak, nonatomic) IBOutlet UITextField *contact_name_tf;
@property (weak, nonatomic) IBOutlet UITextField *contact_email_tf;
@property (weak, nonatomic) IBOutlet UITextField *position_tf;
@property (weak, nonatomic) IBOutlet UITextField *institution_tf;
@property (weak, nonatomic) IBOutlet UITextField *time_duration_tf;
@property (weak, nonatomic) IBOutlet UITextField *description_tf;
@property (weak, nonatomic) IBOutlet UITextField *link_tf;


@end

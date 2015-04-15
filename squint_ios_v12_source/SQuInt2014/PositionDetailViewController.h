//
//  PositionDetailViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PositionDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *career_position_label;
@property (strong, nonatomic) IBOutlet UILabel *career_institution_label;
@property (strong, nonatomic) IBOutlet UILabel *career_posted_by;
@property NSString *career_objid;
@property (strong, nonatomic) IBOutlet UIView *career_card_view;
@property (strong, nonatomic) IBOutlet UIView *career_trim_view;
@property (strong, nonatomic) IBOutlet UIView *note_card_view;
@property (strong, nonatomic) IBOutlet UIButton *contact_poster_button;
- (IBAction)contact_poster_button_tap:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *career_notes_textfield;

@property (strong, nonatomic) IBOutlet UIButton *link_button;
- (IBAction)link_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *contact_name_label;
@property (strong, nonatomic) IBOutlet UILabel *time_duration_label;
@property (strong, nonatomic) IBOutlet UILabel *career_type_label;


@end

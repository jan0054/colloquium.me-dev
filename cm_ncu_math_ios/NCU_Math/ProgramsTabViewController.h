//
//  ProgramsTabViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface ProgramsTabViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *talkview;
@property (strong, nonatomic) IBOutlet UIView *posterview;
@property (strong, nonatomic) IBOutlet UITableView *postertable;
@property (strong, nonatomic) IBOutlet UITableView *talktable;

@property (strong, nonatomic) IBOutlet UISegmentedControl *programseg;
- (IBAction)segaction:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *talk_day_seg;
- (IBAction)talk_day_seg_action:(UISegmentedControl *)sender;

@property (strong, nonatomic) IBOutlet UIView *abstractview;
@property (strong, nonatomic) IBOutlet UITableView *abstracttable;
@property NSMutableArray *session_array;
@property NSMutableDictionary *session_and_talk;
@property NSMutableArray *poster_array;
@property NSMutableArray *talk_only;
- (IBAction)poster_detail_tap:(UIButton *)sender;
@property NSMutableArray *abstract_array;
- (IBAction)abstract_detail_tap:(UIButton *)sender;
- (IBAction)talk_detail_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *bottom_view;
@property UIRefreshControl *pullrefreshtalk;
@property UIRefreshControl *pullrefreshposter;
@property UIRefreshControl *pullrefreshabstract;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *show_search_button;
@property (strong, nonatomic) IBOutlet UITextField *search_input;
@property (strong, nonatomic) IBOutlet UIButton *do_search_button;
@property (weak, nonatomic) IBOutlet UIButton *cancel_search_button;
- (IBAction)show_search_button_tap:(UIBarButtonItem *)sender;
- (IBAction)do_search_button_tap:(UIButton *)sender;
- (IBAction)cancel_search_button_tap:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *search_view;

@end

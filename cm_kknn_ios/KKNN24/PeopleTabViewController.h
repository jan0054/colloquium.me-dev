//
//  PeopleTabViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SelfCellTableViewCell.h"
#import "PersonCellTableViewCell.h"
#import "EventDetailViewController.h"

@interface PeopleTabViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *peopletable;
- (IBAction)person_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *chat_float;
- (IBAction)chat_float_tap:(UIButton *)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
@property UIRefreshControl *pullrefresh;
@property (weak, nonatomic) IBOutlet UIView *search_view;
@property (weak, nonatomic) IBOutlet UIButton *cancel_search_button;
@property (weak, nonatomic) IBOutlet UIButton *do_search_button;
- (IBAction)cancel_search_button_tap:(UIButton *)sender;
- (IBAction)do_search_button_tap:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *search_input;

@property int from_event;
@property NSMutableArray *person_array;
@property NSString *event_author_id;

//used for passing info when going from person detail straight to chat
@property int fromInitiateChatEvent;
@property NSString *conv_id;
@property int preload_chat_isnewconv;
@property NSMutableArray *chatParticipants;

@end

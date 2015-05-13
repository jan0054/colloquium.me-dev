//
//  ConversationListViewController.h
//  SQuInt2014
//
//  Created by csjan on 10/13/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ConversationListViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back_to_people_button;
- (IBAction)back_to_people_button_tap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *conversation_list_table;

@property NSMutableArray *conversation_array;
@property NSMutableArray *talked_to_array;
@property NSMutableArray *talked_from_array;

@property UIRefreshControl *pullrefresh;

@property int from_preloaded;
@property NSString *preloaded_conv_id;
@property NSString *preloaded_otherguy_objid;
@property PFUser *preloaded_otherguy;
@property NSString *preloaded_otherguy_name;
@property NSString *preloaded_abself;
@property int preloaded_isnewconv;
@property (weak, nonatomic) IBOutlet UILabel *no_conv_label;

@end

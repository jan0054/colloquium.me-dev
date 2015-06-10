//
//  ConversationListViewController.h
//  SQuInt2014
//
//  Created by csjan on 10/13/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//ui
@interface ConversationListViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back_to_people_button;
- (IBAction)back_to_people_button_tap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *conversation_list_table;
@property UIRefreshControl *pullrefresh;
@property (weak, nonatomic) IBOutlet UILabel *no_conv_label;

//data
- (void) processData: (NSArray *)results;

@property NSMutableArray *conversation_array;            //main array holding conversation list
@property int fromPersonDetailChat;                      //=1 if coming from tapping chat in person detail view
@property PFObject *preloadedConversation;               //preloaded conversation object from person detail view
@property NSMutableArray *preloadedChatParticipants;     //participant list to pass on to chat

@end

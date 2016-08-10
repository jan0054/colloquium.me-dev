//
//  ConversationView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *conversationTable;
- (void)processData: (NSArray *) results;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addConvButton;
- (IBAction)addConvButtonTap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UILabel *noConvLabel;
@property UIRefreshControl *pullrefresh;
@end

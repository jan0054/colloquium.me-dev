//
//  ProgramForumView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProgramForumView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *forumTable;
@property (strong, nonatomic) IBOutlet UIView *inputBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)refreshButtonTap:(UIBarButtonItem *)sender;

- (void)processData: (NSArray *) results;
- (void)postForumSuccessCallback;

@property PFObject *program;

@end

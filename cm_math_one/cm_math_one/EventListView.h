//
//  EventListView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *eventTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)doneButtonTap:(UIBarButtonItem *)sender;
- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender;
@property UIRefreshControl *pullrefresh;

- (void)processData: (NSArray *) results;

- (IBAction)instructionTap:(UITapGestureRecognizer *)sender;  //used to dismiss the instruction view
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapOutlet;

@end

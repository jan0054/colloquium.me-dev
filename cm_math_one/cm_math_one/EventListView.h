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
- (void)processData: (NSArray *) results;


@end

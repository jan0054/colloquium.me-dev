//
//  TimelineView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *timelineTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addPostButton;
- (IBAction)addPostButtonTap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UILabel *noPostLabel;
- (void)processData: (NSArray *) results;
@property UIRefreshControl *pullrefresh;
@end

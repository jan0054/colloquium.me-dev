//
//  ProgramView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YALContextMenuTableView.h"

@interface ProgramView : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, YALContextMenuTableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *searchInput;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *programTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterButton;
- (IBAction)filterButtonTap:(UIBarButtonItem *)sender;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;
@property (nonatomic, strong) NSMutableArray *menuTitles;

- (void)processData: (NSArray *) results;
- (void)processSessions: (NSArray *) results;
@property UIRefreshControl *pullrefresh;

@end

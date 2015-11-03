//
//  ProgramView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramView : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *searchInput;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *programTable;

- (void)processData: (NSArray *) results;
@property UIRefreshControl *pullrefresh;
@end

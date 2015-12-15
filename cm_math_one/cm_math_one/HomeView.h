//
//  HomeView.h
//  cm_math_one
//
//  Created by csjan on 7/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *homeTable;
- (void)processData: (NSArray *) results;
@property UIRefreshControl *pullrefresh;
@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;
- (IBAction)addEventButtonTap:(UIButton *)sender;

@end

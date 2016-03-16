//
//  StreamListView.h
//  cm_math_one
//
//  Created by csjan on 3/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamListView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *topBarBackground;
@property (strong, nonatomic) IBOutlet UIButton *openChannelButton;
- (IBAction)openChannelButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *streamTable;
@property (strong, nonatomic) IBOutlet UILabel *empty_label;
@property UIRefreshControl *pullrefresh;
@end

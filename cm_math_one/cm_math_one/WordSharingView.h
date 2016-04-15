//
//  WordSharingView.h
//  cm_math_one
//
//  Created by csjan on 4/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordSharingView : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *sharingToggle;
- (IBAction)sharingToggleChanged:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UIView *receiveBackgroundView;
@property (strong, nonatomic) IBOutlet UITableView *resultsTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;
- (IBAction)shareActionButtonTap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UIView *segBackgroundView;

@end

//
//  AttendeeView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendeeView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *searchInput;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *attendeeTable;
- (IBAction)searchButtonTap:(UIButton *)sender;
- (void)processData: (NSArray *) results;

@end

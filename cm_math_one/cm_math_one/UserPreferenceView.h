//
//  UserPreferenceView.h
//  cm_math_one
//
//  Created by csjan on 6/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPreferenceView : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *preferenceTable;
- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender;
- (IBAction)switchChanged:(UISwitch *)sender;
- (IBAction)saveButtonTap:(UIBarButtonItem *)sender;

@end

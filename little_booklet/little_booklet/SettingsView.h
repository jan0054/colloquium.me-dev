//
//  SettingsView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIViewController

- (IBAction)userButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *settingTable;

@end

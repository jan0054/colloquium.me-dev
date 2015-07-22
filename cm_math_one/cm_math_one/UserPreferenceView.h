//
//  UserPreferenceView.h
//  cm_math_one
//
//  Created by csjan on 6/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol delegateProtocol <NSObject>
-(void)prefDone;
@end

@interface UserPreferenceView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *preferenceTable;
- (IBAction)switchChanged:(UISwitch *)sender;
- (IBAction)saveButtonTap:(UIBarButtonItem *)sender;
@property id data_delegate;
@end

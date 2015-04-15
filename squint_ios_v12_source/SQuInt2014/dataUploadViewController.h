//
//  dataUploadViewController.h
//  SQuInT2015
//
//  Created by csjan on 1/22/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dataUploadViewController : UIViewController
- (IBAction)process:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *status_label;

@end

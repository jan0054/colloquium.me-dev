//
//  AboutUsView.h
//  cm_math_one
//
//  Created by csjan on 7/7/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsView : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *contactButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)contactButtonTap:(UIButton *)sender;
- (IBAction)doneButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

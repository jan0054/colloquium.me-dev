//
//  AboutAppViewController.h
//  Little Booklet
//
//  Created by Chi-sheng Jan on 8/12/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutAppViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)contactButtonTap:(UIButton *)sender;
- (IBAction)doneButtonTap:(UIButton *)sender;
@end

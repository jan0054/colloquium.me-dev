//
//  CareerDetailTableViewController.h
//  cm_math_one
//
//  Created by csjan on 8/6/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CareerDetailTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *institutionLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UILabel *linkLabel;
@property (strong, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

- (IBAction)contactButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *linkButton;
- (IBAction)linkButtonTap:(UIButton *)sender;

@property PFObject *currentCareer;

@end

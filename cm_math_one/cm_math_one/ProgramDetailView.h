//
//  ProgramDetailView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProgramDetailView : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *sessionLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIView *barBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *discussButton;
@property (strong, nonatomic) IBOutlet UIView *mainBackgroundView;

- (IBAction)discussButtonTap:(UIBarButtonItem *)sender;

@property PFObject *program;

@end

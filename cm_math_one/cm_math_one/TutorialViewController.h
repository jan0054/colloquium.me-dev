//
//  TutorialViewController.h
//  cm_math_one
//
//  Created by csjan on 12/9/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchView.h"

@protocol tutorialDelegateProtocol <NSObject>
-(void)tutorialDone;
@end

@interface TutorialViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageContent;
- (IBAction)exitButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *exitButton;

@property BOOL signupAfter;
@property id data_delegate;

@end

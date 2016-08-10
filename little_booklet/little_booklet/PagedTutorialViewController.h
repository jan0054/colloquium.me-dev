//
//  PagedTutorialViewController.h
//  cm_math_one
//
//  Created by csjan on 12/9/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagedTutorialViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *tutorialImageView;

@property NSString *imageName;
@property NSString *titleText;
@property NSString *contentText;

@property int pageIndex;
@property (strong, nonatomic) IBOutlet UIView *lowerBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end

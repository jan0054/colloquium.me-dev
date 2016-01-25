//
//  PagedTutorialViewController.m
//  cm_math_one
//
//  Created by csjan on 12/9/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import "PagedTutorialViewController.h"
#import "UIColor+ProjectColors.h"

@implementation PagedTutorialViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lowerBackgroundView.backgroundColor = [UIColor whiteColor];
    self.tutorialImageView.backgroundColor = [UIColor light_grey_background];
    self.view.backgroundColor = [UIColor light_bg];
    self.tutorialImageView.image = [UIImage imageNamed:self.imageName];
    self.titleLabel.text = self.titleText;
    self.contentLabel.text = self.contentText;
}
@end

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
@property int pageIndex;

@end

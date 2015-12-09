//
//  TutorialViewController.m
//  cm_math_one
//
//  Created by csjan on 12/9/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import "TutorialViewController.h"
#import "PagedTutorialViewController.h"
#import "UIColor+ProjectColors.h"

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.exitButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.exitButton setTitleColor:[UIColor dark_accent] forState:UIControlStateHighlighted];
    
    _pageImages = @[@"tut_picker.jpg", @"tut_home.jpg", @"tut_overview.jpg", @"tut_drawer.jpg", @"tut_program.jpg"];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorialpvc"];
    self.pageViewController.dataSource = self;
    
    PagedTutorialViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PagedTutorialViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PagedTutorialViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (PagedTutorialViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    PagedTutorialViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorialpage"];
    controller.imageName = self.pageImages[index];
    controller.pageIndex = index;
    
    return controller;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)exitButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

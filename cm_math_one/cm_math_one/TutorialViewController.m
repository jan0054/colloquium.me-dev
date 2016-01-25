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
#import "LoginView.h"
#import "SignUpView.h"

int currentPage;

@implementation TutorialViewController
@synthesize signupAfter;
@synthesize tutDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.exitButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.exitButton setTitleColor:[UIColor dark_accent] forState:UIControlStateHighlighted];
    
    [self.exitButton setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateNormal];
    [self.exitButton setTitle:NSLocalizedString(@"done", nil) forState:UIControlStateHighlighted];
    
    self.exitButton.hidden = YES;
    self.exitButton.userInteractionEnabled = NO;
    
    _pageImages = @[@"tut_choose_event", @"tut_home", @"tut_drawer", @"tut_overview"];
    _pageTitles = @[NSLocalizedString(@"choose_event_title", nil), NSLocalizedString(@"home_title", nil), NSLocalizedString(@"drawer_title", nil), NSLocalizedString(@"overview_title", nil)];
    _pageContent = @[NSLocalizedString(@"choose_event_content", nil), NSLocalizedString(@"home_content", nil), NSLocalizedString(@"drawer_content", nil), NSLocalizedString(@"overview_content", nil)];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorialpvc"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    PagedTutorialViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (IBAction)exitButtonTap:(UIButton *)sender {
    //set "already setup" flag
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"chooseeventsetup"];
    [defaults synchronize];
    
    if (signupAfter)
    {
        [tutDelegate tutDone];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Page View Controller Data Source & Delegate

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
    controller.titleText = self.pageTitles[index];
    controller.contentText = self.pageContent[index];
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


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSLog(@"PAGE FLIP");
    if (completed)
    {
        PagedTutorialViewController *controller =  pageViewController.viewControllers[0];
        currentPage = controller.pageIndex;
        NSLog(@"PAGE:%i", currentPage);
        if (currentPage == [self.pageImages count]-1)
        {
            self.exitButton.hidden = NO;
            self.exitButton.userInteractionEnabled = YES;
        }
        else
        {
            self.exitButton.hidden = YES;
            self.exitButton.userInteractionEnabled = NO;
        }
    }
}

@end

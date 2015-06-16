//
//  LaunchView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "LaunchView.h"
#import "MMDrawerController.h"

@implementation LaunchView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSegueWithIdentifier:@"drawersegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"drawersegue"]) {
        MMDrawerController *destinationViewController = (MMDrawerController *) segue.destinationViewController;
        
        // Instantitate and set the center view controller.
        UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
        [destinationViewController setCenterViewController:centerViewController];
        
        // Instantiate and set the left drawer controller.
        UIViewController *leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"drawer_nc"];
        [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
        
        [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
        [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];
        [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView];
        [destinationViewController setMaximumLeftDrawerWidth:160.0];
    }
}

@end

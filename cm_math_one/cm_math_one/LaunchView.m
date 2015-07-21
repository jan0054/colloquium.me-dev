//
//  LaunchView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "LaunchView.h"
#import "MMDrawerController.h"
#import "LoginView.h"
#import "SignUpView.h"
#import "UserPreferenceView.h"

BOOL waitForPreference;  //used to pause launching the drawersegue to wait for the user preference view

@implementation LaunchView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![PFUser currentUser])
    {
        // Customize the Log In View Controller
        LoginView *logInViewController = [[LoginView alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword ];
        
        // Create the sign up view controller
        SignUpView *signUpViewController = [[SignUpView alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        signUpViewController.emailAsUsername = YES;
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    else
    {
        [self performSegueWithIdentifier:@"drawersegue" sender:self];
        NSLog(@"Drawer segue from viewdidload");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!waitForPreference)
    {
        [self performSegueWithIdentifier:@"drawersegue" sender:self];
    }
    else
    {
        waitForPreference = NO;
    }
    NSLog(@"Drawer segue from viewdidappear");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"drawersegue"]) {
        MMDrawerController *destinationViewController = (MMDrawerController *) segue.destinationViewController;
        
        // Instantitate and set the center view controller. (i.e. the default first view shown) depending on if there are events already chosen
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *eventNames = [defaults objectForKey:@"eventNames"];
        if (eventNames.count >=1)  //already exist previously selected events, show the tab controller
        {
            UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
            [destinationViewController setCenterViewController:centerViewController];
        }
        else  //no existing selected events, show the event picker
        {
            UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
            [destinationViewController setCenterViewController:centerViewController];
        }
        
        // Instantiate and set the left drawer controller. (the drawer view)
        UIViewController *leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"drawer_vc"];
        [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
        
        [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
        [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];
        [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView];
        [destinationViewController setMaximumLeftDrawerWidth:160.0];
        destinationViewController.shouldStretchDrawer = NO;
    }
}

#pragma mark - User Management

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Please fill in all fields."
                               delegate:nil
                      cancelButtonTitle:@"Done"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    [self completeOnboarding];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later from the Settings screen"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
    
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please fill in all fields."
                                   delegate:nil
                          cancelButtonTitle:@"Done"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self completeOnboarding];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up with error: %@", error);
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void) completeOnboarding
{
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    NSLog(@"User associcated with Installation: %@ to %@",[PFUser currentUser].objectId, installation.objectId);
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UserPreferenceView *controller = (UserPreferenceView *)[storyboard instantiateViewControllerWithIdentifier:@"userpreferenceview"];
    //[self presentViewController:controller animated:YES completion:nil];
    waitForPreference = YES;
    
    // Dismiss the PFSignUpViewController
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"sign up / login controller dismissed");
        //pop up the user preference controller to setup stuff
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserPreferenceView *controller = (UserPreferenceView *)[storyboard instantiateViewControllerWithIdentifier:@"userpreferenceview"];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

@end

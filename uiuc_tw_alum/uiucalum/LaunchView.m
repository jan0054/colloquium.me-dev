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
#import "UIViewController+ParseQueries.h"
#import "MMDrawerVisualState.h"
#import "TutorialViewController.h"

BOOL waitForPreference;  //used to pause launching the drawersegue to wait for the user preference view or the signup/login view (i.e. don't load drawer yet)

@implementation LaunchView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL alreadySetup = [defaults boolForKey:@"chooseeventsetup"];
    if (!alreadySetup)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TutorialViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"tutorialcontroller"];
        controller.signupAfter = YES;
        controller.tutDelegate = self;
        [self presentViewController:controller animated:NO completion:nil];
    }

    if (![PFUser currentUser])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int skiplogin = [[defaults valueForKey:@"skiplogin"] intValue];
        if (skiplogin == 1)
        {
            [self performSegueWithIdentifier:@"drawersegue" sender:self];
            NSLog(@"Drawer segue from viewdidload(skip login");
        }
        else
        {
            // Customize the Log In View Controller
            LoginView *logInViewController = [[LoginView alloc] init];
            [logInViewController setDelegate:self];
            [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook];
            
            // Create the sign up view controller
            SignUpView *signUpViewController = [[SignUpView alloc] init];
            [signUpViewController setDelegate:self]; // Set ourselves as the delegate
            signUpViewController.emailAsUsername = YES;
            // Assign our sign up controller to be displayed from the login controller
            [logInViewController setSignUpController:signUpViewController];
            
            // Present the log in view controller
            [self presentViewController:logInViewController animated:YES completion:NULL];
        }
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
        NSLog(@"Drawer segue from viewdidappear");
    }
    else
    {
        waitForPreference = NO;
        NSLog(@"Drawer segue waiting on preference");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"drawersegue"]) {
        MMDrawerController *destinationViewController = (MMDrawerController *) segue.destinationViewController;
        
        // Instantitate and set the center view controller. (i.e. the default first view shown) depending on if there are events already chosen
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *eventNames = [defaults objectForKey:@"eventNames"];
        if (eventNames.count >=1)  //already exist previously selected events, show the tab controller (update: we go to the event picker anyway since we're deprecating the home view)
        {
            //UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
            UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
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
        [destinationViewController setMaximumLeftDrawerWidth:200.0];
        [destinationViewController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:3.0]];
        destinationViewController.shouldStretchDrawer = NO;
    }
}

#pragma mark - User Management

- (void)goToLogin
{
    if (![PFUser currentUser])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int skiplogin = [[defaults valueForKey:@"skiplogin"] intValue];
        if (skiplogin == 1)
        {
        
        }
        else
        {
            // Customize the Log In View Controller
            LoginView *logInViewController = [[LoginView alloc] init];
            [logInViewController setDelegate:self];
            [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook];
            
            // Create the sign up view controller
            SignUpView *signUpViewController = [[SignUpView alloc] init];
            [signUpViewController setDelegate:self]; // Set ourselves as the delegate
            signUpViewController.emailAsUsername = YES;
            // Assign our sign up controller to be displayed from the login controller
            [logInViewController setSignUpController:signUpViewController];
            
            // Present the log in view controller
            [self presentViewController:logInViewController animated:YES completion:NULL];
        }
    }

}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                message:NSLocalizedString(@"alert_please_fill", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self writeUserPreferenceToLocal:self forUser:user];
    [self completeOnboarding];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in with error %@", error);
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                message:error.userInfo[@"error"]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                      otherButtonTitles:nil] show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.navigationController popViewControllerAnimated:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@1 forKey:@"skiplogin"];
    [defaults synchronize];
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later from the Settings screen"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
     */
    [self performSelector:@selector(doDrawer) withObject:nil afterDelay:0.1];
}

- (void)doDrawer
{
    [self performSegueWithIdentifier:@"drawersegue" sender:self];
    NSLog(@"Drawer segue from dismiss");
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                    message:NSLocalizedString(@"alert_please_fill", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                message:error.userInfo[@"error"]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                      otherButtonTitles:nil] show];
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

    waitForPreference = YES;
    
    // Dismiss the PFSignUpViewController
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"sign up / login controller dismissed");
        
        //pop up the user preference controller to setup stuff
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //UserPreferenceView *controller = (UserPreferenceView *)[storyboard instantiateViewControllerWithIdentifier:@"userpreferenceview"];
        UINavigationController *controller = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"preference_nc"];
        UserPreferenceView *prefController =  controller.viewControllers[0];
        prefController.data_delegate = self;
        [self presentViewController:controller animated:NO completion:nil];
    }];
}

- (void)prefDone
{
    [self performSelector:@selector(doDrawer) withObject:nil afterDelay:0.1];
}

- (void)tutDone
{
    NSLog(@"TUTORIAL DELEGATE CALLED");
    waitForPreference = YES;
    [self performSelector:@selector(goToLogin) withObject:nil afterDelay:0.1];  //this weird delay thing is required...
}

@end

//
//  SettingsView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "SettingsView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "SettingUserCell.h"
#import "SettingGenericCell.h"
#import "LoginView.h"
#import "SignUpView.h"
#import "UserPreferenceView.h"
#import "InstructionsViewController.h"
#import "PasswordResetView.h"
#import "TutorialViewController.h"

@implementation SettingsView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    
    //styling
    self.settingTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.layer.shadowColor = [UIColor dark_primary].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
}

- (void)viewDidLayoutSubviews
{
    if ([self.settingTable respondsToSelector:@selector(layoutMargins)]) {
        self.settingTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.settingTable reloadData];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)userButtonTap:(UIButton *)sender
{
    if (![PFUser currentUser])
    {
        [self log_in];
    }
    else
    {
        [self log_out];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![PFUser currentUser])
    {
        return 5;
    }
    else
    {
        //add a user preference row
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingUserCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"settingusercell"];
    SettingGenericCell *genericCell = [tableView dequeueReusableCellWithIdentifier:@"settinggenericcell"];
    if ([userCell respondsToSelector:@selector(layoutMargins)]) {
        userCell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([genericCell respondsToSelector:@selector(layoutMargins)]) {
        genericCell.layoutMargins = UIEdgeInsetsZero;
    }
    userCell.secondaryLabel.textColor = [UIColor dark_primary];
    genericCell.secondaryLabel.textColor = [UIColor dark_primary];
    
    //user account management
    NSString *userStatus = @"";
    NSString *secondaryStatus = @"";
    NSString *statusButton = @"";
    if ([PFUser currentUser])
    {
        PFUser *user = [PFUser currentUser];
        NSString *signAs = NSLocalizedString(@"sign_as", nil);
        userStatus = [NSString stringWithFormat:@"%@ %@ %@", signAs,  user[@"first_name"], user[@"last_name"]];
        secondaryStatus = NSLocalizedString(@"sign_out_switch", nil);
        statusButton = NSLocalizedString(@"sign_out", nil);
    }
    else
    {
        userStatus = NSLocalizedString(@"no_sign_yet", nil);
        secondaryStatus = NSLocalizedString(@"sign_in_detail", nil);
        statusButton = NSLocalizedString(@"sign_in", nil);
    }
    
    switch (indexPath.row) {
        case 0:
            userCell.primaryLabel.text = userStatus;
            userCell.secondaryLabel.text = secondaryStatus;
            [userCell.userButton setTitle:statusButton forState:UIControlStateNormal];
            userCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [userCell.userButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
            return userCell;
            break;
        case 1:
            genericCell.primaryLabel.text = NSLocalizedString(@"feedback_title", nil);
            genericCell.secondaryLabel.text = NSLocalizedString(@"feedback_sub", nil);
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 2:
            genericCell.primaryLabel.text = NSLocalizedString(@"admin_title", nil);
            genericCell.secondaryLabel.text = NSLocalizedString(@"admin_sub", nil);
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 3:
            genericCell.primaryLabel.text = NSLocalizedString(@"privacy_title", nil);
            genericCell.secondaryLabel.text = NSLocalizedString(@"privacy_sub", nil);
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 4:
            genericCell.primaryLabel.text = NSLocalizedString(@"about_title", nil);
            genericCell.secondaryLabel.text = NSLocalizedString(@"about_sub", nil);
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 5:
            genericCell.primaryLabel.text = NSLocalizedString(@"pref_title", nil);
            genericCell.secondaryLabel.text = NSLocalizedString(@"pref_sub", nil);
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        default:
            return genericCell;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserPreferenceView *controller = (UserPreferenceView *)[storyboard instantiateViewControllerWithIdentifier:@"userpreferenceview"];
    TutorialViewController *controller2 = [storyboard instantiateViewControllerWithIdentifier:@"tutorialcontroller"];
    //PasswordResetView *controller = (PasswordResetView *)[storyboard instantiateViewControllerWithIdentifier:@"reset_vc"];
    
    switch (indexPath.row) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@colloquium.me"]];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@colloquium.me"]];
            break;
        case 3:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://colloquium.me/?page_id=3348"]];
            break;
        case 4:
            //[self performSegueWithIdentifier:@"aboutsegue" sender:self];
            [self presentViewController:controller2 animated:YES completion:nil];
            break;
        case 5:
            [self presentViewController:controller animated:YES completion:nil];
            break;
        default:
            break;
    }
}


#pragma mark - User Management

-(void) log_out
{
    [PFUser logOut];
    // DIS-Associate the device with logged out user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION DIS-ASSOCIATED: %@", installation.objectId);
    [self removeLocalStorage];
    [self.settingTable reloadData];
}

-(void) log_in
{
    if (![PFUser currentUser])
    {
        // Customize the Log In View Controller
        LoginView *logInViewController = [[LoginView alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook];
        
        // Create the sign up view controller
        SignUpView *signUpViewController = [[SignUpView alloc] init];
        signUpViewController.emailAsUsername = YES;
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
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
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"alert_sign_later", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
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

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

@implementation SettingsView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    self.settingTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    
    //user account management
    NSString *userStatus = @"";
    NSString *secondaryStatus = @"";
    NSString *statusButton = @"";
    if ([PFUser currentUser])
    {
        PFUser *user = [PFUser currentUser];
        userStatus = [NSString stringWithFormat:@"Signed in as %@ %@", user[@"first_name"], user[@"last_name"]];
        secondaryStatus = @"Sign out to switch users";
        statusButton = @"Sign Out";
    }
    else
    {
        userStatus = @"Not signed in yet";
        secondaryStatus = @"Sign in to access social features";
        statusButton = @"Sign In";
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
            genericCell.primaryLabel.text = @"App Feedback";
            genericCell.secondaryLabel.text = @"Email us with app questions or feedback";
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 2:
            genericCell.primaryLabel.text = @"Administrative Assistance";
            genericCell.secondaryLabel.text = @"Email event organizers with event questions";
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 3:
            genericCell.primaryLabel.text = @"Privacy & Terms";
            genericCell.secondaryLabel.text = @"Info on how we protect and secure your data";
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 4:
            genericCell.primaryLabel.text = @"About Us";
            genericCell.secondaryLabel.text = @"Learn about the developers of this app";
            genericCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return genericCell;
            break;
        case 5:
            genericCell.primaryLabel.text = @"User Preferences";
            genericCell.secondaryLabel.text = @"Setup or change user info and social options";
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
    
    switch (indexPath.row) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
            break;
        case 2:
            //to-do: add view to choose event admins?
            break;
        case 3:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://colloquium.me/?page_id=3348"]];
            break;
        case 4:
            [self performSegueWithIdentifier:@"aboutsegue" sender:self];
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
        [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword ];
        
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
    
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Please fill in all fields."
                               delegate:nil
                      cancelButtonTitle:@"Done"
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
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later under Settings"
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

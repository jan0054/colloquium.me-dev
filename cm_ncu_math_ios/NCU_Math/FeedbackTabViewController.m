//
//  FeedbackTabViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "FeedbackTabViewController.h"
#import "UIColor+ProjectColors.h"
#import "UserOptionsViewController.h"

@interface FeedbackTabViewController ()

@end


@implementation FeedbackTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settingstable.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.settingstable.tableFooterView = [[UIView alloc] init];
    self.settingstable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor dark_primary];
    [self.settingstable setSeparatorColor:[UIColor divider_color]];
    
}

- (void) viewDidLayoutSubviews
{

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.settingstable reloadData];
}

-(void) log_out
{
    //turn off notifications (push)  ***currently not in use
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"notifications"];
    [defaults synchronize];
    
    [PFUser logOut];
    
    // DIS-Associate the device with logged out user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION DIS-ASSOCIATED: %@", installation.objectId);

}

-(void) log_in
{
    if (![PFUser currentUser])
    {
        // Customize the Log In View Controller
        CustomLogInViewController *logInViewController = [[CustomLogInViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword ];
        
        // Create the sign up view controller
        CustomSignUpViewController *signUpViewController = [[CustomSignUpViewController alloc] init];
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
    
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION ASSOCIATED: %@ to %@",[PFUser currentUser].objectId, installation.objectId);
    
    //turn on notifications (push)  ***not used in current ver
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"notifications"];
    [defaults synchronize];
    
    [self.settingstable reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later from the settings tab"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
     */
    
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
    
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION ASSOCIATED");
    
    //turn on notifications (push)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"notifications"];
    [defaults synchronize];
    
    [self.settingstable reloadData];
    // Dismiss the PFSignUpViewController
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"sign up controller dismissed");
        //pop up the user options controller to set chat/email settings
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserOptionsViewController *controller = (UserOptionsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"usersetupview"];
        controller.isnew = 1;
        [self presentViewController:controller animated:YES completion:nil];

    }];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

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
        return 6;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingLoginCellTableViewCell *logincell = [tableView dequeueReusableCellWithIdentifier:@"logincell"];
    SettingPushCellTableViewCell *pushcell = [tableView dequeueReusableCellWithIdentifier:@"pushcell"];
    GeneralSettingCellTableViewCell *generalsettingcell = [tableView dequeueReusableCellWithIdentifier:@"generalsettingcell"];
    UserPreferenceTableViewCell *preferencecell = [tableView dequeueReusableCellWithIdentifier:@"preferencecell"];
    
    if (indexPath.row==0)
    {
        [logincell.login_action_button setTitle:@"Log In" forState:UIControlStateNormal];
        [logincell.login_action_button setTitle:@"Log In" forState:UIControlStateHighlighted];
        NSString *name = @"Not logged in";
        
        if ([PFUser currentUser])
        {
            PFUser *cur = [PFUser currentUser];
            name = [NSString stringWithFormat:@"Logged in as %@", cur.username];
            
            [logincell.login_action_button setTitle:@"Log Out" forState:UIControlStateNormal];
            [logincell.login_action_button setTitle:@"Log Out" forState:UIControlStateHighlighted];
            logincell.login_subtitle_label.textColor=[UIColor whiteColor];
            logincell.login_subtitle_label.text = @"Log out to switch users";

        }
        else
        {
            logincell.login_subtitle_label.textColor=[UIColor whiteColor];
            logincell.login_subtitle_label.text = @"Log in to message users";
        }
        
        [logincell.login_action_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
        [logincell.login_action_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
        logincell.login_name_label.text = name;
        logincell.selectionStyle = UITableViewCellSelectionStyleNone;
        logincell.backgroundColor = [UIColor clearColor];
        logincell.login_name_label.textColor = [UIColor whiteColor];
        if ([logincell respondsToSelector:@selector(layoutMargins)]) {
            logincell.layoutMargins = UIEdgeInsetsZero;
        }
        return logincell;
    }
    
    else if (indexPath.row==1)
    {
        generalsettingcell.general_name_label.text = @"App Feedback";
        generalsettingcell.general_name_label.textColor = [UIColor whiteColor];
        generalsettingcell.backgroundColor = [UIColor clearColor];
        if ([generalsettingcell respondsToSelector:@selector(layoutMargins)]) {
            generalsettingcell.layoutMargins = UIEdgeInsetsZero;
        }
        generalsettingcell.general_subtitle_label.textColor=[UIColor whiteColor];
        generalsettingcell.general_subtitle_label.text=@"Email event organizers with app questions or feedback";
        generalsettingcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return generalsettingcell;
    }
    
    else if (indexPath.row==2)
    {
        generalsettingcell.general_name_label.text = @"Administrative Assistance";
        generalsettingcell.general_name_label.textColor = [UIColor whiteColor];
        generalsettingcell.backgroundColor = [UIColor clearColor];
        if ([generalsettingcell respondsToSelector:@selector(layoutMargins)]) {
            generalsettingcell.layoutMargins = UIEdgeInsetsZero;
        }
        generalsettingcell.general_subtitle_label.textColor=[UIColor whiteColor];
        generalsettingcell.general_subtitle_label.text=@"Email event organizers for administrative assistance";
        generalsettingcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return generalsettingcell;
    }

    else if (indexPath.row == 3)
    {
        generalsettingcell.general_name_label.text = @"Privacy & Terms";
        generalsettingcell.general_name_label.textColor = [UIColor whiteColor];
        generalsettingcell.backgroundColor = [UIColor clearColor];
        if ([generalsettingcell respondsToSelector:@selector(layoutMargins)]) {
            generalsettingcell.layoutMargins = UIEdgeInsetsZero;
        }
        generalsettingcell.general_subtitle_label.textColor=[UIColor whiteColor];
        generalsettingcell.general_subtitle_label.text=@"Info on how we protect and secure your data";
        generalsettingcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return generalsettingcell;
    }
    
    else if (indexPath.row== 4)
    {
        generalsettingcell.general_name_label.text = @"About Us";
        generalsettingcell.general_name_label.textColor = [UIColor whiteColor];
        generalsettingcell.backgroundColor = [UIColor clearColor];
        if ([generalsettingcell respondsToSelector:@selector(layoutMargins)]) {
            generalsettingcell.layoutMargins = UIEdgeInsetsZero;
        }
        generalsettingcell.general_subtitle_label.textColor=[UIColor whiteColor];
        generalsettingcell.general_subtitle_label.text=@"Info about the developers of this app";
        generalsettingcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return generalsettingcell;
    }

    else
    {
        preferencecell.preference_main_label.text = @"Preferences";
        preferencecell.preference_subtitle_label.text = @"Set chat and email preferences";
        preferencecell.backgroundColor = [UIColor clearColor];
        preferencecell.preference_main_label.textColor = [UIColor whiteColor];
        preferencecell.preference_subtitle_label.textColor = [UIColor whiteColor];
        [preferencecell.preference_change_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
        [preferencecell.preference_change_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
        preferencecell.selectionStyle = UITableViewCellSelectionStyleNone;
        return preferencecell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==4)
    {
        [self performSegueWithIdentifier:@"aboutsegue" sender:self];
    }
    else if (indexPath.row ==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
    }
    else if (indexPath.row ==2)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
    }
    else if (indexPath.row==3)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tapgo.cc/tw/?page_id=1145"]];
    }
}

- (IBAction)login_button_tap:(UIButton *)sender {
    if (![PFUser currentUser])
    {
        [self log_in];
    }
    else
    {
        [self log_out];
        [self.settingstable reloadData];
    }
}

- (IBAction)preference_change_button_tap:(UIButton *)sender {
    //pop up the user options controller to set chat/email settings
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserOptionsViewController *controller = (UserOptionsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"usersetupview"];
    controller.isnew = 0;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
    
}

- (IBAction)notification_switch_action:(UISwitch *)sender {
    
}

@end
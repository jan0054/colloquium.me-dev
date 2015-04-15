//
//  SettingsTableViewController.m
//  a_gentle_sunset
//
//  Created by csjan on 3/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "CustomLogInViewController.h"
#import "CustomSignUpViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    self.tableView.allowsSelection = NO;
    
    if ([PFUser currentUser])
    {
        [self.login_button setTitle:@"登出" forState:UIControlStateNormal];
        [self.login_button setTitle:@"登出" forState:UIControlStateHighlighted];
    }
    else
    {
        [self.login_button setTitle:@"登入" forState:UIControlStateNormal];
        [self.login_button setTitle:@"登入" forState:UIControlStateHighlighted];
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)push_button_tap:(UIButton *)sender {
    
}

- (IBAction)login_button_tap:(UIButton *)sender {
    if ([PFUser currentUser])
    {
        [self log_out];
    }
    else
    {
        [self log_in];
    }
}

- (void) log_in {
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

- (void) log_out {
    [PFUser logOut];
    
    [self.login_button setTitle:@"登入" forState:UIControlStateNormal];
    [self.login_button setTitle:@"登入" forState:UIControlStateHighlighted];
    
    // DIS-Associate the device with logged out user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION DIS-ASSOCIATED: %@", installation.objectId);
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"錯誤"
                                message:@"請填寫所有欄位"
                               delegate:nil
                      cancelButtonTitle:@"確定"
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"log in controller dismissed");
        [self.login_button setTitle:@"登出" forState:UIControlStateNormal];
        [self.login_button setTitle:@"登出" forState:UIControlStateHighlighted];
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"本App需登入方可正常使用"
                                                   delegate:self
                                          cancelButtonTitle:@"確定"
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
        [[[UIAlertView alloc] initWithTitle:@"錯誤"
                                    message:@"請填寫所有欄位"
                                   delegate:nil
                          cancelButtonTitle:@"確定"
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
    
    // Dismiss the PFSignUpViewController
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"sign up controller dismissed");
        [self.login_button setTitle:@"登出" forState:UIControlStateNormal];
        [self.login_button setTitle:@"登出" forState:UIControlStateHighlighted];
    }];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end

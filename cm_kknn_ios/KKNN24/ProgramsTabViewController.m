//
//  ProgramsTabViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "ProgramsTabViewController.h"
#import "CustomLogInViewController.h"
#import "CustomSignUpViewController.h"
#import "PosterCellTableViewCell.h"
#import "TalkCellTableViewCell.h"
#import "AbstractCellTableViewCell.h"
#import "UIColor+ProjectColors.h"
#import "EventDetailViewController.h"
#import "AbstractPdfViewController.h"
#import "AppDelegate.h"
#import "UserOptionsViewController.h"
#import "UIImage+ImageTint.h"

@interface ProgramsTabViewController ()

@end

int detail_type; //talk=0, poster=1, abstract=2
NSString *detail_objid;
int unread_total;
NSString *search_str;
BOOL search_on;
NSMutableArray *search_array;

@implementation ProgramsTabViewController
@synthesize session_array;
@synthesize poster_array;
@synthesize session_and_talk;
@synthesize abstract_array;
@synthesize pullrefreshtalk;
@synthesize pullrefreshposter;
@synthesize pullrefreshabstract;
@synthesize talk_only;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //initialize elements
    self.session_array = [[NSMutableArray alloc] init];
    self.poster_array = [[NSMutableArray alloc] init];
    self.abstract_array = [[NSMutableArray alloc] init];
    self.session_and_talk = [[NSMutableDictionary alloc] init];
    self.talk_only = [[NSMutableArray alloc] init];
    self.talktable.tableFooterView = [[UIView alloc] init];
    self.postertable.tableFooterView = [[UIView alloc] init];
    self.abstracttable.tableFooterView = [[UIView alloc] init];
    search_array = [[NSMutableArray alloc] init];
    self.search_input.delegate = self;
    self.no_attachment_label.hidden = YES;
    self.no_poster_label.hidden = YES;
    
    //Pull To Refresh Controls
    self.pullrefreshtalk = [[UIRefreshControl alloc] init];
    [pullrefreshtalk addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.talktable addSubview:pullrefreshtalk];
    self.pullrefreshposter = [[UIRefreshControl alloc] init];
    [pullrefreshposter addTarget:self action:@selector(refreshctrl_p:) forControlEvents:UIControlEventValueChanged];
    [self.postertable addSubview:pullrefreshposter];
    self.pullrefreshabstract = [[UIRefreshControl alloc] init];
    [pullrefreshabstract addTarget:self action:@selector(refreshctrl_a:) forControlEvents:UIControlEventValueChanged];
    [self.abstracttable addSubview:pullrefreshabstract];

    //styling
    self.view.backgroundColor = [UIColor background];
    self.bottom_view.backgroundColor = [UIColor background];
    self.talkview.backgroundColor = [UIColor clearColor];
    self.posterview.backgroundColor = [UIColor clearColor];
    self.abstractview.backgroundColor = [UIColor clearColor];
    self.talktable.backgroundColor = [UIColor clearColor];
    self.postertable.backgroundColor = [UIColor clearColor];
    self.abstracttable.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.show_search_button setTintColor:[UIColor light_button_txt]];
    self.search_view.backgroundColor = [UIColor light_bg];
    self.programseg.backgroundColor = [UIColor primary_color];
    self.no_attachment_label.textColor = [UIColor light_txt];
    self.no_poster_label.textColor = [UIColor light_txt];
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.programseg.bounds];
    self.programseg.layer.masksToBounds = NO;
    self.programseg.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programseg.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.programseg.layer.shadowOpacity = 0.3f;
    self.programseg.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:self.search_view.bounds];
    self.search_view.layer.masksToBounds = NO;
    self.search_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.search_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.search_view.layer.shadowOpacity = 0.3f;
    self.search_view.layer.shadowPath = shadowPath2.CGPath;
    
    UIImage *cross_img = [UIImage imageNamed:@"cross1.png"];
    cross_img = [cross_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cancel_search_button setTintColor:[UIColor dark_button_txt]];
    [self.cancel_search_button setImage:cross_img forState:UIControlStateNormal];
    [self.cancel_search_button setImage:cross_img forState:UIControlStateSelected];
    UIImage *search_img = [UIImage imageNamed:@"search3.png"];
    search_img = [search_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.do_search_button setTintColor:[UIColor dark_button_txt]];
    [self.do_search_button setImage:search_img forState:UIControlStateNormal];
    [self.do_search_button setImage:search_img forState:UIControlStateSelected];
    
    //get data
    [self get_session_and_talk_data_for_day:0];
    [self get_poster_data];
    [self get_abstract_data];
    
    //sign up/sign in
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // generate a tinted unselected image based on image passed via the storyboard
    for(UITabBarItem *item in self.tabBarController.tabBar.items) {
        item.image = [[item.selectedImage imageWithColor:[UIColor lightGrayColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [self check_selected_seg];
}

- (void) viewDidLayoutSubviews
{
    if ([self.talktable respondsToSelector:@selector(layoutMargins)]) {
        self.talktable.layoutMargins = UIEdgeInsetsZero;
        self.postertable.layoutMargins = UIEdgeInsetsZero;
        self.abstracttable.layoutMargins = UIEdgeInsetsZero;
    }
    [self check_selected_seg];
    
    //change layout for search on/off
    if (search_on)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.search_view setFrame:CGRectMake(self.search_view.frame.origin.x, self.search_view.frame.origin.y+40, self.search_view.frame.size.width, self.search_view.frame.size.height)];
            [self.programseg setFrame:CGRectMake(self.programseg.frame.origin.x, self.programseg.frame.origin.y+40, self.programseg.frame.size.width, self.programseg.frame.size.height)];
            [self.talkview setFrame:CGRectMake(self.talkview.frame.origin.x, self.talkview.frame.origin.y+40, self.talkview.frame.size.width, self.talkview.frame.size.height-40)];
            [self.posterview setFrame:CGRectMake(self.posterview.frame.origin.x, self.posterview.frame.origin.y+40, self.posterview.frame.size.width, self.posterview.frame.size.height-40)];
            [self.abstractview setFrame:CGRectMake(self.abstractview.frame.origin.x, self.abstractview.frame.origin.y+40, self.abstractview.frame.size.width, self.abstractview.frame.size.height-40)];
            [self.talktable setFrame:CGRectMake(self.talktable.frame.origin.x, self.talktable.frame.origin.y, self.talktable.frame.size.width, self.talktable.frame.size.height-40)];
            [self.postertable setFrame:CGRectMake(self.postertable.frame.origin.x, self.postertable.frame.origin.y, self.postertable.frame.size.width, self.postertable.frame.size.height-40)];
            [self.abstracttable setFrame:CGRectMake(self.abstracttable.frame.origin.x, self.abstracttable.frame.origin.y, self.abstracttable.frame.size.width, self.abstracttable.frame.size.height-40)];
        }];
        
        self.search_view.hidden = NO;
        NSLog(@"SEARCH ON LAYOUT");
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.search_view setFrame:CGRectMake(self.search_view.frame.origin.x, self.search_view.frame.origin.y, self.search_view.frame.size.width, self.search_view.frame.size.height)];
            [self.programseg setFrame:CGRectMake(self.programseg.frame.origin.x, self.programseg.frame.origin.y, self.programseg.frame.size.width, self.programseg.frame.size.height)];
            [self.talkview setFrame:CGRectMake(self.talkview.frame.origin.x, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height)];
            [self.posterview setFrame:CGRectMake(self.posterview.frame.origin.x, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height)];
            [self.abstractview setFrame:CGRectMake(self.abstractview.frame.origin.x, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height)];
            [self.talktable setFrame:CGRectMake(self.talktable.frame.origin.x, self.talktable.frame.origin.y, self.talktable.frame.size.width, self.talktable.frame.size.height)];
            [self.postertable setFrame:CGRectMake(self.postertable.frame.origin.x, self.postertable.frame.origin.y, self.postertable.frame.size.width, self.postertable.frame.size.height)];
            [self.abstracttable setFrame:CGRectMake(self.abstracttable.frame.origin.x, self.abstracttable.frame.origin.y, self.abstracttable.frame.size.width, self.abstracttable.frame.size.height)];
        }];
        
        self.search_view.hidden = YES;
        NSLog(@"SEARCH OFF LAYOUT");
    }
    

}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_session_and_talk_data_for_day:0];

    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}
- (void)refreshctrl_p:(id)sender
{
    //refresh code here
    [self get_poster_data];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}
- (void)refreshctrl_a:(id)sender
{
    //refresh code here
    [self get_abstract_data];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
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

    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self completed_signup];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later from the settings tab"
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
    
    //log out and go back to login view because of parse bug in 1.7.x (hopefully fixed in 1.7.3) 0519 update: nope! not fixed!
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Please log in using your username/password"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];

    [PFUser logOut];
    [self signup_to_login];
    
    
    // Associate the device with a user (normal procedure with no bugs)
    /*
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION ASSOCIATED");
    
    [self completed_signup];
    */
    
    //create the corresponding person object and set person/user properties
    /*
    PFUser *cur_user = user;
    NSString *email = cur_user[@"email"];
    cur_user[@"is_person"] = @1;
    cur_user[@"chat_status"] = @1;
    PFObject *person = [PFObject objectWithClassName:@"Person"];
    person[@"user"] = cur_user;
    person[@"is_user"] = @1;
    person[@"chat_status"] = @1;
    person[@"email"] = email;
    //after completion, call the method to close signup view and go to user options view
    [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new person created successfully");
            cur_user[@"person"] = person;
            [cur_user saveInBackground];
            [self completed_signup];
        }
        else
        {
            NSLog(@"new person creation error");
        }
    }];
    */
}

- (void) completed_signup
{
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

- (void) signup_to_login
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if (tableView.tag==1)
    {
        //return self.session_array.count;
        //NSLog(@"talk_session count: %lu", (unsigned long)self.session_array.count);
        return 1;
    }
    else if (tableView.tag==2)
    {
        return 1;
    }
    else
    {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        //PFObject *session_obj = [self.session_array objectAtIndex:section];
        //NSMutableArray *talk_temparray = [self.session_and_talk objectForKey:session_obj.objectId];
        //return [talk_temparray count];
        //NSLog(@"talk count: %lu", [talk_temparray count]);
        return self.talk_only.count;
    }
    else if (tableView.tag==2)
    {
        return self.poster_array.count;
    }
    else
    {
        return self.abstract_array.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        //init cell and object
        TalkCellTableViewCell *talkcell = [tableView dequeueReusableCellWithIdentifier:@"talkcell"];
        //PFObject *session = [self.session_array objectAtIndex:indexPath.section];
        //NSMutableArray *talks = [self.session_and_talk objectForKey:session.objectId];
        //PFObject *talk = [talks objectAtIndex:indexPath.row];
        PFObject *talk = [self.talk_only objectAtIndex:indexPath.row];
        PFObject *author = talk[@"author"];
        PFObject *location = talk[@"location"];
        
        //fill data
        talkcell.talk_name_label.text = talk[@"name"];
        talkcell.talk_author_label.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        talkcell.talk_description_label.text = talk[@"content"];
        talkcell.talk_location_label.text = location[@"name"];
        NSDate *date = talk[@"start_time"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"MMM-d HH:mm"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSString *dateString = [dateFormat stringFromDate:date];
        talkcell.talk_time_label.text = dateString;
        
        //styling
        if ([talkcell respondsToSelector:@selector(layoutMargins)])
        {
            talkcell.layoutMargins = UIEdgeInsetsZero;
        }
        talkcell.selectionStyle = UITableViewCellSelectionStyleNone;
        talkcell.backgroundColor = [UIColor clearColor];
        talkcell.talk_card_view.backgroundColor = [UIColor light_bg];
        talkcell.talk_card_view.alpha = 1.0;
        //talkcell.talk_detail_button.titleLabel.textColor = [UIColor bright_orange];
        [talkcell.talk_detail_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
        [talkcell.talk_detail_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateHighlighted];
        talkcell.talk_trim_view.backgroundColor = [UIColor accent_color];
        talkcell.talk_location_label.textColor = [UIColor secondary_text];
        talkcell.talk_time_label.textColor = [UIColor secondary_text];
        talkcell.talk_card_view.layer.cornerRadius = 2;
        talkcell.talk_author_label.textColor = [UIColor dark_txt];
        talkcell.talk_description_label.textColor = [UIColor dark_txt];
        talkcell.talk_name_label.textColor = [UIColor dark_txt];
        
        //add shadow to views
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:talkcell.talk_card_view.bounds];
        talkcell.talk_card_view.layer.masksToBounds = NO;
        talkcell.talk_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
        talkcell.talk_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        talkcell.talk_card_view.layer.shadowOpacity = 0.3f;
        talkcell.talk_card_view.layer.shadowPath = shadowPath.CGPath;

        
        return talkcell;
    }
    else if (tableView.tag==2)
    {
        //init cell and object
        PosterCellTableViewCell *postercell = [tableView dequeueReusableCellWithIdentifier:@"postercell"];
        PFObject *poster = [self.poster_array objectAtIndex:indexPath.row];
        PFObject *author = poster[@"author"];
        PFObject *location = poster[@"location"];
        
        //fill data
        postercell.poster_topic_label.text = poster[@"name"];
        postercell.poster_author_label.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        postercell.poster_content_label.text = poster[@"description"];
        postercell.poster_location_label.text = location[@"name"];
        
        //styling
        if ([postercell respondsToSelector:@selector(layoutMargins)])
        {
            postercell.layoutMargins = UIEdgeInsetsZero;
        }
        postercell.selectionStyle = UITableViewCellSelectionStyleNone;
        postercell.backgroundColor = [UIColor clearColor];
        postercell.poster_card_view.backgroundColor = [UIColor primary_color];
        postercell.poster_card_view.alpha = 0.8;
        //postercell.poster_detail_button.titleLabel.textColor = [UIColor bright_orange];
        [postercell.poster_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
        [postercell.poster_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
        postercell.poster_trim_view.backgroundColor = [UIColor primary_color];
        postercell.poster_location_label.textColor = [UIColor light_primary];
        postercell.poster_card_view.layer.cornerRadius = 2;
        postercell.poster_author_label.textColor = [UIColor light_primary];
        
        //add shadow to views
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:postercell.poster_card_view.bounds];
        postercell.poster_card_view.layer.masksToBounds = NO;
        postercell.poster_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
        postercell.poster_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        postercell.poster_card_view.layer.shadowOpacity = 0.3f;
        postercell.poster_card_view.layer.shadowPath = shadowPath.CGPath;
        
        return postercell;
    }
    else
    {
        //init cell and object
        AbstractCellTableViewCell *abstractcell = [tableView dequeueReusableCellWithIdentifier:@"abstractcell"];
        PFObject *abstract = [self.abstract_array objectAtIndex:indexPath.row];
        PFObject *author = abstract[@"author"];
        
        //fill data
        abstractcell.abstract_title_label.text = abstract[@"name"];
        abstractcell.abstract_author_label.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        
        //styling
        if ([abstractcell respondsToSelector:@selector(layoutMargins)])
        {
            abstractcell.layoutMargins = UIEdgeInsetsZero;
        }
        abstractcell.selectionStyle = UITableViewCellSelectionStyleNone;
        abstractcell.backgroundColor = [UIColor clearColor];
        abstractcell.abstract_card_view.backgroundColor = [UIColor primary_color];
        abstractcell.abstract_card_view.alpha = 0.8;
        //abstractcell.abstract_detail_button.titleLabel.textColor = [UIColor bright_orange];
        [abstractcell.abstract_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
        [abstractcell.abstract_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
        abstractcell.abstract_trim_view.backgroundColor = [UIColor light_primary];
        abstractcell.abstract_author_label.textColor = [UIColor light_primary];
        abstractcell.abstract_card_view.layer.cornerRadius = 2;
        
        //add shadow to views
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:abstractcell.abstract_card_view.bounds];
        abstractcell.abstract_card_view.layer.masksToBounds = NO;
        abstractcell.abstract_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
        abstractcell.abstract_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        abstractcell.abstract_card_view.layer.shadowOpacity = 0.3f;
        abstractcell.abstract_card_view.layer.shadowPath = shadowPath.CGPath;
        
        return abstractcell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)segaction:(UISegmentedControl *)sender {
    
    if (self.programseg.selectedSegmentIndex==0)
    {
        //[self.talktable reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            self.talkview.frame= CGRectMake(0, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
            self.posterview.frame= CGRectMake(320, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
            self.abstractview.frame= CGRectMake(320, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);
        }];
        NSLog(@"switch to talk seg");
    }
    else if (self.programseg.selectedSegmentIndex==1)
    {
        //[self.postertable reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            self.talkview.frame= CGRectMake(-320, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
            self.posterview.frame= CGRectMake(0, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
            self.abstractview.frame= CGRectMake(320, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);
        }];
        NSLog(@"switch to poster seg");
    }
    else if (self.programseg.selectedSegmentIndex==2)
    {
        //[self.abstracttable reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            self.talkview.frame= CGRectMake(-320, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
            self.posterview.frame= CGRectMake(-320, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
            self.abstractview.frame= CGRectMake(0, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);
        }];
        NSLog(@"switch to abstract seg");
    }
    //change layout for search on/off
    if (search_on)
    {
        [self.programseg setFrame:CGRectMake(self.programseg.frame.origin.x, self.programseg.frame.origin.y+40, self.programseg.frame.size.width, self.programseg.frame.size.height)];
        NSLog(@"SEARCH ON LAYOUT: SEG");
    }
    else
    {
        [self.programseg setFrame:CGRectMake(self.programseg.frame.origin.x, self.programseg.frame.origin.y, self.programseg.frame.size.width, self.programseg.frame.size.height)];
        NSLog(@"SEARCH OFF LAYOUT: SEG");
    }

}

- (void) get_session_and_talk_data_for_day: (int)day
{
    if (day == 0)
    {
        PFQuery *talk_subquery = [PFQuery queryWithClassName:@"Talk"];
        [talk_subquery includeKey:@"location"];
        [talk_subquery includeKey:@"author"];
        [talk_subquery orderByAscending:@"start_time"];
        talk_subquery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        talk_subquery.maxCacheAge = 86400;
        if (search_on && search_str.length>0)
        {
            [talk_subquery whereKey:@"words" containsAllObjectsInArray:search_array];
        }
        [talk_subquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"talk query success with count: %lu", (unsigned long)[objects count]);
            [self.talk_only removeAllObjects];
            self.talk_only = [objects mutableCopy];
            [self.talktable reloadData];
        }];
    }
    else
    {
        PFQuery *talk_subquery = [PFQuery queryWithClassName:@"Talk"];
        [talk_subquery includeKey:@"location"];
        [talk_subquery includeKey:@"author"];
        [talk_subquery orderByAscending:@"start_time"];
        talk_subquery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        talk_subquery.maxCacheAge = 86400;
        NSDate *start = [self get_start_time_for_day:day];
        NSDate *end = [self get_start_time_for_day:day+1];
        [talk_subquery whereKey:@"start_time" greaterThan:start];
        [talk_subquery whereKey:@"start_time" lessThan:end];
        if (search_on && search_str.length>0)
        {
            [talk_subquery whereKey:@"words" containsAllObjectsInArray:search_array];
        }
        [talk_subquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"talk query success with count: %lu", (unsigned long)[objects count]);
            [self.talk_only removeAllObjects];
            self.talk_only = [objects mutableCopy];
            [self.talktable reloadData];
        }];
    }
    
}

- (void) get_poster_data
{
    PFQuery *posterquery = [PFQuery queryWithClassName:@"Poster"];
    [posterquery orderByDescending:@"name"];
    [posterquery includeKey:@"author"];
    [posterquery includeKey:@"location"];
    posterquery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    posterquery.maxCacheAge = 86400;
    if (search_on && search_str.length>0)
    {
        [posterquery whereKey:@"words" containsAllObjectsInArray:search_array];
    }
    [posterquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"poster query success");
        [self.poster_array removeAllObjects];
        for (PFObject *poster_obj in objects)
        {
            [self.poster_array addObject:poster_obj];
        }
        if ([self.poster_array count] == 0)
        {
            self.no_poster_label.hidden = NO;
        }
        else
        {
            self.no_poster_label.hidden = YES;
        }
        [self.postertable reloadData];
    }];
}

- (void) get_abstract_data
{
    PFQuery *abstractquery = [PFQuery queryWithClassName:@"Attachments"];
    [abstractquery orderByDescending:@"name"];
    [abstractquery includeKey:@"author"];
    abstractquery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    abstractquery.maxCacheAge = 86400;
    [abstractquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"abstract query success");
        [self.abstract_array removeAllObjects];
        for (PFObject *abstract_obj in objects)
        {
            [self.abstract_array addObject:abstract_obj];
        }
        if ([self.abstract_array count] == 0)
        {
            self.no_attachment_label.hidden = NO;
        }
        else
        {
            self.no_attachment_label.hidden = YES;
        }
        [self.abstracttable reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (detail_type==0)
    {
        EventDetailViewController *controller = [segue destinationViewController];
        controller.event_type = 0;
        controller.event_objid = detail_objid;
    }
    else if (detail_type==1)
    {
        EventDetailViewController *controller = [segue destinationViewController];
        controller.event_type = 1;
        controller.event_objid = detail_objid;
    }
    else if (detail_type==2)
    {
        AbstractPdfViewController *controller = (AbstractPdfViewController *)[segue destinationViewController];
        controller.from_author = 0;
        controller.abstract_objid = detail_objid;
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Program" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;

}

- (IBAction)poster_detail_tap:(UIButton *)sender {
    PosterCellTableViewCell *cell = (PosterCellTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.postertable indexPathForCell:cell];
    NSLog(@"poster_detail_tap: %ld", (long)tapped_path.row);
    
    PFObject *poster = [self.poster_array objectAtIndex:tapped_path.row];
    detail_objid = poster.objectId;
    detail_type = 1;
    
    [self performSegueWithIdentifier:@"programeventsegue" sender:self];
}

- (IBAction)abstract_detail_tap:(UIButton *)sender {
    AbstractCellTableViewCell *cell = (AbstractCellTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.abstracttable indexPathForCell:cell];
    NSLog(@"abstract_detail_tap: %ld", (long)tapped_path.row);
    PFObject *abstract = [self.abstract_array objectAtIndex:tapped_path.row];
    detail_objid = abstract.objectId;
    detail_type = 2;
    
    [self performSegueWithIdentifier:@"programabstractsegue" sender:self];
}

- (IBAction)talk_detail_tap:(UIButton *)sender {
    TalkCellTableViewCell *cell = (TalkCellTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.talktable indexPathForCell:cell];
    //NSLog(@"poster_detail_tap: %ld, %ld", (long)tapped_path.section, (long)tapped_path.row);
    
    //PFObject *session = [self.session_array objectAtIndex:tapped_path.section];
    //NSMutableArray *talks = [self.session_and_talk objectForKey:session.objectId];
    //PFObject *talk = [talks objectAtIndex:tapped_path.row];
    PFObject *talk = [self.talk_only objectAtIndex:tapped_path.row];
    detail_objid = talk.objectId;
    detail_type = 0;
    
    [self performSegueWithIdentifier:@"programeventsegue" sender:self];
}

- (void) check_selected_seg
{
    int sel_index = self.programseg.selectedSegmentIndex;
    if (sel_index==0)
    {
        //talk seg selected
        self.talkview.frame= CGRectMake(0, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
        self.posterview.frame= CGRectMake(320, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
        self.abstractview.frame= CGRectMake(320, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);


        NSLog(@"CHECK SEG: TALK");
    }
    else if (sel_index==1)
    {
        //poster seg selected
        self.talkview.frame= CGRectMake(-320, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
        self.posterview.frame= CGRectMake(0, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
        self.abstractview.frame= CGRectMake(320, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);


        NSLog(@"CHECK SEG: POSTER");
    }
    else if (sel_index==2)
    {
        //abstract seg selected
        self.talkview.frame= CGRectMake(-320, self.talkview.frame.origin.y, self.talkview.frame.size.width, self.talkview.frame.size.height);
        self.posterview.frame= CGRectMake(-320, self.posterview.frame.origin.y, self.posterview.frame.size.width, self.posterview.frame.size.height);
        self.abstractview.frame= CGRectMake(0, self.abstractview.frame.origin.y, self.abstractview.frame.size.width, self.abstractview.frame.size.height);

        NSLog(@"CHECK SEG: ABSTRACT");
        NSLog(@"COORD:%f", self.talkview.frame.origin.x);
    }
    
}

//utility function to return the exact time (nsdate) for each day of the conference (day 1 day 2 ...etc)
- (NSDate *) get_start_time_for_day: (int) day
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:2];
    [comps setYear:2015];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    if (day ==1)
    {
        [comps setDay:19];
    }
    else if (day == 2)
    {
        [comps setDay:20];
    }
    else if (day == 3)
    {
        [comps setDay:21];
    }
    else
    {
        [comps setDay:22];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    return date;
}

- (IBAction)show_search_button_tap:(UIBarButtonItem *)sender {
    if (search_on)
    {
        //search was on, switch it off
        search_on = NO;
        self.search_input.text = @"";
        search_str = @"";
        [search_array removeAllObjects];
        [self.search_input resignFirstResponder];
        [self get_session_and_talk_data_for_day:0];
        [self get_poster_data];
        [self.view layoutIfNeeded];
    }
    else if (!search_on)
    {
        //search was off, switch it on
        search_on = YES;
        self.search_input.text = @"";
        search_str = @"";
        [search_array removeAllObjects];
        [self.view layoutIfNeeded];
    }
}

- (IBAction)do_search_button_tap:(UIButton *)sender {
    if (self.search_input.text.length > 0 )
    {
        search_str = self.search_input.text.lowercaseString;
        NSArray *wordsAndEmptyStrings = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        search_array = [words mutableCopy];
        [self get_session_and_talk_data_for_day:0];
        [self get_poster_data];
        [self.search_input resignFirstResponder];
    }
    
}

- (IBAction)cancel_search_button_tap:(UIButton *)sender {
    self.search_input.text = @"";
    search_str = @"";
    [search_array removeAllObjects];
    [self get_session_and_talk_data_for_day:0];
    [self get_poster_data];
    [self.search_input resignFirstResponder];
}


@end

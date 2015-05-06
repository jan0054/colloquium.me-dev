//
//  PersonDetailViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/22/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "PersonDetailEventCellTableViewCell.h"
#import "UIColor+ProjectColors.h"
#import "EventDetailViewController.h"
#import "AbstractPdfViewController.h"
#import "ChatViewController.h"
#import "PeopleTabViewController.h"

@interface PersonDetailViewController ()

@end

PFUser *the_user;
PFObject *the_person;
NSMutableArray *person_talks;
NSMutableArray *person_posters;
NSMutableArray *person_abstracts;
int seg_index;
BOOL mail_enabled;
BOOL web_enabled;
BOOL chat_enabled;
NSString *chosen_event_id;
int is_new_conv;
NSString *conv_objid;
int is_self;
NSString *ab_self;

@implementation PersonDetailViewController
@synthesize person_objid;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize
    person_talks = [[NSMutableArray alloc] init];
    person_posters = [[NSMutableArray alloc] init];
    person_abstracts = [[NSMutableArray alloc] init];
    seg_index=0;
    
    //styling
    self.person_detail_table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.person_card_view.backgroundColor = [UIColor nu_deep_blue];
    self.person_card_view.alpha = 0.8;
    self.person_trim_view.backgroundColor = [UIColor light_blue];
    self.person_detail_seg.tintColor = [UIColor whiteColor];
    self.person_card_view.layer.cornerRadius = 2;
    [self.person_chat_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.person_chat_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    [self.person_email_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.person_email_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    [self.person_link_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.person_link_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.person_card_view.bounds];
    self.person_card_view.layer.masksToBounds = NO;
    self.person_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.person_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.person_card_view.layer.shadowOpacity = 0.3f;
    self.person_card_view.layer.shadowPath = shadowPath.CGPath;
    
    [self get_person_data];
    
}

- (void) viewDidLayoutSubviews
{
    if ([self.person_detail_table respondsToSelector:@selector(layoutMargins)]) {
        self.person_detail_table.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)person_detail_seg_action:(UISegmentedControl *)sender {
    seg_index = self.person_detail_seg.selectedSegmentIndex;
    [self.person_detail_table reloadData];
}

- (IBAction)person_email_button_tap:(UIButton *)sender {
    if (mail_enabled==YES)
    {
        NSString *mailstr = the_person[@"email"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"This attendee has not set his email as public"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];

    }
}

- (IBAction)person_link_button_tap:(UIButton *)sender {
    if (web_enabled == YES)
    {
        NSString *linkstr = the_person[@"link"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkstr]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"This person does not have a public webpage"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) get_person_data
{
    //get current user 1. isperson 2. chat_on
    PFUser *cur_user = [PFUser currentUser];
    NSNumber *cur_user_chat_num = cur_user[@"chat_on"];
    int cur_user_chat = [cur_user_chat_num intValue];
    NSNumber *cur_user_isperson_num = cur_user[@"isperson"];
    int cur_user_isperson = [cur_user_isperson_num intValue];
    
    PFQuery *personquery = [PFQuery queryWithClassName:@"person"];
    [personquery includeKey:@"user"];
    [personquery getObjectInBackgroundWithId:self.person_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"detail person query success");
        the_person = object;
        self.person_name_label.text = [NSString stringWithFormat:@"%@, %@", the_person[@"last_name"], the_person[@"first_name"]];
        self.person_institution_label.text = the_person[@"institution"];
        [self get_person_talks];
        [self get_person_posters];
        [self get_person_abstracts];
        
        //get this person's email and chat preferences
        NSString *mailstr = the_person[@"email"];
        NSString *linkstr = the_person[@"link"];
        NSNumber *email_on = the_person[@"email_on"];
        NSNumber *chat_on = the_person[@"chat_on"];
        int email_int = [email_on intValue];
        int chat_int = [chat_on intValue];
        
        //determine email status: 1. cur user is attendee? 2. this person public email? 3. email not empty?
        if (cur_user_isperson != 1)
        {
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            mail_enabled = NO;
            self.person_email_button.enabled = NO;
            NSLog(@"mail button disabled due to current user not attendee");

        }
        else if (email_int != 1)
        {
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            mail_enabled = NO;
            self.person_email_button.enabled = NO;
            NSLog(@"mail button disabled due to this person doesn't want to publish email");
        }
        else if (mailstr == (id)[NSNull null] || mailstr.length == 0)
        {
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            mail_enabled = NO;
            self.person_email_button.enabled = NO;
            NSLog(@"mail button disabled due to empty email");
        }
        else
        {
            mail_enabled = YES;
            self.person_email_button.enabled = YES;
        }
        
        //determine web link status
        if ( linkstr == (id)[NSNull null] ||linkstr.length == 0 )
        {
            [self.person_link_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_link_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_link_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            web_enabled = NO;
            NSLog(@"web button disabled");
        }
        else
        {
            web_enabled = YES;
        }
        
        //determine chat status: 1. cur user has chat_on? 2. this person is user? 3. this person has chat_on? 4. is self?
        NSNumber *isuser_num = the_person[@"is_user"];
        int isuser = [isuser_num intValue];
        if (cur_user_chat != 1)
        {
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            chat_enabled = NO;
            self.person_chat_button.enabled = NO;
            NSLog(@"chat button disabled because current user hasn't turned on chat");
        }
        else if ( isuser != 1)
        {
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            chat_enabled = NO;
            self.person_chat_button.enabled = NO;
            NSLog(@"chat button disabled because person is not user");
        }
        else if (chat_int != 1)
        {
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            chat_enabled = NO;
            self.person_chat_button.enabled = NO;
            NSLog(@"chat button disabled because this person turned off chat");
        }
        else
        {
            the_user = the_person[@"user"];
            if ([the_user.objectId isEqualToString:cur_user.objectId])
            {
                chat_enabled= NO;
                is_self = 1;
                [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
                [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                self.person_chat_button.enabled = NO;
                NSLog(@"chat button disabled because this person is self");
            }
            else
            {
                chat_enabled = YES;
                self.person_chat_button.enabled = YES;
                NSLog(@"chat ready");
            }
        }
    }];
}

- (void) get_person_talks
{
    PFQuery *person_talk_query = [PFQuery queryWithClassName:@"talk"];
    [person_talk_query whereKey:@"author" equalTo:the_person];
    [person_talk_query orderByDescending:@"start_time"];
    [person_talk_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully retrieved %lu talks for the person.", (unsigned long)objects.count);
            person_talks = [objects mutableCopy];
            [self.person_detail_table reloadData];
        }
        else
        {
            // Log details of the failure if there's an error
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) get_person_posters
{
    PFQuery *person_poster_query = [PFQuery queryWithClassName:@"poster"];
    [person_poster_query whereKey:@"author" equalTo:the_person];
    [person_poster_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully retrieved %lu posters for the person.", (unsigned long)objects.count);
            person_posters = [objects mutableCopy];
            [self.person_detail_table reloadData];
        }
        else
        {
            // Log details of the failure if there's an error
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) get_person_abstracts
{
    PFQuery *person_abstract_query = [PFQuery queryWithClassName:@"abstract"];
    [person_abstract_query whereKey:@"author" equalTo:the_person];
    [person_abstract_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully retrieved %lu abstracts for the person.", (unsigned long)objects.count);
            person_abstracts = [objects mutableCopy];
            [self.person_detail_table reloadData];
        }
        else
        {
            // Log details of the failure if there's an error
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (seg_index) {
        case 0:
            return [person_talks count];
            break;
        case 1:
            return [person_posters count];
            break;
        case 2:
            return [person_abstracts count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonDetailEventCellTableViewCell *persondetailcell = [tableView dequeueReusableCellWithIdentifier:@"persondetailcell"];
    
    if (seg_index==0)
    {
        PFObject *talk = [person_talks objectAtIndex:indexPath.row];
        persondetailcell.person_event_title_label.text = talk[@"name"];
    }
    else if (seg_index==1)
    {
        PFObject *poster = [person_posters objectAtIndex:indexPath.row];
        persondetailcell.person_event_title_label.text = poster[@"name"];
    }
    else
    {
        PFObject *abstract = [person_abstracts objectAtIndex:indexPath.row];
        persondetailcell.person_event_title_label.text = abstract[@"name"];
    }
    
    persondetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([persondetailcell respondsToSelector:@selector(layoutMargins)]) {
        persondetailcell.layoutMargins = UIEdgeInsetsZero;
    }
    persondetailcell.person_event_title_label.textColor = [UIColor whiteColor];
    persondetailcell.backgroundColor = [UIColor clearColor];
    return persondetailcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (seg_index==0)
    {
        PFObject *talk = [person_talks objectAtIndex:indexPath.row];
        chosen_event_id = talk.objectId;
        [self performSegueWithIdentifier:@"authoreventsegue" sender:self];
    }
    else if (seg_index==1)
    {
        PFObject *poster = [person_posters objectAtIndex:indexPath.row];
        chosen_event_id = poster.objectId;
        [self performSegueWithIdentifier:@"authoreventsegue" sender:self];
    }
    else if (seg_index==2)
    {
        PFObject *abstract = [person_abstracts objectAtIndex:indexPath.row];
        chosen_event_id = abstract.objectId;
        [self performSegueWithIdentifier:@"authorabstractsegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (seg_index == 0)
    {
        EventDetailViewController *controller = (EventDetailViewController *)[segue destinationViewController];
        controller.from_author = 1;
        controller.event_objid = chosen_event_id;
        controller.event_type = 0;
    }
    else if (seg_index==1)
    {
        EventDetailViewController *controller = (EventDetailViewController *)[segue destinationViewController];
        controller.from_author = 1;
        controller.event_objid = chosen_event_id;
        controller.event_type = 1;
    }
    else if (seg_index==2)
    {
        AbstractPdfViewController *controller = (AbstractPdfViewController *)[segue destinationViewController];
        controller.from_author = 1;
        controller.abstract_objid = chosen_event_id;
    }
    else
    {
        ChatViewController *controller = (ChatViewController *)[segue destinationViewController];
        if (is_new_conv==0)
        {
            controller.is_new_conv = 0;
            controller.conversation_objid = conv_objid;
            controller.other_guy_objid = the_user.objectId;
            controller.other_guy_name = the_user[@"username"];
            controller.otherguy = the_user;
            controller.ab_self = ab_self;

        }
        else if (is_new_conv==1)
        {
            controller.is_new_conv = 1;
            controller.conversation_objid = conv_objid;
            controller.other_guy_objid = the_user.objectId;
            controller.other_guy_name = the_user[@"username"];
            controller.otherguy = the_user;
            controller.ab_self = ab_self;
        }
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;

}


- (IBAction)person_chat_button_tap:(UIButton *)sender {
    seg_index = 99;
    if (chat_enabled == YES)
    {
        NSLog(@"going to chat interface");
        [self check_conv_exist];
        
    }
    else
    {
        if (is_self==1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Cannot message self"
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];

        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"This person is not signed in or has turned off chat"
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }

}

//before triggering chat, check if self has messaged this user before
- (void) check_conv_exist
{
    PFUser *cur_user = [PFUser currentUser];
    PFQuery *query_a = [PFQuery queryWithClassName:@"conversation"];
    [query_a whereKey:@"user_a" equalTo:cur_user];
    [query_a whereKey:@"user_b" equalTo:the_user];
    [query_a findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] >=1)
        {
            NSLog(@"conversation found (query a)");
            is_new_conv=0;
            PFObject *the_conv = [objects objectAtIndex:0];
            conv_objid = the_conv.objectId;
            ab_self = @"a";
            //[self performSegueWithIdentifier:@"personchatsegue" sender:self];
            [self nav_to_chat];
        }
        else if ([objects count]==0)
        {
            PFQuery *query_b = [PFQuery queryWithClassName:@"conversation"];
            [query_b whereKey:@"user_a" equalTo:the_user];
            [query_b whereKey:@"user_b" equalTo:cur_user];
            [query_b findObjectsInBackgroundWithBlock:^(NSArray *objects_b, NSError *error) {
                if ([objects_b count] >=1)
                {
                    NSLog(@"conversation found (query b)");
                    is_new_conv=0;
                    PFObject *the_conv = [objects_b objectAtIndex:0];
                    conv_objid = the_conv.objectId;
                    ab_self = @"b";
                    //[self performSegueWithIdentifier:@"personchatsegue" sender:self];
                    [self nav_to_chat];

                }
                else if ([objects_b count]==0)
                {
                    NSLog(@"no existing conversation");
                    is_new_conv=1;
                    PFObject *new_conv = [PFObject objectWithClassName:@"conversation"];
                    new_conv[@"user_a"] = cur_user;
                    new_conv[@"user_b"] = the_user;
                    new_conv[@"last_msg"] = @"no messages yet";
                    new_conv[@"last_time"] = [NSDate date];
                    new_conv[@"user_a_unread"] = @0;
                    new_conv[@"user_b_unread"] = @0;
                    [new_conv saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"new conversation successfully created");
                        /*
                        PFQuery *findnewconv = [PFQuery queryWithClassName:@"conversation"];
                        [findnewconv whereKey:@"user_a" equalTo:cur_user];
                        [findnewconv whereKey:@"user_b" equalTo:the_person];
                        [findnewconv findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            PFObject *conv = [objects objectAtIndex:0];
                            conv_objid = conv.objectId;
                        }];
                        */
                        conv_objid = new_conv.objectId;
                        ab_self = @"a";
                        //[self performSegueWithIdentifier:@"personchatsegue" sender:self];
                        [self nav_to_chat];
                    }];
                }
            }];

        }
    }];
}

//pop the push segue back to ppl list, enter conversation view, then select appropriate conversation
- (void) nav_to_chat
{
    UINavigationController *navcon = [self.tabBarController.viewControllers objectAtIndex:1];
    [navcon popToRootViewControllerAnimated:NO];
    PeopleTabViewController *ppltabcon = (PeopleTabViewController *)[navcon topViewController];
    ppltabcon.from_message=1;
    ppltabcon.conv_id = conv_objid;
    ppltabcon.preload_chat_abself = ab_self;
    ppltabcon.preload_chat_isnewconv = is_new_conv;
    ppltabcon.preload_chat_otherguy = the_user;
    ppltabcon.preload_chat_otherguy_name = the_user[@"username"];
    ppltabcon.preload_chat_otherguy_objid = the_user.objectId;
    [self.tabBarController setSelectedIndex:1];
}



@end

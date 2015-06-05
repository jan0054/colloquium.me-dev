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
#import "UIViewController+ParseQueries.h"

@interface PersonDetailViewController ()

@end

PFUser *currentUser;
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
NSMutableArray *chatParticipants;

@implementation PersonDetailViewController
@synthesize person_objid;

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize
    person_talks = [[NSMutableArray alloc] init];
    person_posters = [[NSMutableArray alloc] init];
    person_abstracts = [[NSMutableArray alloc] init];
    chatParticipants = [[NSMutableArray alloc] init];
    seg_index=0;
    if ([PFUser currentUser])
    {
        currentUser = [PFUser currentUser];
    }
    
    //styling
    self.person_detail_table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor background];
    self.person_card_view.backgroundColor = [UIColor light_bg];
    self.person_card_view.alpha = 1.0;
    self.person_trim_view.backgroundColor = [UIColor accent_color];
    self.person_detail_seg.tintColor = [UIColor whiteColor];
    self.person_card_view.layer.cornerRadius = 2;
    [self.person_chat_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    [self.person_chat_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateHighlighted];
    [self.person_email_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    [self.person_email_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateHighlighted];
    [self.person_link_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    [self.person_link_button setTitleColor:[UIColor dark_button_txt] forState:UIControlStateHighlighted];
    self.person_name_label.textColor = [UIColor dark_txt];
    self.person_institution_label.textColor = [UIColor secondary_text];
    self.person_detail_seg.backgroundColor =[UIColor primary_color];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.person_card_view.bounds];
    self.person_card_view.layer.masksToBounds = NO;
    self.person_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.person_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.person_card_view.layer.shadowOpacity = 0.3f;
    self.person_card_view.layer.shadowPath = shadowPath.CGPath;
    UIBezierPath *shadowPath1 = [UIBezierPath bezierPathWithRect:self.person_detail_seg.bounds];
    self.person_detail_seg.layer.masksToBounds = NO;
    self.person_detail_seg.layer.shadowColor = [UIColor blackColor].CGColor;
    self.person_detail_seg.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.person_detail_seg.layer.shadowOpacity = 0.3f;
    self.person_detail_seg.layer.shadowPath = shadowPath1.CGPath;
    
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

#pragma mark - Data

- (void) get_person_data
{
    NSNumber *cur_user_chat_num = currentUser[@"chat_status"];
    int cur_user_chat = [cur_user_chat_num intValue];
    NSNumber *cur_user_isperson_num = currentUser[@"is_person"];
    int cur_user_isperson = [cur_user_isperson_num intValue];
    
    PFQuery *personquery = [PFQuery queryWithClassName:@"Person"];
    [personquery includeKey:@"user"];
    [personquery getObjectInBackgroundWithId:self.person_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"detail person query success");
        the_person = object;
        self.person_name_label.text = [NSString stringWithFormat:@"%@, %@", the_person[@"last_name"], the_person[@"first_name"]];
        self.person_institution_label.text = the_person[@"institution"];
        [self getTalks:self forAuthor:the_person];
        [self getPosters:self forAuthor:the_person];
        [self getAttachments:self forAuthor:the_person];
        
        //get this person's email and chat preferences
        NSString *mailstr = the_person[@"email"];
        NSString *linkstr = the_person[@"link"];
        NSNumber *email_on = the_person[@"email_status"];
        NSNumber *chat_on = the_person[@"chat_status"];
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
            if ([the_user.objectId isEqualToString:currentUser.objectId])
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

- (void)processConversationData: (NSArray *)results {
    NSLog(@"received conversation search results");
    if (results.count == 0)
    {
        //no existing private conversation between self and this person
        is_new_conv = 1;
    }
    else
    {
        is_new_conv = 0;
        PFObject *conversation = [results objectAtIndex:0];
        conv_objid = conversation.objectId;
    }
}

- (void)processTalkData: (NSArray *)results {
    NSLog(@"received talk data for person");
    person_talks = [results mutableCopy];
    [self.person_detail_table reloadData];
}
- (void)processPosterData: (NSArray *)results {
    NSLog(@"received poster data for person");
    person_posters = [results mutableCopy];
    [self.person_detail_table reloadData];
}
- (void)processAttachmentData: (NSArray *)results {
    NSLog(@"received attachment data for person");
    person_abstracts = [results mutableCopy];
    [self.person_detail_table reloadData];
}

//before triggering chat, check if self has messaged this user before
- (void) check_conv_exist
{
    PFUser *cur_user = [PFUser currentUser];
    PFRelation *relation1 = [cur_user relationForKey:@"conversation"];
    PFQuery *innerQuery1 = [relation1 query];
    [innerQuery1 whereKey:@"is_group" notEqualTo:@1];
    
    PFRelation *relation2 = [the_user relationForKey:@"conversation"];
    PFQuery *innerQuery2 = [relation2 query];
    [innerQuery2 whereKey:@"is_group" notEqualTo:@1];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"objectId" matchesKey:@"objectId" inQuery:innerQuery1];
    [query whereKey:@"objectId" matchesKey:@"objectId" inQuery:innerQuery2];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"conversation query error");
        } else {
            if (objects.count == 0)
            {
                NSLog(@"no existing conversation, creating new...");
                is_new_conv=1;
                PFObject *new_conv = [PFObject objectWithClassName:@"Conversation"];
                new_conv[@"last_msg"] = @"no messages yet";
                new_conv[@"last_time"] = [NSDate date];
                [new_conv saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"new conversation successfully created");
                    conv_objid = new_conv.objectId;
                    [self nav_to_chat];
                }];
            }
            else
            {
                //found conversation between these two people
                PFObject *conversation = [objects objectAtIndex:0];
                conv_objid = conversation.objectId;
                [self nav_to_chat];
            }
        }
    }];
}

- (void) startNewConversationWithUser: (PFUser *)user
{
    PFObject *conversation = [PFObject objectWithClassName:@"Conversation"];
    conversation[@"last_time"] = [NSDate date];
    conversation[@"last_msg"] = @"no messages yet";
    conversation[@"is_group"] = @0;
    PFRelation *relation = [conversation relationForKey:@"participants"];
    [relation addObject:user];
    [relation addObject:currentUser];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"new conversation successfully created");
        conv_objid = conversation.objectId;
        [self nav_to_chat];
    }];
}

#pragma mark - TableView

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

#pragma mark - Navigation

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
        }
        else if (is_new_conv==1)
        {
            controller.is_new_conv = 1;
            controller.conversation_objid = conv_objid;
        }
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;

}

//pop the push segue back to ppl list, enter conversation view, then select appropriate conversation
- (void) nav_to_chat
{
    [chatParticipants addObject:currentUser];
    [chatParticipants addObject:the_user];
    UINavigationController *navcon = [self.tabBarController.viewControllers objectAtIndex:1];
    [navcon popToRootViewControllerAnimated:NO];
    PeopleTabViewController *ppltabcon = (PeopleTabViewController *)[navcon topViewController];
    ppltabcon.fromInitiateChatEvent=1;
    ppltabcon.conv_id = conv_objid;
    ppltabcon.preload_chat_isnewconv = is_new_conv;
    ppltabcon.chatParticipants = chatParticipants;
    [self.tabBarController setSelectedIndex:1];
}

@end

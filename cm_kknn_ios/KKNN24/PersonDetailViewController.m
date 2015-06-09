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
BOOL selfIsPerson;
BOOL selfChatOn;
PFUser *the_user;                    //selected person's user object, if available
PFObject *the_person;                //selected person's person object
NSMutableArray *person_talks;
NSMutableArray *person_posters;
NSMutableArray *person_abstracts;
int seg_index;                       //holds currently selected segment index
NSString *chosen_event_id;
NSString *conv_objid;                //conversation id to be passed to chat
NSMutableArray *chatParticipants;    //chat participants to pass on to chat view (eventually..)
int chatStatus;                      //1=enabled, 0=other person not user or not set to public, 2=this person is self
int linkStatus;                      //1=enabled, 0=other person not user or didn't set link
int emailStatus;                     //1=enabled, 0=other person not user or not set to public

@implementation PersonDetailViewController
@synthesize person_objid;

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    person_talks = [[NSMutableArray alloc] init];
    person_posters = [[NSMutableArray alloc] init];
    person_abstracts = [[NSMutableArray alloc] init];
    chatParticipants = [[NSMutableArray alloc] init];
    seg_index=0;
    [self setupSelfStatus];
    
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
    
    [self getPersonData];
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
    [self goSendEmail];
}

- (IBAction)person_link_button_tap:(UIButton *)sender {
    [self goToLink];
}

- (IBAction)person_chat_button_tap:(UIButton *)sender {
    [self goToChat];
}

#pragma mark - Data

- (void) setupSelfStatus
{
    if ([PFUser currentUser])
    {
        currentUser = [PFUser currentUser];
        NSNumber *isPerson = currentUser[@"is_person"];
        int isPersonInt = [isPerson intValue];
        NSNumber *chatStatus = currentUser[@"chat_status"];
        int chatStatusInt = [chatStatus intValue];
        if (isPersonInt == 1)
        {
            selfIsPerson = YES;
            if (chatStatusInt ==1)
            {
                selfChatOn = YES;
            }
            else
            {
                selfChatOn = NO;
            }
        }
        else
        {
            selfIsPerson = NO;
            selfChatOn = NO;
        }
    }
    else
    {
        selfIsPerson = NO;
        selfChatOn = NO;
    }
}

- (void) getPersonData
{
    PFQuery *personquery = [PFQuery queryWithClassName:@"Person"];
    [personquery includeKey:@"user"];
    [personquery getObjectInBackgroundWithId:self.person_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"person query success");
        the_person = object;
        //fill basic fields and query for events
        self.person_name_label.text = [NSString stringWithFormat:@"%@, %@", the_person[@"last_name"], the_person[@"first_name"]];
        self.person_institution_label.text = the_person[@"institution"];
        [self getTalks:self forAuthor:the_person];
        [self getPosters:self forAuthor:the_person];
        [self getAttachments:self forAuthor:the_person];
        //chat+email+link
        NSString *address = the_person[@"email"];
        NSString *link = the_person[@"link"];
        NSNumber *email = the_person[@"email_status"];
        NSNumber *chat = the_person[@"chat_status"];
        int emailInt = [email intValue];
        int chatInt = [chat intValue];
        linkStatus = [self determineLinkStatus:link];
        emailStatus = [self determineEmailStatus:emailInt withAddress:address];
        chatStatus = [self determineChatStatus:chatInt];
        }];
}

- (int)determineEmailStatus: (int) status withAddress: (NSString *) address
{
    if (status ==1 && address.length >0)
    {
        return 1;
    }
    else
    {
        [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.person_email_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        return 0;
    }
}

- (int)determineLinkStatus: (NSString *) linkString
{
    if (linkString.length == 0)
    {
        [self.person_link_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.person_link_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        return 0;
    }
    else
    {
        return 1;
    }
}

- (int)determineChatStatus: (int) status
{
    if (status ==1)
    {
        the_user = the_person[@"user"];
        if ([the_user.objectId isEqualToString:currentUser.objectId])
        {
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            return 2;
        }
        return 1;
    }
    else
    {
        [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.person_chat_button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        return 0;
    }
}

- (void)goSendEmail
{
    if (selfIsPerson)
    {
        if (emailStatus==1)
        {
            NSString *mailstr = the_person[@"email"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"This person's email is private."
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        [self alertNotAttendee];
    }
}

- (void)goToLink
{
    if (selfIsPerson)
    {
        if (linkStatus==1)
        {
            NSString *linkstr = the_person[@"link"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkstr]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"This person has not set a public webpage."
                                                           delegate:self
                                                  cancelButtonTitle:@"Done"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        [self alertNotAttendee];
    }
}

- (void)goToChat
{
    if (selfChatOn)
    {
        switch (chatStatus) {
            case 0:
                [self alertNoChat];
                break;
            case 1:
                [self checkConversationForSelfAndUser:the_user];
                break;
            case 2:
                [self alertMessageSelf];
                break;
            default:
                break;
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"You need to be an event attendee and turn on chat."
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) alertNotAttendee
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You need to be an event attendee to use this feature."
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) alertMessageSelf
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Cannot message self."
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) alertNoChat
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"This person is not signed in or has turned off chat"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
}

//about to chat, first check if self has messaged this user before
- (void) checkConversationForSelfAndUser: (PFUser *)user
{
    [self getPrivateChat:self withUser:user alongWithSelf:currentUser];
    
    //old way to build the query
    /*
     PFRelation *relation1 = [currentUser relationForKey:@"conversation"];
     PFQuery *innerQuery1 = [relation1 query];
     [innerQuery1 whereKey:@"is_group" notEqualTo:@1];
     
     PFRelation *relation2 = [the_user relationForKey:@"conversation"];
     PFQuery *innerQuery2 = [relation2 query];
     [innerQuery2 whereKey:@"is_group" notEqualTo:@1];
     
     PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
     [query whereKey:@"objectId" matchesKey:@"objectId" inQuery:innerQuery1];
     [query whereKey:@"objectId" matchesKey:@"objectId" inQuery:innerQuery2];
     [query whereKey:@"is_group" notEqualTo:@1];
     
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (error) {
     NSLog(@"conversation query error");
     } else {
     if (objects.count == 0)
     {
     NSLog(@"no existing conversation, creating new...");
     PFObject *new_conv = [PFObject objectWithClassName:@"Conversation"];
     new_conv[@"last_msg"] = @"no messages yet";
     new_conv[@"last_time"] = [NSDate date];
     [new_conv saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     NSLog(@"new conversation successfully created");
     conv_objid = new_conv.objectId;
     [self navigateToChat];
     }];
     }
     else
     {
     //found conversation between these two people
     PFObject *conversation = [objects objectAtIndex:0];
     conv_objid = conversation.objectId;
     [self navigateToChat];
     }
     }
     }];
     */
}

- (void)processConversationData: (NSArray *)results {
    NSLog(@"Received conversation search results for this person: %lu", (unsigned long)results.count);
    if (results.count == 0)
    {
        //no existing private conversation between self and this person
        [self startNewConversationWithUser:the_user];
    }
    else
    {
        PFObject *conversation = [results objectAtIndex:0];
        conv_objid = conversation.objectId;
        [self navigateToChat];
    }
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
        [self navigateToChat];
    }];
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
    PersonDetailEventCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"persondetailcell"];
    //styling
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.person_event_title_label.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    //data
    if (seg_index==0)
    {
        PFObject *talk = [person_talks objectAtIndex:indexPath.row];
        cell.person_event_title_label.text = talk[@"name"];
    }
    else if (seg_index==1)
    {
        PFObject *poster = [person_posters objectAtIndex:indexPath.row];
        cell.person_event_title_label.text = poster[@"name"];
    }
    else
    {
        PFObject *abstract = [person_abstracts objectAtIndex:indexPath.row];
        cell.person_event_title_label.text = abstract[@"name"];
    }
    
    return cell;
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
}

//pop the push segue back to ppl list, enter conversation view, then select appropriate conversation
- (void) navigateToChat
{
    [chatParticipants removeAllObjects];
    [chatParticipants addObject:currentUser];
    [chatParticipants addObject:the_user];
    
    UINavigationController *navcon = [self.tabBarController.viewControllers objectAtIndex:1];
    [navcon popToRootViewControllerAnimated:NO];
    PeopleTabViewController *peopleTabViewController = (PeopleTabViewController *)[navcon topViewController];
    peopleTabViewController.fromInitiateChatEvent=1;
    peopleTabViewController.conv_id = conv_objid;
    peopleTabViewController.preloadedChatParticipants = chatParticipants;
    [self.tabBarController setSelectedIndex:1];
}

@end

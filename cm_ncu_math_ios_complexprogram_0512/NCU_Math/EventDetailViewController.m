//
//  EventDetailViewController.m
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "EventDetailViewController.h"
#import "UIColor+ProjectColors.h"
#import "PersonDetailViewController.h"
#import "PeopleTabViewController.h"
#import "AbstractPdfViewController.h"
#import "DiscussionViewController.h"

@interface EventDetailViewController ()

@end

NSString *author_objid;
NSString *abstract_id;
NSString *seg_choice;
PFObject *event_obj;
int discuss_on;  //enable-disable the discussion button

@implementation EventDetailViewController
@synthesize event_objid;
@synthesize from_author;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //disable discuss button first, wait till after data load to enable (avoid crashes)
    self.discuss_button.userInteractionEnabled = NO;
    
    //disable the attachment button first, enable it later if there is an attachement.
    self.eventdetail_abstract_button.enabled = NO;
    self.eventdetail_abstract_button.hidden = YES;
    abstract_id = @"";
    
    //disable the discussion button first, enable it if the current user is registered attendee
    [self.discuss_button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.discuss_button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    discuss_on = 0;
    if ([PFUser currentUser])
    {
        //ok, there's someone logged in, check if it's a registered attendee
        NSNumber *isperson = [PFUser currentUser][@"isperson"];
        int isperson_int = [isperson intValue];
        if (isperson_int == 1)
        {
            //ok, its a registered attendee, we can let him into discussion
            [self.discuss_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
            [self.discuss_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
            discuss_on = 1;
        }
    }
    
    //styling
    self.view.backgroundColor = [UIColor background];
    [self.eventdetail_card_view setBackgroundColor:[UIColor primary_color]];
    self.eventdetail_card_view.alpha = 0.8;
    [self.eventdetail_trim_view setBackgroundColor:[UIColor light_primary]];
    [self.eventdetail_description_card_view setBackgroundColor:[UIColor primary_color]];
    [self.eventdetail_description_textview setBackgroundColor:[UIColor primary_color]];
    self.eventdetail_location_label.textColor = [UIColor divider_color];
    self.eventdetail_time_label.textColor = [UIColor divider_color];
    self.eventdetail_author_label.textColor = [UIColor divider_color];
    self.eventdetail_card_view.layer.cornerRadius = 2;
    self.eventdetail_description_card_view.layer.cornerRadius = 2;
    [self.eventdetail_authordetail_button setTitleColor: [UIColor accent_color] forState:UIControlStateNormal];
    [self.eventdetail_authordetail_button setTitleColor: [UIColor accent_color] forState:UIControlStateHighlighted];
    [self.eventdetail_abstract_button setTitleColor: [UIColor accent_color] forState:UIControlStateNormal];
    [self.eventdetail_abstract_button setTitleColor: [UIColor accent_color] forState:UIControlStateHighlighted];
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.eventdetail_card_view.bounds];
    self.eventdetail_card_view.layer.masksToBounds = NO;
    self.eventdetail_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.eventdetail_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.eventdetail_card_view.layer.shadowOpacity = 0.3f;
    self.eventdetail_card_view.layer.shadowPath = shadowPath.CGPath;
    UIBezierPath *shadowPatha = [UIBezierPath bezierPathWithRect:self.eventdetail_description_card_view.bounds];
    self.eventdetail_description_card_view.layer.masksToBounds = NO;
    self.eventdetail_description_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.eventdetail_description_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.eventdetail_description_card_view.layer.shadowOpacity = 0.3f;
    self.eventdetail_description_card_view.layer.shadowPath = shadowPatha.CGPath;
    
    //get data
    if (self.event_type == 0)
    {
        [self get_talk_data];
    }
    else if (self.event_type == 1)
    {
        [self get_poster_data];
    }
}

- (void) viewDidAppear:(BOOL)animated
{

}

-(void) get_talk_data
{
    PFQuery *query = [PFQuery queryWithClassName:@"talk"];
    [query includeKey:@"author"];
    [query includeKey:@"location"];
    [query includeKey:@"abstract"];
    [query includeKey:@"session"];
    [query getObjectInBackgroundWithId:self.event_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"talk query success");
        event_obj = object;
        self.eventdetail_name_label.text = object[@"name"];
        PFObject *author = object[@"author"];
        self.eventdetail_author_label.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        author_objid = author.objectId;
        PFObject *abstract = object[@"abstract"];
        if (abstract != nil)
        {
            abstract_id = abstract.objectId;
            self.eventdetail_abstract_button.enabled = YES;
            self.eventdetail_abstract_button.hidden = NO;
        }
        self.eventdetail_description_textview.text = object[@"description"];
        PFObject *location = object[@"location"];
        self.eventdetail_location_label.text = location[@"name"];
        PFObject *session = object[@"session"];
        self.session_label.text = session[@"name"];
        NSDate *date = object[@"start_time"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormat setDateFormat: @"EEEE (MMM-d)   HH:mm"];
        NSString *dateString = [dateFormat stringFromDate:date];
        self.eventdetail_time_label.text = dateString;
        self.discuss_button.userInteractionEnabled = YES;
    }];

}

- (void) get_poster_data
{
    PFQuery *query = [PFQuery queryWithClassName:@"poster"];
    [query includeKey:@"author"];
    [query includeKey:@"location"];
    [query includeKey:@"abstract"];
    [query getObjectInBackgroundWithId:self.event_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"talk query success");
        event_obj = object;
        self.eventdetail_name_label.text = object[@"name"];
        PFObject *author = object[@"author"];
        author_objid = author.objectId;
        PFObject *abstract = object[@"abstract"];
        if (abstract != nil)
        {
            abstract_id = abstract.objectId;
            self.eventdetail_abstract_button.enabled = YES;
            self.eventdetail_abstract_button.hidden = NO;
        }
        abstract_id = abstract.objectId;
        self.eventdetail_author_label.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
        self.eventdetail_description_textview.text = object[@"description"];
        PFObject *location = object[@"location"];
        self.eventdetail_location_label.text = location[@"name"];
        self.eventdetail_time_label.text = @"";
        self.discuss_button.userInteractionEnabled = YES;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([seg_choice isEqualToString:@"abstract"])
    {
        AbstractPdfViewController *controller = (AbstractPdfViewController *)[segue destinationViewController];
        controller.abstract_objid = abstract_id;
    }
    else if ([seg_choice isEqualToString:@"discussion"])
    {
        DiscussionViewController *controller = (DiscussionViewController *)[segue destinationViewController];
        controller.event_type = self.event_type;
        controller.event_objid = self.event_objid;
        controller.event_obj = event_obj;
    }
}

- (IBAction)eventdetail_authordetail_button_tap:(UIButton *)sender {
    UINavigationController *navcon = [self.tabBarController.viewControllers objectAtIndex:1];
    [navcon popToRootViewControllerAnimated:NO];
    PeopleTabViewController *ppltabcon = (PeopleTabViewController *)[navcon topViewController];
    ppltabcon.from_event=1;
    ppltabcon.event_author_id = author_objid;
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)eventdetail_abstract_button_tap:(UIButton *)sender {
    if (abstract_id.length >=1)
    {
        seg_choice = @"abstract";
        [self performSegueWithIdentifier:@"eventabstractsegue" sender:self];
    }
}

- (IBAction)discuss_button_tap:(UIButton *)sender {
    if (discuss_on == 1)
    {
        seg_choice = @"discussion";
        [self performSegueWithIdentifier:@"discussionsegue" sender:self];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You need to be a registered attendee. If you are, please log in first."
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];

    }
}

@end

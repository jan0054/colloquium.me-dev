//
//  PositionDetailViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "PositionDetailViewController.h"
#import "UIColor+ProjectColors.h"

@interface PositionDetailViewController ()

@end

PFObject *thecareer;
NSString *postermail;
NSString *weblink;

@implementation PositionDetailViewController
@synthesize career_objid;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //hide the web and email button first
    self.link_button.enabled = NO;
    self.link_button.hidden = YES;
    self.contact_poster_button.enabled = NO;
    self.contact_poster_button.hidden = YES;
    
    //styling
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.career_card_view.backgroundColor = [UIColor nu_deep_blue];
    self.career_card_view.alpha = 0.8;
    self.career_trim_view.backgroundColor =[UIColor light_blue];
    self.note_card_view.backgroundColor = [UIColor main_blue];
    self.career_card_view.layer.cornerRadius = 2;
    self.note_card_view.layer.cornerRadius = 2;
    [self.contact_poster_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.contact_poster_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    [self.career_notes_textfield setBackgroundColor:[UIColor main_blue]];
    self.career_posted_by.textColor = [UIColor light_blue];
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.career_card_view.bounds];
    self.career_card_view.layer.masksToBounds = NO;
    self.career_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.career_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.career_card_view.layer.shadowOpacity = 0.3f;
    self.career_card_view.layer.shadowPath = shadowPath.CGPath;
    UIBezierPath *shadowPatha = [UIBezierPath bezierPathWithRect:self.note_card_view.bounds];
    self.note_card_view.layer.masksToBounds = NO;
    self.note_card_view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.note_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.note_card_view.layer.shadowOpacity = 0.3f;
    self.note_card_view.layer.shadowPath = shadowPatha.CGPath;
    
    
    [self get_career_data];

}

- (void) get_career_data
{
    PFQuery *careerquery = [PFQuery queryWithClassName:@"career"];
    [careerquery includeKey:@"posted_by"];
    [careerquery getObjectInBackgroundWithId:self.career_objid block:^(PFObject *object, NSError *error) {
        NSLog(@"detail career query success");
        thecareer = object;
        [self fill_data];
    }];
}

- (void) fill_data
{
    NSNumber *ctype = thecareer[@"offer_seek"];
    int ctype_int = [ctype intValue];
    if (ctype_int == 1)
    {
        //job seeker
        self.career_type_label.text = @"Seeking position";
        self.time_duration_label.text = [NSString stringWithFormat:@"Degree date: %@", thecareer[@"time_duration"]];
        self.career_institution_label.text = [NSString stringWithFormat:@"Degree: %@", thecareer[@"institution"]];
    }
    else
    {
        //job offer
        self.career_type_label.text = @"Position available";
        self.time_duration_label.text = [NSString stringWithFormat:@"Date/Duration: %@", thecareer[@"time_duration"]];
        self.career_institution_label.text = [NSString stringWithFormat:@"Institution: %@", thecareer[@"institution"]];
    }
    self.career_position_label.text = thecareer[@"position"];
    self.career_notes_textfield.text = thecareer[@"description"];
    self.contact_name_label.text = [NSString stringWithFormat:@"Contact: %@", thecareer[@"contact_name"]];
    PFObject *person = thecareer[@"posted_by"];
    self.career_posted_by.text = [NSString stringWithFormat:@"Posted by: %@ %@", person[@"first_name"], person[@"last_name"]];
    
    NSString *web_link_str = thecareer[@"link"];
    if (web_link_str.length>4)
    {
        //non-empty link
        self.link_button.enabled = YES;
        self.link_button.hidden = NO;
        weblink = web_link_str;
    }
    NSString *mailstr = thecareer[@"contact_email"];
    if (mailstr.length>4)
    {
        //non-empty email
        self.contact_poster_button.enabled = YES;
        self.contact_poster_button.hidden = NO;
        postermail = mailstr;
    }
}

- (IBAction)contact_poster_button_tap:(UIButton *)sender {
    NSString *mailstr = [NSString stringWithFormat:@"mailto://%@", postermail];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
}
- (IBAction)link_button_tap:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weblink]];
    NSLog(@"%@", weblink);
}

@end

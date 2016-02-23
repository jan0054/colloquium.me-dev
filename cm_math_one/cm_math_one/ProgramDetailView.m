//
//  ProgramDetailView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ProgramDetailView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ProgramForumView.h"
#import "FullScreenTextView.h"
#import "PdfReaderView.h"

PFFile *pdfFile;
BOOL reminderSet;
NSDate *startTime;
NSString *programName;
NSString *programId;

@implementation ProgramDetailView
@synthesize program;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    [self fillFieldsWithObject:self.program];
    programId = self.program.objectId;
    [self determineReminderStatusForObjectID:programId];
    
    //styling
    self.mainBackgroundView.backgroundColor = [UIColor clearColor];
    self.sessionLabel.textColor = [UIColor secondary_text];
    self.locationLabel.textColor = [UIColor secondary_text];
    self.timeLabel.textColor = [UIColor secondary_text];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
    
    UIImage *img = [UIImage imageNamed:@"fullscreen48@2x"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.fullscreenButton setTintColor:[UIColor accent_color]];
    [self.fullscreenButton setImage:img forState:UIControlStateNormal];
    
    [self.fullscreenButton setTitle:NSLocalizedString(@"fullscreen_button", nil) forState:UIControlStateNormal];
    [self.fullscreenButton setTitle:NSLocalizedString(@"fullscreen_button", nil) forState:UIControlStateHighlighted];
    [self.reminderButton setTitle:NSLocalizedString(@"reminder_button", nil) forState:UIControlStateNormal];
    [self.reminderButton setTitle:NSLocalizedString(@"reminder_button", nil) forState:UIControlStateHighlighted];
    
    [self.fullscreenButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self.reminderButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self.reminderButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
}

- (IBAction)fullscreenButtonTap:(UIButton *)sender {
    [self performSegueWithIdentifier:@"fullscreensegue" sender:self];
    NSLog(@"FULL SCREEN BUTTON TAPPED");
}

- (IBAction)discussButtonTap:(UIBarButtonItem *)sender {
    if ([PFUser currentUser])
    {
        [self performSegueWithIdentifier:@"programforumsegue" sender:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_need_account", nil)
                                    message:NSLocalizedString(@"alert_sign_in", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)pdfButtonTap:(UIButton *)sender {
    PdfReaderView *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"pdfreaderview"];
    controller.pdfPFFile = pdfFile;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)reminderButtonTap:(UIButton *)sender {
    NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:startTime];
    if (secs < 0)  //start time is in the future
    {
        if (reminderSet)
        {
            NSLog(@"reminder canceled");
            [self deleteReminderForObjectID:programId];
            reminderSet = NO;
            UIImage *img = [UIImage imageNamed:@"alarm48"];
            img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.reminderButton setTintColor:[UIColor light_bg]];
            [self.reminderButton setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSLog(@"reminder set");
            [self setReminderForDate:startTime withTitle:programName withObjectId:programId];
            reminderSet = YES;
            UIImage *img = [UIImage imageNamed:@"alarm48"];
            img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.reminderButton setTintColor:[UIColor primary_color_icon]];
            [self.reminderButton setImage:img forState:UIControlStateNormal];
        }
    }
    else   //start time has passed
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_passed_title", nil)
                                    message:NSLocalizedString(@"alert_passed_detail", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_passed_done", nil)
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Data

- (void)fillFieldsWithObject: (PFObject *)object
{
    PFObject *author = object[@"author"];
    PFObject *location = object[@"location"];
    PFObject *session = object[@"session"];
    self.sessionLabel.text = session[@"name"];
    self.nameLabel.text = object[@"name"];
    programName = object[@"name"];
    self.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    self.locationLabel.text = location[@"name"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = object[@"start_time"];
    startTime = sdate;
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSDate *edate = object[@"end_time"];
    NSString *estr = [dateFormat stringFromDate:edate];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", sstr, estr];
    self.contentTextView.text = object[@"content"];
    //determine pdf status
    if ([object objectForKey:@"pdf"])   //there is a pdf file
    {
        pdfFile = object[@"pdf"];
        self.pdfButton.hidden = NO;
        self.pdfButton.userInteractionEnabled = YES;
        [self.pdfButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
        [self.pdfButton setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    }
    else   //pdf isn't set
    {
        self.pdfButton.hidden = YES;
        self.pdfButton.userInteractionEnabled = NO;
        [self.pdfButton setTitleColor:[UIColor unselected_icon] forState:UIControlStateNormal];
        [self.pdfButton setTitleColor:[UIColor unselected_icon] forState:UIControlStateHighlighted];
    }
}

- (void)determineReminderStatusForObjectID: (NSString *)objId
{
    BOOL match = NO;
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *reminderArray = [app scheduledLocalNotifications];
    for (int i=0; i<[reminderArray count]; i++)
    {
        UILocalNotification* reminder = [reminderArray objectAtIndex:i];
        NSDictionary *userInfo = reminder.userInfo;
        NSString *reminderId=[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"objid"]];
        if ([reminderId isEqualToString:objId])
        {
            match = YES;
        }
    }
    
    if (match)   //reminder was set
    {
        reminderSet = YES;
        UIImage *img = [UIImage imageNamed:@"alarm48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.reminderButton setTintColor:[UIColor primary_color_icon]];
        [self.reminderButton setImage:img forState:UIControlStateNormal];
    }
    else   //reminder was not set
    {
        reminderSet = NO;
        UIImage *img = [UIImage imageNamed:@"alarm48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.reminderButton setTintColor:[UIColor light_bg]];
        [self.reminderButton setImage:img forState:UIControlStateNormal];
    }

}

- (void)setReminderForDate: (NSDate *)startDate withTitle: (NSString *)title withObjectId: (NSString *)objId
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [startDate dateByAddingTimeInterval:-300];
    localNotif.timeZone = [NSTimeZone systemTimeZone];
    NSString *fullMsg = [NSString stringWithFormat:@"%@ %@", title, NSLocalizedString(@"about_to_start", nil)];
    localNotif.alertBody = fullMsg;
    localNotif.alertAction = NSLocalizedString(@"reminder_done", nil);
    localNotif.alertTitle = NSLocalizedString(@"reminder_title", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:objId forKey:@"objid"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    NSLog(@"Reminder Set");
}

- (void)deleteReminderForObjectID: (NSString *)objId
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *reminderArray = [app scheduledLocalNotifications];
    for (int i=0; i<[reminderArray count]; i++)
    {
        UILocalNotification* reminderEvent = [reminderArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = reminderEvent.userInfo;
        NSString *reminderId=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"objid"]];
        if ([reminderId isEqualToString:objId])
        {
            //Cancel the notification
            [app cancelLocalNotification:reminderEvent];
            break;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"programforumsegue"]) {
        ProgramForumView *controller = (ProgramForumView *)segue.destinationViewController;
        controller.sourceProgram = self.program;
    }
    else if ([segue.identifier isEqualToString:@"fullscreensegue"])
    {
        FullScreenTextView *controller = (FullScreenTextView *)segue.destinationViewController;
        controller.content = self.contentTextView.text;
    }
}

@end

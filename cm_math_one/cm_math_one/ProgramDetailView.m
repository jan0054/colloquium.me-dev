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

@implementation ProgramDetailView
@synthesize program;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillFieldsWithObject:self.program];
    
    //styling
    self.mainBackgroundView.backgroundColor = [UIColor clearColor];
    self.sessionLabel.textColor = [UIColor dark_primary];
    self.locationLabel.textColor = [UIColor dark_primary];
    self.timeLabel.textColor = [UIColor dark_primary];
    UIImage *img = [UIImage imageNamed:@"fullscreen48@2x"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.fullscreenButton setTintColor:[UIColor primary_color]];
    [self.fullscreenButton setImage:img forState:UIControlStateNormal];
    //self.pdfButton.backgroundColor = [UIColor colorWithRed:170.0 green:170.0 blue:170.0 alpha:0.5];
}

- (IBAction)fullscreenButtonTap:(UIButton *)sender {
    [self performSegueWithIdentifier:@"fullscreensegue" sender:self];
    NSLog(@"FULL SCREEN BUTTON TAPPED");
}

- (IBAction)contentTapped:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"fullscreensegue" sender:self];
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

#pragma mark - Data

- (void)fillFieldsWithObject: (PFObject *)object
{
    PFObject *author = object[@"author"];
    PFObject *location = object[@"location"];
    PFObject *session = object[@"session"];
    self.sessionLabel.text = session[@"name"];
    self.nameLabel.text = object[@"name"];
    self.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    self.locationLabel.text = location[@"name"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = object[@"start_time"];
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
    }
    else   //pdf isn't set
    {
        self.pdfButton.hidden = YES;
        self.pdfButton.userInteractionEnabled = NO;
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

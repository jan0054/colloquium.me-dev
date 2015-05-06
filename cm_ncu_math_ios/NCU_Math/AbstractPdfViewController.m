//
//  AbstractPdfViewController.m
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "AbstractPdfViewController.h"
#import "UIColor+ProjectColors.h"
#import "PeopleTabViewController.h"

@interface AbstractPdfViewController ()

@end

NSString *author_id;
NSString *url_to_open;

@implementation AbstractPdfViewController
@synthesize abstract_name;
@synthesize from_author;
@synthesize abstract_objid;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //styling
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.pdf_trim_view.backgroundColor = [UIColor light_blue];
    self.abstract_trim_view.backgroundColor = [UIColor light_blue];
    self.abstract_card_view.backgroundColor = [UIColor nu_deep_blue];
    self.abstract_card_view.alpha = 0.8;
    self.abstract_author_label.textColor = [UIColor reallylight_blue];
    self.abstract_card_view.layer.cornerRadius = 2;
    self.abstract_detail_card_view.layer.cornerRadius = 2;
    self.abstract_detail_card_view.backgroundColor = [UIColor main_blue];
    [self.author_detail_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.author_detail_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    [self.abstract_open_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [self.abstract_open_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.abstract_card_view.bounds];
    self.abstract_card_view.layer.masksToBounds = NO;
    self.abstract_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.abstract_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.abstract_card_view.layer.shadowOpacity = 0.3f;
    self.abstract_card_view.layer.shadowPath = shadowPath.CGPath;
    //add shadow to views
    UIBezierPath *shadowPathb = [UIBezierPath bezierPathWithRect:self.abstract_detail_card_view.bounds];
    self.abstract_detail_card_view.layer.masksToBounds = NO;
    self.abstract_detail_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.abstract_detail_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.abstract_detail_card_view.layer.shadowOpacity = 0.3f;
    self.abstract_detail_card_view.layer.shadowPath = shadowPathb.CGPath;
    
    [self get_abstract_data];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (self.from_author==1)
    {
        self.author_detail_button.hidden = YES;
        self.from_author=0;
    }
    else
    {
        self.author_detail_button.hidden = NO;
    }
}

- (void) get_abstract_data
{
    PFQuery *abstractquery = [PFQuery queryWithClassName:@"abstract"];
    [abstractquery includeKey:@"author"];
    [abstractquery getObjectInBackgroundWithId:self.abstract_objid block:^(PFObject *object, NSError *error) {
        NSLog(@" single abstract query success");
        self.abstract_name_label.text = object[@"name"];
        self.abstract_content_textview.text = object[@"content"];
        PFObject *author = object[@"author"];
        author_id = author.objectId;
        self.abstract_author_label.text = [NSString stringWithFormat:@"%@, %@", author[@"first_name"], author[@"last_name"]];
        PFFile *abstract_pdf = object[@"pdf"];
        url_to_open = abstract_pdf.url;
        NSLog(@"attachment URL: %@", url_to_open );
        if (url_to_open.length >=1)
        {
            [self.abstract_open_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
            [self.abstract_open_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
        }
        else
        {
            [self.abstract_open_button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.abstract_open_button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        }
        //code to load pdf preview, not used in current version
        /*
        NSURL *pdf_url = [NSURL URLWithString:url_to_open];
        NSURLRequest *loadpdf = [NSURLRequest requestWithURL:url_to_open];
        [self.abstract_pdf_webview loadRequest:loadpdf];
        */
    }];
}

- (IBAction)author_detail_button_tap:(UIButton *)sender {
    UINavigationController *navcon = [self.tabBarController.viewControllers objectAtIndex:1];
    [navcon popToRootViewControllerAnimated:NO];
    PeopleTabViewController *ppltabcon = (PeopleTabViewController *)[navcon topViewController];
    ppltabcon.from_event=1;
    ppltabcon.event_author_id = author_id;
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)abstract_open_button_tap:(UIButton *)sender {
    if (url_to_open.length >=1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url_to_open]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"This attachment does not have an external link to open"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
}





@end

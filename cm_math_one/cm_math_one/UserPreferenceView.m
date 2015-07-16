//
//  UserPreferenceView.m
//  cm_math_one
//
//  Created by csjan on 6/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UserPreferenceView.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"
#import "UserPreferenceCell.h"
#import "UserPreferenceInputCell.h"
#import "UIViewController+ParseQueries.h"

BOOL changed;

@implementation UserPreferenceView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];

    self.preferenceTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    changed = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidLayoutSubviews
{
    if ([self.preferenceTable respondsToSelector:@selector(layoutMargins)]) {
        self.preferenceTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchChanged:(UISwitch *)sender {
    //UserPreferenceCell *pcell = (UserPreferenceCell *)[[[[sender superview] superview] superview] superview];
    //NSIndexPath *tapped_path = [self.preferenceTable indexPathForCell:pcell];
    changed = YES;
}

- (IBAction)saveButtonTap:(UIBarButtonItem *)sender {
    //before saving, check that first and last name are set
    UserPreferenceInputCell *fnCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UserPreferenceInputCell *lnCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    NSString *fn = fnCell.textInput.text;
    NSString *ln = lnCell.textInput.text;
    
    if (fn.length>0 && ln.length>0)
    {
        [self saveData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please fill in all required fields"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 7;   //email switch, event notifications, chat notifications, first name, last name, institution, link
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserPreferenceCell *pcell = [tableView dequeueReusableCellWithIdentifier:@"userpreferencecell"];
    UserPreferenceInputCell *icell = [tableView dequeueReusableCellWithIdentifier:@"userpreferenceinputcell"];
    
    //styling
    pcell.selectionStyle = UITableViewCellSelectionStyleNone;
    icell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([pcell respondsToSelector:@selector(layoutMargins)]) {
        pcell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([icell respondsToSelector:@selector(layoutMargins)]) {
        icell.layoutMargins = UIEdgeInsetsZero;
    }
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL mail = [defaults boolForKey:@"mailswitch"];
    BOOL event = [defaults boolForKey:@"eventswitch"];
    BOOL chat = [defaults boolForKey:@"chatswitch"];
    NSString *fn = [defaults stringForKey:@"firstname"];
    NSString *ln = [defaults stringForKey:@"lastname"];
    NSString *inst = [defaults stringForKey:@"institution"];
    NSString *link = [defaults stringForKey:@"link"];
    
    switch (indexPath.row) {
        case 0:
            pcell.contentLabel.text = @"Allow other users to email you";
            [pcell.settingSwitch setOn:mail];
            return pcell;
            break;
        case 1:
            pcell.contentLabel.text = @"Receive event notifications";
            [pcell.settingSwitch setOn:event];
            return pcell;
            break;
        case 2:
            pcell.contentLabel.text = @"Receive chat notifications";
            [pcell.settingSwitch setOn:chat];
            return pcell;
            break;
        case 3:
            icell.contentLabel.text = @"First Name:";
            icell.textInput.placeholder = @"required";
            icell.textInput.text = fn.length>0 ? fn : nil;
            return icell;
            break;
        case 4:
            icell.contentLabel.text = @"Last Name:";
            icell.textInput.placeholder = @"required";
            icell.textInput.text = ln.length>0 ? ln : nil;
            return icell;
            break;
        case 5:
            icell.contentLabel.text = @"Institution:";
            icell.textInput.placeholder = @"optional";
            icell.textInput.text = inst.length>0 ? inst : nil;
            return icell;
            break;
        case 6:
            icell.contentLabel.text = @"Web Page:";
            icell.textInput.placeholder = @"optional";
            icell.textInput.text = link.length>0 ? link : nil;
            return icell;
            break;
        default:
            return pcell;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (void) saveData
{
    //get the data
    UserPreferenceCell *mailCell = (UserPreferenceCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UserPreferenceCell *eventCell = (UserPreferenceCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UserPreferenceCell *chatCell = (UserPreferenceCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UserPreferenceInputCell *fnCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UserPreferenceInputCell *lnCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    UserPreferenceInputCell *inCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    UserPreferenceInputCell *webCell = (UserPreferenceInputCell *)[self.preferenceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    UISwitch *mailSwitch = mailCell.settingSwitch;
    UISwitch *eventSwitch = eventCell.settingSwitch;
    UISwitch *chatSwitch = chatCell.settingSwitch;
    NSString *fn = fnCell.textInput.text;
    NSString *ln = lnCell.textInput.text;
    NSString *inst = inCell.textInput.text.length>0 ? inCell.textInput.text : @"n/a";
    NSString *link = webCell.textInput.text.length>0 ? webCell.textInput.text : @"";
    
    //save to local
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:mailSwitch.on forKey:@"mailswitch"];
    [defaults setBool:eventSwitch.on forKey:@"eventswitch"];
    [defaults setBool:chatSwitch.on forKey:@"chatswitch"];
    [defaults setObject:fn forKey:@"firstname"];
    [defaults setObject:ln forKey:@"lastname"];
    [defaults setObject:inst forKey:@"institution"];
    [defaults setObject:link forKey:@"link"];
    [defaults synchronize];
    
    //save to Parse
    if ([PFUser currentUser])
    {
        [self updateUserPreference:self forUser:[PFUser currentUser]];
    }
    
    //exit
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

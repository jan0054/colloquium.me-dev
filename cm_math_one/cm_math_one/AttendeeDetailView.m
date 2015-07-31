//
//  AttendeeDetailView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AttendeeDetailView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "AttendeeProgramCell.h"

NSMutableArray *attendeeProgramArray;

@implementation AttendeeDetailView
@synthesize attendee;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    attendeeProgramArray = [[NSMutableArray alloc] init];
    self.attendeeProgramTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;

    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self forAuthor:attendee forEvent:event];
    
    //disable email/chat if turned off, or if web link empty
    [self checkPermissions];
}

- (void)viewDidLayoutSubviews
{
    if ([self.attendeeProgramTable respondsToSelector:@selector(layoutMargins)]) {
        self.attendeeProgramTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)chatButtonTap:(UIButton *)sender {
    //to-do: start chat with this person
    PFUser *user = attendee[@"user"];
    
}

- (IBAction)emailButtonTap:(UIButton *)sender {
    NSString *mailstr = [NSString stringWithFormat:@"mailto://%@", attendee[@"email"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
}

- (IBAction)websiteButtonTap:(UIButton *)sender {
    NSString *linkstr = attendee[@"link"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkstr]];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [attendeeProgramArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttendeeProgramCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendeeprogramcell"];
    PFObject *program = [attendeeProgramArray objectAtIndex:indexPath.row];
    cell.programLabel.text = program[@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to-do: go to the program detail view for this program
    PFObject *program = [attendeeProgramArray objectAtIndex:indexPath.row];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [attendeeProgramArray removeAllObjects];
    attendeeProgramArray = [results mutableCopy];
    [self.attendeeProgramTable reloadData];
}

- (void)checkPermissions
{
    int email = [attendee[@"email_status"] intValue];
    int chat = [attendee[@"chat_Status"] intValue];
    if (email == 1)
    {
        self.emailButton.enabled = YES;
    }
    else
    {
        self.emailButton.enabled = NO;
    }
    if (chat == 1)
    {
        self.chatButton.enabled = YES;
    }
    else
    {
        self.chatButton.enabled = NO;
    }
    NSString *link = attendee[@"link"];
    if (link.length >=1)
    {
        self.websiteButton.enabled = YES;
    }
    else
    {
        self.websiteButton.enabled = NO;
    }
}

@end

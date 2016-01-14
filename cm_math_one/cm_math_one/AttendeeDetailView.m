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
#import "ProgramDetailView.h"

NSMutableArray *attendeeProgramArray;
PFObject *chosenProgram;

@implementation AttendeeDetailView
@synthesize attendee;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    attendeeProgramArray = [[NSMutableArray alloc] init];
    self.attendeeProgramTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.noProgramLabel.hidden = YES;
    
    //styling
    self.noProgramLabel.textColor = [UIColor dark_accent];
    self.attendeeBackground.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;

    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self forAuthor:attendee forEvent:event];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.attendee[@"last_name"], self.attendee[@"first_name"]];
    self.institutionLabel.text = self.attendee[@"institution"];
    
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
    NSString *mail = attendee[@"email"];
    if (mail.length>3)
    {
        NSString *mailstr = [NSString stringWithFormat:@"mailto://%@", attendee[@"email"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
    }
}

- (IBAction)websiteButtonTap:(UIButton *)sender {
    NSString *linkstr = attendee[@"link"];
    if (linkstr.length>3)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkstr]];
    }
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to-do: go to the program detail view for this program
    chosenProgram = [attendeeProgramArray objectAtIndex:indexPath.row];
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //ProgramDetailView *controller = (ProgramDetailView *)[storyboard instantiateViewControllerWithIdentifier:@"programdetail_vc"];
    //controller.program = targetProgram;
    //[self presentViewController:controller animated:YES completion:nil];
    [self performSegueWithIdentifier:@"attendeetalksegue" sender:self];
    
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [attendeeProgramArray removeAllObjects];
    attendeeProgramArray = [results mutableCopy];
    [self.attendeeProgramTable reloadData];
    
    if (attendeeProgramArray.count >0)
    {
        self.noProgramLabel.hidden = YES;
    }
    else
    {
        self.noProgramLabel.hidden = NO;
    }
}

- (void)checkPermissions
{
    int email = [attendee[@"email_status"] intValue];
    int chat = [attendee[@"chat_Status"] intValue];
    if (email == 1)
    {
        self.emailButton.enabled = YES;
        [self.emailButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    }
    else
    {
        self.emailButton.enabled = NO;
    }
    /*
    if (chat == 1)
    {
        self.chatButton.enabled = YES;
        [self.chatButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    }
    else
    {
        self.chatButton.enabled = NO;
    }
    */
    
    //unfinished: tap to start chat
    self.chatButton.enabled = NO;
    self.chatButton.hidden = YES;
    
    NSString *link = attendee[@"link"];
    if (link.length >=1)
    {
        self.websiteButton.enabled = YES;
        [self.websiteButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    }
    else
    {
        self.websiteButton.enabled = NO;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"attendeetalksegue"]) {
        ProgramDetailView *controller = (ProgramDetailView *) segue.destinationViewController;
        controller.program = chosenProgram;
    }
}

@end

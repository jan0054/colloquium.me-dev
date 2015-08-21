//
//  ChatOptions.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChatOptions.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ChatOptionCell.h"

NSMutableArray *inviteeArray;
BOOL isGroup;

@implementation ChatOptions
@synthesize conversation;
@synthesize receivedParticipants;

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    inviteeArray = [[NSMutableArray alloc] init];
    [self getInviteeList:self withoutUsers:receivedParticipants];
    
    //styling
    //self.view.layer.cornerRadius = 3;
    self.inviteeTable.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidLayoutSubviews
{
    if ([self.inviteeTable respondsToSelector:@selector(layoutMargins)]) {
        self.inviteeTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)leaveButtonTap:(UIBarButtonItem *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Confirm leave"
                                message:@"You will not be able to view these messages or receive new ones after you leave the conversation."
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Leave", nil] show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self leaveConversation:self forConversation:conversation forUser:[PFUser currentUser]];
    }
}

- (IBAction)inviteButtonTap:(UIButton *)sender {
    ChatOptionCell *cell = (ChatOptionCell *)[[sender superview] superview];
    NSIndexPath *tappedPath = [self.inviteeTable indexPathForCell:cell];
    NSLog(@"invitee_tap: %ld", (long)tappedPath.row);
    PFUser *invitedUser = [inviteeArray objectAtIndex:tappedPath.row];
    [self inviteUser:self toConversation:conversation withUser:invitedUser atPath:tappedPath];

    cell.inviteButton.enabled = NO;
    cell.inviteButton.userInteractionEnabled = NO;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inviteeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatoptioncell"];
    
    //styling
    //cell.nameLabel.textColor = [UIColor dark_txt];
    //cell.institutionLabel.textColor = [UIColor secondary_text];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    [cell.inviteButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //data
    PFObject *user = [inviteeArray objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
    NSString *institution = user[@"institution"];
    
    cell.nameLabel.text = name;
    cell.institutionLabel.text = institution;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Data

- (void)processInviteeData:(NSArray *)results  //callback for total chat-enabled user query, minus current participants
{
    [inviteeArray removeAllObjects];
    inviteeArray = [results mutableCopy];
    [self.inviteeTable reloadData];
}

- (void)processAddedSuccess:(NSIndexPath *)path forAddedUser: (PFUser *)user //callback for adding a specific user
{
    [self.receivedParticipants addObject:user];
    [self getInviteeList:self withoutUsers:receivedParticipants];
    //ChatOptionCell *cell = (ChatOptionCell *)[self.inviteeTable cellForRowAtIndexPath:path];
    //[cell.inviteButton setTitle:@"Invited" forState:UIControlStateNormal];
}

- (void)processLeftConversation  //callback for leaving the conversation
{
    PFUser *user = [PFUser currentUser];
    NSString *broadcastString = [NSString stringWithFormat:@"%@ %@ has left the conversation.", user[@"first_name"], user[@"last_name"]];
    [self sendBroadcast:self withAuthor:user withContent:broadcastString forConversation:self.conversation];
    
    NSLog(@"Left conversation, popping controller stack back to root");
    UINavigationController *navCon = self.navigationController;
    [navCon popToRootViewControllerAnimated:YES];
}

@end

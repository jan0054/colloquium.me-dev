//
//  ChatInviteView.m
//  cm_math_one
//
//  Created by csjan on 8/10/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChatInviteView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ChatInviteCell.h"

NSMutableArray *inviteArray;
NSMutableArray *selectedArray;

@implementation ChatInviteView

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    inviteArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    [self getInviteeList:self withoutUsers:@[[PFUser currentUser]]];
    
    //styling
    //self.view.layer.cornerRadius = 3;
    self.chatInviteTable.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidLayoutSubviews
{
    if ([self.chatInviteTable respondsToSelector:@selector(layoutMargins)]) {
        self.chatInviteTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)inviteButtonTap:(UIButton *)sender {
}

- (IBAction)inviteDoneButtonTap:(UIBarButtonItem *)sender {
    [selectedArray removeAllObjects];
    NSArray *selectedPaths =  self.chatInviteTable.indexPathsForSelectedRows;
    for ( NSIndexPath *ip in selectedPaths)
    {
        int place = ip.row;
        PFUser *user = [inviteArray objectAtIndex:place];
        [selectedArray addObject:user];
    }
    [selectedArray addObject:[PFUser currentUser]];
    [self createConcersation:self withParticipants:selectedArray];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inviteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatinvitecell"];
    
    //styling
    //cell.nameLabel.textColor = [UIColor dark_txt];
    //cell.institutionLabel.textColor = [UIColor secondary_text];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    //data
    PFObject *user = [inviteArray objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
    NSString *institution = user[@"institution"];
    
    cell.nameLabel.text = name;
    cell.institutionLabel.text = institution;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = (ChatInviteCell *)[self.chatInviteTable cellForRowAtIndexPath:indexPath];
    [cell.inviteButton setTitle:@"Invited!" forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = (ChatInviteCell *)[self.chatInviteTable cellForRowAtIndexPath:indexPath];
    [cell.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
}

#pragma mark - Data

- (void)processInviteeData:(NSArray *)results  //callback for total chat-enabled user query, minus current participants
{
    [inviteArray removeAllObjects];
    inviteArray = [results mutableCopy];
    [self.chatInviteTable reloadData];
}

- (void)createConvSuccess  //callback for done button tap
{
    UINavigationController *navCon = self.navigationController;
    [navCon popViewControllerAnimated:YES];
}

@end

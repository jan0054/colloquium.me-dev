//
//  GroupChatOptions.m
//  KKNN24
//
//  Created by csjan on 6/9/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "GroupChatOptions.h"
#import "GroupChatInviteCell.h"
#import "UIViewController+ParseQueries.h"
#import "UIColor+ProjectColors.h"
#import "ChatViewController.h"


NSMutableArray *inviteeList;

@implementation GroupChatOptions
@synthesize isGroup;
@synthesize selectedList;
@synthesize participants;
@synthesize data_delegate;

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    inviteeList = [[NSMutableArray alloc] init];
    self.selectedList = [[NSMutableArray alloc] init];
    [self getInviteeList:self withoutUsers:participants];

    //styling
    self.view.layer.cornerRadius = 3;
    self.inviteTable.tableFooterView = [[UIView alloc] init];
    
    [self updateIsGroup];
    [self updateSelectedInvitees];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"Container view appear");
}

- (void) viewDidLayoutSubviews
{
    if ([self.inviteTable respondsToSelector:@selector(layoutMargins)]) {
        self.inviteTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)leaveConversationButtonTap:(UIButton *)sender
{
    NSLog(@"leave conversation tapped");
    [data_delegate leaveConversationFromDelegate];
}

- (IBAction)addConversationButtonTap:(UIButton *)sender
{
    NSLog(@"add people tapped");
    [self getSelectedRows];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inviteeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupChatInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invitecell"];
    //styling
    cell.nameLabel.textColor = [UIColor dark_txt];
    cell.institutionLabel.textColor = [UIColor secondary_text];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    //data
    PFObject *person = [inviteeList objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", person[@"first_name"], person[@"last_name"]];
    NSString *institution = person[@"institution"];
    //ui
    cell.nameLabel.text = name;
    cell.institutionLabel.text = institution;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectedInvitees];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectedInvitees];
}

- (void) getSelectedRows
{
    [selectedList removeAllObjects];
    NSArray *selected_paths = (NSArray *)[self.inviteTable indexPathsForSelectedRows];
    for ( NSIndexPath *ip in selected_paths)
    {
        int place = ip.row;
        PFObject *object = [inviteeList objectAtIndex:place];
        [selectedList addObject:object];
    }
    [self addInviteesToGroup:selectedList];
}

- (void) deselectAllRows
{
    NSArray *selected_paths = (NSArray *)[self.inviteTable indexPathsForSelectedRows];
    for ( NSIndexPath *ip in selected_paths)
    {
        [self.inviteTable deselectRowAtIndexPath:ip animated:YES];
    }
}

#pragma mark - Data

- (void)processInviteeData:(NSArray *)results
{
    [inviteeList removeAllObjects];
    inviteeList = [results mutableCopy];
    [self.inviteTable reloadData];
}

- (void)updateIsGroup
{
    NSNumber *ignum = self.conversation[@"is_group"];
    int ig = [ignum intValue];
    if (ig == 1)
    {
        isGroup = YES;
    }
    else
    {
        isGroup = NO;
    }

    if (isGroup)
    {
        self.leaveConversationButton.enabled = YES;
        [self.leaveConversationButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    }
    else
    {
        self.leaveConversationButton.enabled = NO;
        [self.leaveConversationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)updateSelectedInvitees
{
    NSArray *selected_paths = (NSArray *)[self.inviteTable indexPathsForSelectedRows];
    if (selected_paths.count>=1)
    {
        self.addConversationButton.enabled = YES;
        [self.addConversationButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    }
    else
    {
        self.addConversationButton.enabled = NO;
        [self.addConversationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)addInviteesToGroup: (NSArray *)selectedPeople
{
    [self deselectAllRows];
    NSMutableArray *usersToAdd = [[NSMutableArray alloc] init];
    for (PFObject *person in selectedPeople)
    {
        PFUser *user = person[@"user"];
        [usersToAdd addObject:user];
    }
    [self.conversation addObjectsFromArray:usersToAdd forKey:@"participants"];
    self.conversation[@"is_group"] = @1;
    [self.conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Conversation added participants successfully");
            self.participants = self.conversation[@"participants"];
            [self getInviteeList:self withoutUsers:self.participants];
            [self updateIsGroup];
            [self updateSelectedInvitees];
            [data_delegate gotParticipantsFromDelegate:self.participants withNewPeople:selectedPeople withConversation:self.conversation];
        }
        else
        {
            NSLog(@"Conversation add participants error:%@",error);
        }
    }];
}

@end
//
//  ConversationView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ConversationView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ConversationCell.h"

NSMutableArray *conversationArray;

@implementation ConversationView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    conversationArray = [[NSMutableArray alloc] init];
    
    if ([PFUser currentUser])
    {
        [self getConversations:self withUser:[PFUser currentUser]];
    }
    else
    {
        [self noUserYet];
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationcell"];
    PFObject *conversation = [conversationArray objectAtIndex:indexPath.row];
    
    cell.timeLabel.text = @"";
    cell.participantLabel.text = @"";
    cell.messageLabel.text = @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [conversationArray removeAllObjects];
    conversationArray = [results mutableCopy];
    [self.conversationTable reloadData];
}

- (void) noUserYet
{
    //to-do: ask user to sign up / log in
}

@end

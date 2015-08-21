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
#import "ChatView.h"

NSMutableArray *conversationArray;
PFObject *selectedConversation;
PFUser *selfUser;
NSMutableArray *selectedParticipants;

@implementation ConversationView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    conversationArray = [[NSMutableArray alloc] init];
    selectedParticipants = [[NSMutableArray alloc] init];
    self.conversationTable.estimatedRowHeight = 160.0;
    self.conversationTable.rowHeight = UITableViewAutomaticDimension;
    self.conversationTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.noConvLabel.hidden = YES;
    self.noConvLabel.textColor = [UIColor dark_primary];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.conversationTable respondsToSelector:@selector(layoutMargins)]) {
        self.conversationTable.layoutMargins = UIEdgeInsetsZero;
    }
    
    if ([PFUser currentUser])
    {
        selfUser = [PFUser currentUser];
        [self getConversations:self withUser:selfUser];
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

- (IBAction)addConvButtonTap:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"chatinvitesegue" sender:self];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [conversationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationcell"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.timeLabel.textColor = [UIColor dark_primary];
    cell.timeLabel.backgroundColor = [UIColor clearColor];
    cell.messageLabel.backgroundColor = [UIColor clearColor];
    cell.participantLabel.backgroundColor = [UIColor clearColor];
    
    PFObject *conversation = [conversationArray objectAtIndex:indexPath.row];
    
    NSDate *date = conversation[@"last_time"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    NSArray *participants = conversation[@"participants"];
    NSString *name = @"";
    for (PFUser *user in participants)
    {
        if (![user.objectId isEqualToString:selfUser.objectId])
        {
            name = [NSString stringWithFormat:@"%@, %@", name, [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]]];
        }
    }
    if (name.length>3)
    {
        NSRange range = NSMakeRange(0, 2);
        name = [name stringByReplacingCharactersInRange:range withString:@""];
    }
    else
    {
        name = @"No participants in conversation";
        cell.participantLabel.textColor = [UIColor primary_color];
    }
    
    cell.timeLabel.text = dateString;
    cell.participantLabel.text = name;
    cell.messageLabel.text = conversation[@"last_msg"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedConversation = [conversationArray objectAtIndex:indexPath.row];
    selectedParticipants = selectedConversation[@"participants"];
    [self performSegueWithIdentifier:@"chatsegue" sender:self];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [conversationArray removeAllObjects];
    conversationArray = [results mutableCopy];
    [self.conversationTable reloadData];
    
    if (conversationArray.count >0)
    {
        self.noConvLabel.hidden = YES;
    }
    else
    {
        self.noConvLabel.hidden = NO;
    }
}

- (void) noUserYet
{
    //to-do: ask user to sign up / log in then go to log in page
    [[[UIAlertView alloc] initWithTitle:@"You need a user account"
                                message:@"Please sign in first"
                               delegate:nil
                      cancelButtonTitle:@"Done"
                      otherButtonTitles:nil] show];
    UIViewController *centerViewController;
    centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings_nc"];
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chatsegue"]) {
        ChatView *controller = (ChatView *) segue.destinationViewController;
        controller.currentConversation = selectedConversation;
        controller.participants = selectedParticipants;
    }
    else if ([segue.identifier isEqualToString:@"chatinvitesegue"])
    {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
        self.navigationItem.backBarButtonItem=newBackButton;
    }
}

@end

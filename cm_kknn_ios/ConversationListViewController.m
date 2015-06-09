//
//  ConversationListViewController.m
//  SQuInt2014
//
//  Created by csjan on 10/13/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "ConversationListViewController.h"
#import <Parse/Parse.h>
#import "ConversationCellTableViewCell.h"
#import "ChatViewController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"

@interface ConversationListViewController ()

@end

NSString *chosen_conv_id;            //the selected conversation id
NSMutableArray *chosenParticipants;  //the participants to pass to chat
NSMutableDictionary *totalParticipantsList;    //list of participant arrays for all conversations
PFUser *currentUser;

@implementation ConversationListViewController
@synthesize conversation_array;
@synthesize pullrefresh;
@synthesize fromPersonDetailChat;
@synthesize preloaded_conv_id;
@synthesize preloadedChatParticipants;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    self.view.backgroundColor = [UIColor background];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.conversation_list_table.tableFooterView = [[UIView alloc] init];
    self.conversation_array = [[NSMutableArray alloc] init];
    self.no_conv_label.hidden = YES;
    chosenParticipants = [[NSMutableArray alloc] init];
    totalParticipantsList = [[NSMutableDictionary alloc] init];
    if ([PFUser currentUser])
    {
        currentUser = [PFUser currentUser];
    }
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.conversation_list_table addSubview:pullrefresh];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.conversation_list_table.userInteractionEnabled = NO;
    self.no_conv_label.hidden = YES;
    if (self.fromPersonDetailChat==1)
    {
        NSLog(@"bypassing conversation list: direct to chat");
        [self preload_chat_with_conv_id:preloaded_conv_id];
    }
    else
    {
        NSLog(@"non-direct chat, loading conv list");
        [self getConversations];
    }
    [self clearBadge];
}

- (void) viewDidLayoutSubviews
{
    if ([self.conversation_list_table respondsToSelector:@selector(layoutMargins)]) {
        self.conversation_list_table.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)refreshctrl:(id)sender
{
    [self getConversations];
    [(UIRefreshControl *)sender endRefreshing];
}

- (IBAction)back_to_people_button_tap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"conversation TABLE COUNT: %lu", (unsigned long)[self.conversation_array count]);
    return self.conversation_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationcell"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.conversation_card_view.backgroundColor = [UIColor whiteColor];
    cell.conversation_new_label.textColor = [UIColor accent_color];
    UIImage *msg_img = [UIImage imageNamed:@"new_msg.png"];
    msg_img = [msg_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.conversation_new_image setTintColor:[UIColor accent_color]];
    cell.conversation_new_image.image = msg_img;
    cell.conversation_new_label.textColor = [UIColor light_txt];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:cell.conversation_bottom_view.bounds];
    cell.conversation_bottom_view.layer.masksToBounds = NO;
    cell.conversation_bottom_view.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.conversation_bottom_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    cell.conversation_bottom_view.layer.shadowOpacity = 0.3f;
    cell.conversation_bottom_view.layer.shadowPath = shadowPath.CGPath;
    
    //data
    PFObject *conversation = [self.conversation_array objectAtIndex:indexPath.row];
    
    //get the participant list
    NSArray *participants = [conversation objectForKey:@"participants"];
    [totalParticipantsList setObject:participants forKey:conversation.objectId];
    NSString *name = @"";
    for (PFUser *user in participants)
    {
        if (![user.objectId isEqualToString:currentUser.objectId])
        {
            name = [NSString stringWithFormat:@"%@, %@", name, user.username];
        }
    }
    NSRange range = NSMakeRange(0, 2);
    name = [name stringByReplacingCharactersInRange:range withString:@""];
    cell.conversation_name_label.text = name;
    
    NSDate *date = conversation[@"last_time"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    cell.conversation_time_label.text = dateString;
    cell.conversation_msg_label.text = conversation[@"last_msg"];
    
    //temporary: until unread msg is implemented
    cell.conversation_new_image.hidden=YES;
    cell.conversation_new_label.hidden=YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *conversation = [self.conversation_array objectAtIndex:indexPath.row];
    chosen_conv_id = conversation.objectId;
    chosenParticipants = [totalParticipantsList objectForKey:chosen_conv_id];
    [self performSegueWithIdentifier:@"chatsegue" sender:self];
}

#pragma mark - Data

- (void) preload_chat_with_conv_id: (NSString *) conv_id_from_preload
{
    fromPersonDetailChat = 0;
    chosen_conv_id = conv_id_from_preload;
    chosenParticipants = self.preloadedChatParticipants;
    
    [self performSegueWithIdentifier:@"chatsegue" sender:self];
}

//get conversations and put into conversation_array, or if none, display the empty label
- (void) getConversations
{
    PFUser *currentuser = [PFUser currentUser];
    [self getConversations:self withUser:currentuser];
}

- (void)processData:(NSArray *)results {
    NSLog(@"received conversation data");
    [self.conversation_array removeAllObjects];
    [totalParticipantsList removeAllObjects];
    if ([results count] == 0)
    {
        self.no_conv_label.hidden = NO;
    }
    else
    {
        self.no_conv_label.hidden = YES;
    }
    self.conversation_array = [results mutableCopy];
    [self.conversation_list_table reloadData];
    self.conversation_list_table.userInteractionEnabled = YES;
}

- (void) clearBadge
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *controller = [segue destinationViewController];
    controller.conversation_objid = chosen_conv_id;
    controller.participants = chosenParticipants;
}

@end

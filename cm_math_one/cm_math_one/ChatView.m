//
//  ChatView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChatView.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ChatBroadcastCell.h"
#import "ChatYouCell.h"
#import "ChatMeCell.h"

NSMutableArray *chatArray;
PFUser *loggedinUser;

@implementation ChatView
@synthesize currentConversation;
@synthesize participants;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    chatArray = [[NSMutableArray alloc] init];
    if ([PFUser currentUser])
    {
        loggedinUser = [PFUser currentUser];
    }

    //styling
    
    //data
    [self getChat:self withConversation:self.currentConversation];
}

- (IBAction)sendChatButtonTap:(UIButton *)sender {
    if (self.inputTextField.text.length >=1)
    {
        [self sendChat:self withAuthor:loggedinUser withContent:self.inputTextField.text withConversation:currentConversation];
    }
}

- (IBAction)editButtonTap:(UIBarButtonItem *)sender {
    //to-do: go to group chat options view
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMeCell *mecell = [tableView dequeueReusableCellWithIdentifier:@"chatmecell"];
    ChatYouCell *youcell = [tableView dequeueReusableCellWithIdentifier:@"chatyoucell"];
    ChatBroadcastCell *broadcastcell = [tableView dequeueReusableCellWithIdentifier:@"chatbroadcastcell"];
    
    //styling
    mecell.selectionStyle = UITableViewCellSelectionStyleNone;
    youcell.selectionStyle = UITableViewCellSelectionStyleNone;
    broadcastcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //data
    PFObject *chat = [chatArray objectAtIndex:indexPath.row];
    PFUser *author = chat[@"author"];
    NSDate *date = chat.createdAt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *contentString = chat[@"content"];
    BOOL theySaid;
    
    if ([author.objectId isEqualToString:loggedinUser.objectId])
    {
        theySaid = NO;
    }
    else
    {
        theySaid = YES;
    }
    
    NSNumber *bc = chat[@"broadcast"];
    int bcInt = [bc intValue];
    if (bcInt == 1)
    {
        broadcastcell.contentLabel.text = contentString;
        return broadcastcell;
    }
    else if (theySaid)
    {
        //msg is them to me
        youcell.contentLabel.text = contentString;
        youcell.timeLabel.text = dateString;
        youcell.authorLabel.text = author.username;
        return youcell;
    }
    else
    {
        //msg is me to them
        mecell.contentLabel.text = contentString;
        mecell.timeLabel.text = dateString;
        return mecell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (void)processChatList: (NSArray *) results
{
    [chatArray removeAllObjects];
    chatArray = [results mutableCopy];
    [self.chatTable reloadData];
    
    //scroll the table to bottom row (if not empty table)
    if ([chatArray count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([chatArray count] - 1) inSection:0];
        [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void) processChatUploadWithConversation: (PFObject *)conversation withContent: (NSString *)content
{
    NSLog(@"received chat upload callback, sending push");
    
    NSString *pushstr = [NSString stringWithFormat:@"%@: %@",loggedinUser.username,content];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushstr, @"alert",
                          @"Increment", @"badge",
                          @"default", @"sound",
                          nil];
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" containedIn:self.participants];
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:data];
    [push sendPushInBackground];
    
    //interface: reload chat list and reset text field
    [self getChat:self withConversation:self.currentConversation];
    self.inputTextField.text = @"";
    self.inputTextField.placeholder = @"Type message here..";
}

@end

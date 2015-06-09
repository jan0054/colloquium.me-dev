//
//  GroupChatOptions.m
//  KKNN24
//
//  Created by csjan on 6/9/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "GroupChatOptions.h"
#import "GroupChatInviteCell.h"

@implementation GroupChatOptions

- (IBAction)leaveConversationButtonTap:(UIButton *)sender {
    NSLog(@"leave conversation tapped");
}
- (IBAction)addConversationButtonTap:(UIButton *)sender {
    NSLog(@"add people tapped");
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
    GroupChatInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invitecell"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end

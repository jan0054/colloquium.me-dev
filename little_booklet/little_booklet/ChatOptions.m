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
    self.searchField.delegate = self;
    
    //styling
    //self.view.layer.cornerRadius = 3;
    self.inviteeTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIImage *img = [UIImage imageNamed:@"search48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setTintColor:[UIColor lightGrayColor]];
    [self.searchButton setImage:img forState:UIControlStateNormal];
    self.searchBackgroundView.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;

    
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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_leave_title", nil)
                                message:NSLocalizedString(@"alert_leave_detail", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"alert_leave", nil), nil] show];
    
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

- (IBAction)searchButtonTap:(UIButton *)sender {
    if (self.searchField.text.length >0)
    {
        NSString *search_str = self.searchField.text.lowercaseString;
        
        NSArray *separateBySpace = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *processedWords = [[NSMutableArray alloc] init];
        for (NSString *componentString in separateBySpace)
        {
            CFStringRef compstr = (__bridge CFStringRef)(componentString);
            NSString *lang = CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage(compstr, CFRangeMake(0, componentString.length)));
            if ([lang isEqualToString:@"zh-Hant"])
            {
                //中文
                for (int i=1; i<=componentString.length; i++)
                {
                    NSString *chcomp = [componentString substringWithRange:NSMakeRange(i-1, 1)];
                    [processedWords addObject:chcomp];
                }
            }
            else
            {
                //not中文
                [processedWords addObject:componentString];
            }
        }
        
        [self getInviteeList:self withoutUsers:receivedParticipants withSearch:processedWords];
        NSLog(@"PROCESSEDWORDS:%lu, %@", processedWords.count, processedWords);
    }
    [self.searchField resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.searchField) [self resetSearch];
    return YES;
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
    [cell.inviteButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
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

- (void)resetSearch
{
    NSLog(@"Search reset called");
    [self getInviteeList:self withoutUsers:receivedParticipants];
}


@end

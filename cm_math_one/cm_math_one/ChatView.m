//
//  ChatView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChatView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ChatBroadcastCell.h"
#import "ChatYouCell.h"
#import "ChatMeCell.h"
#import "ChatOptions.h"

NSMutableArray *chatArray;
PFUser *loggedinUser;

@implementation ChatView
@synthesize currentConversation;
@synthesize participants;
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    chatArray = [[NSMutableArray alloc] init];
    self.chatTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.chatTable.estimatedRowHeight = 120.0;
    self.chatTable.rowHeight = UITableViewAutomaticDimension;

    
    if ([PFUser currentUser])
    {
        loggedinUser = [PFUser currentUser];
    }
    self.inputTextField.delegate = self;
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.chatTable addSubview:pullrefresh];
    
    //styling
    self.inputBackground.backgroundColor = [UIColor light_bg];
    [self.sendChatButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;

}

- (IBAction)sendChatButtonTap:(UIButton *)sender {
    if (self.inputTextField.text.length >=1)
    {
        [self sendChat:self withAuthor:loggedinUser withContent:self.inputTextField.text withConversation:currentConversation];
        self.sendChatButton.enabled = NO;
    }
}

- (IBAction)editButtonTap:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"chatoptionsegue" sender:self];
}

- (void)refreshctrl:(id)sender
{
    [self getChat:self withConversation:self.currentConversation];
    [self updateConversationObject];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.chatTable respondsToSelector:@selector(layoutMargins)]) {
        self.chatTable.layoutMargins = UIEdgeInsetsZero;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushreload:) name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self getChat:self withConversation:self.currentConversation];
    [self updateConversationObject];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event   //dismiss keyboard when touched outside
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.inputTextField isFirstResponder] && [touch view] != self.inputTextField) {
        [self.inputTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
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
    if ([mecell respondsToSelector:@selector(layoutMargins)]) {
        mecell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([youcell respondsToSelector:@selector(layoutMargins)]) {
        youcell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([broadcastcell respondsToSelector:@selector(layoutMargins)]) {
        broadcastcell.layoutMargins = UIEdgeInsetsZero;
    }
    mecell.timeLabel.textColor = [UIColor secondary_text];
    youcell.timeLabel.textColor = [UIColor secondary_text];
    
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
        broadcastcell.contentLabel.textColor = [UIColor secondary_text];
        return broadcastcell;
    }
    else if (theySaid)
    {
        //msg is them to me
        youcell.contentLabel.text = contentString;
        youcell.timeLabel.text = dateString;
        youcell.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
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
    self.sendChatButton.enabled = YES;
    NSLog(@"received chat upload callback, sending push");
    
    NSString *pushstr = [NSString stringWithFormat:@"%@ %@: %@", loggedinUser[@"first_name"], loggedinUser[@"last_name"], content];
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
    self.inputTextField.placeholder = NSLocalizedString(@"chat_input_holder", nil);
}

- (void) pushreload: (id) sender  //in-app push receiver
{
    [self updateConversationObject];
}

- (void)updateConversationObject
{
    [self.currentConversation fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.currentConversation = object;
        [self getChat:self withConversation:self.currentConversation];
        self.participants = self.currentConversation[@"participants"];
    }];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints: keyboard up");
    
    self.inputRowBottom.constant = height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([chatArray count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([chatArray count] - 1) inSection:0];
        [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"Updating constraints: keyboard down");
    
    self.inputRowBottom.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([chatArray count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([chatArray count] - 1) inSection:0];
        [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chatoptionsegue"])
    {
        //to-do: group chat stuff
        ChatOptions *controller = (ChatOptions *)[segue destinationViewController];
        //controller.data_delegate = self;
        controller.conversation = self.currentConversation;
        controller.receivedParticipants = self.participants;
    }
}

@end

//
//  ChatViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "ChatViewController.h"
#import "UIColor+ProjectColors.h"
#import "ChatMeCellTableViewCell.h"
#import "ChatYouCellTableViewCell.h"

@interface ChatViewController ()

@end

PFObject *conversation;

@implementation ChatViewController
@synthesize is_new_conv;
@synthesize conversation_objid;
@synthesize chat_array;
@synthesize chat_table_array;
@synthesize otherguy;
@synthesize pullrefresh;
@synthesize ab_self;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chat_input_box.delegate = self;
    self.chat_array = [[NSMutableArray alloc] init];
    self.chat_table_array = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor background];
    self.chat_table.backgroundColor = [UIColor clearColor];
    self.send_chat_button.titleLabel.textColor = [UIColor accent_color];
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.chat_table addSubview:pullrefresh];
    
    self.chat_table.estimatedRowHeight = 69;
    self.chat_table.rowHeight = UITableViewAutomaticDimension;
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushreload:) name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self get_chat_info];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints: keyboard up");

    self.textfieldbottom.constant = height+5;
    self.sendmessagebottom.constant = height+5;
    self.tablebottom.constant = height+50;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([self.chat_table_array count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
        [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"Updating constraints: keyboard down");
    
    self.textfieldbottom.constant = 5;
    self.sendmessagebottom.constant = 5;
    self.tablebottom.constant = 50;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([self.chat_table_array count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
        [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_chat_info];
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

//dismiss keyboard when touched outside
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.chat_input_box isFirstResponder] && [touch view] != self.chat_input_box) {
        [self.chat_input_box resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

//controls view sliding up when editing text field
- (void) textFieldDidBeginEditing:(UITextField *)textView
{
    [self animateTextField: textView up: YES];
}
- (void) textFieldDidEndEditing:(UITextField *)textView
{
    [self animateTextField: textView up: NO];
}
- (void) animateTextField: (UITextField *) textView up: (BOOL) up
{
    /*
    const int movementDistance = 197; // sliding distance
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    */
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"chat table count: %ld",(unsigned long)[self.chat_table_array count]);
    return [self.chat_table_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMeCellTableViewCell *chatmecell = [tableView dequeueReusableCellWithIdentifier:@"chatmecell"];
    ChatYouCellTableViewCell *chatyoucell = [tableView dequeueReusableCellWithIdentifier:@"chatyoucell"];
    
    chatmecell.selectionStyle = UITableViewCellSelectionStyleNone;
    chatyoucell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *chat_dict = [self.chat_table_array objectAtIndex:indexPath.row];
    NSNumber *fromme_nsnum = [chat_dict valueForKey:@"fromme"];
    int fromme = [fromme_nsnum intValue];
    if (fromme==0)
    {
        //msg is them to me
        chatyoucell.chat_content_label.text = [chat_dict objectForKey:@"content"];
        chatyoucell.chat_time_label.text = [chat_dict objectForKey:@"time"];
        chatyoucell.chat_person_label.text = [NSString stringWithFormat:@"%@:",self.other_guy_name];
        

        //chatyoucell.chat_content_label.backgroundColor = [UIColor whiteColor];
        //chatyoucell.chat_content_label.layer.cornerRadius = 5;
        //[chatyoucell.chat_content_label sizeToFit];
        return chatyoucell;
    }
    else
    {
        //msg is me to them
        chatmecell.chat_content_label.text = [chat_dict objectForKey:@"content"];
        chatmecell.chat_time_label.text = [chat_dict objectForKey:@"time"];
        

        
        //chatmecell.chat_content_label.backgroundColor = [UIColor whiteColor];
        //chatmecell.chat_content_label.layer.cornerRadius = 5;
        
        //[chatmecell.chat_content_label sizeToFit];
        return chatmecell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //do nothing when tapping chat elements (yet)
    [self.chat_input_box resignFirstResponder];
}

- (void) pushreload: (id) sender
{
    [self get_chat_info];
}

- (void) get_chat_info
{
    //first check if the other participant still has their chat_on set
    NSNumber *chat_on_num = otherguy[@"chat_on"];
    int chat_on = [chat_on_num intValue];
    if (chat_on != 1)
    {
        self.send_chat_button.enabled = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"This user has turned off chat"
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        self.send_chat_button.enabled = YES;
    }
    
    self.chat_table_array = [[NSMutableArray alloc] init];
    
    PFObject *the_conv = [PFObject objectWithoutDataWithClassName:@"conversation" objectId:self.conversation_objid];
    conversation = the_conv;
    
    PFQuery *query = [PFQuery queryWithClassName:@"chat"];
    [query whereKey:@"conversation" equalTo:the_conv];
    [query includeKey:@"from"];
    [query includeKey:@"to"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"chat query success with # of chat elements: %ld", (unsigned long)[objects count]);
        //reset the arrays used to store chat elements
        [self.chat_table_array removeAllObjects];
        
        //loop for each chat element
        for (PFObject *chat_obj in objects)
        {
            NSLog(@"FOR LOOP - chat objects");
            
            NSDate *msg_time = chat_obj.createdAt;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat: @"MM-dd HH:mm"];
            NSString *dateString = [dateFormat stringFromDate:msg_time];
            NSLog(@"DATE:%@", dateString);
            NSMutableDictionary *chat_dict = [[NSMutableDictionary alloc] init];
            
            [chat_dict setObject:chat_obj[@"content"] forKey:@"content"];
            [chat_dict setObject:dateString forKey:@"time"];
            PFUser *from_person = chat_obj[@"from"];
            PFUser *to_person = chat_obj[@"to"];
            NSString *from_id = from_person.objectId;
            PFUser *self_user = [PFUser currentUser];
            NSString *self_id =self_user.objectId;
            if ([from_id isEqualToString:self_id])
            {
                [chat_dict setValue:[NSNumber numberWithInt:1] forKey:@"fromme"];
                NSLog(@"msg is from me");
            }
            else
            {
                [chat_dict setValue:[NSNumber numberWithInt:0] forKey:@"fromme"];
                NSLog(@"msg is from other guy");
            }
            
            [self.chat_table_array addObject:chat_dict];
        }
        
        [self.chat_table reloadData];
        
        //clear unread count
        if ([ab_self isEqualToString:@"a"])
        {
            conversation[@"user_a_unread"] = @0;
        }
        else if ([ab_self isEqualToString:@"b"])
        {
            conversation[@"user_b_unread"] = @0;
        }
        [conversation saveInBackground];

        //scroll the table to bottom row (if not empty table)
        if ([self.chat_table_array count] >=1)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
            [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

    }];
   
}

- (IBAction)send_chat_button_tap:(UIButton *)sender {
    
    NSString *content = self.chat_input_box.text;

    PFObject *new_chat = [PFObject objectWithClassName:@"chat"];
    new_chat[@"content"] = content;
    new_chat[@"conversation"] = conversation;
    new_chat[@"from"] = [PFUser currentUser];
    new_chat[@"to"] = otherguy;
    [new_chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new chat uploaded successfully");
            
            //now send the push notification
            NSString *pushstr = [NSString stringWithFormat:@"%@: %@",otherguy.username,content];
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  pushstr, @"alert",
                                  @"Increment", @"badge",
                                  @"default", @"sound",
                                  nil];
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:otherguy];
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery]; // Set our Installation query
            //[push setMessage:pushstr];
            [push setData:data];
            [push sendPushInBackground];
        }
        else
        {
            NSLog(@"push error:%@",error);
        }
        
        [self get_chat_info];
    }];
    
    self.chat_input_box.text = @"";
    self.chat_input_box.placeholder = @"Type message here..";
    
    //change the parent conversation, last message, last message time, and unread count
    conversation[@"last_time"] = [NSDate date];
    conversation[@"last_msg"] = content;
    if ([ab_self isEqualToString:@"a"])
    {
        [conversation incrementKey:@"user_b_unread"];
    }
    else if ([ab_self isEqualToString:@"b"])
    {
        [conversation incrementKey:@"user_a_unread"];
    }

    [conversation saveInBackgroundWithBlock:^(BOOL succeededa, NSError *errora) {
        if (succeededa)
        {
            NSLog(@"new chat changed conversation successfully");
        }
        else
        {
            NSLog(@"error:%@",errora);
        }

    }];
    
}




@end

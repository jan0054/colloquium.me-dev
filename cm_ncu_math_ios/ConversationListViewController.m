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

@interface ConversationListViewController ()

@end

NSString *chosen_conv_id;
NSString *chosen_conv_other_guy_id;
NSString *chosen_conv_other_guy_name;
PFUser *chosen_guy;
NSString *ab_self;

@implementation ConversationListViewController
@synthesize conversation_array;
@synthesize talked_to_array;
@synthesize talked_from_array;
@synthesize pullrefresh;
@synthesize from_preloaded;
@synthesize preloaded_conv_id;
@synthesize preloaded_abself;
@synthesize preloaded_isnewconv;
@synthesize preloaded_otherguy;
@synthesize preloaded_otherguy_name;
@synthesize preloaded_otherguy_objid;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    self.view.backgroundColor = [UIColor background];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.conversation_list_table.tableFooterView = [[UIView alloc] init];
    self.conversation_array = [[NSMutableArray alloc] init];
    self.talked_to_array = [[NSMutableArray alloc] init];
    self.talked_from_array = [[NSMutableArray alloc] init];
    self.no_conv_label.hidden = YES;
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.conversation_list_table addSubview:pullrefresh];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.conversation_list_table.userInteractionEnabled = NO;
    self.no_conv_label.hidden = YES;
    if (self.from_preloaded==1)
    {
        NSLog(@"bypassing conv list: direct to chat");
        [self preload_chat_with_conv_id:preloaded_conv_id];
    }
    else
    {
        NSLog(@"non-direct chat, loading conv list");
        [self get_conversations];
    }
}

- (void) viewDidLayoutSubviews
{
    if ([self.conversation_list_table respondsToSelector:@selector(layoutMargins)]) {
        self.conversation_list_table.layoutMargins = UIEdgeInsetsZero;
    }
}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    [self get_conversations];
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

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
    ConversationCellTableViewCell *conversationcell = [tableView dequeueReusableCellWithIdentifier:@"conversationcell"];
    
    //styling
    if ([conversationcell respondsToSelector:@selector(layoutMargins)]) {
        conversationcell.layoutMargins = UIEdgeInsetsZero;
    }
    conversationcell.selectionStyle = UITableViewCellSelectionStyleNone;
    conversationcell.conversation_card_view.backgroundColor = [UIColor whiteColor];
    conversationcell.conversation_new_label.textColor = [UIColor accent_color];
    UIImage *msg_img = [UIImage imageNamed:@"new_msg.png"];
    msg_img = [msg_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [conversationcell.conversation_new_image setTintColor:[UIColor accent_color]];
    conversationcell.conversation_new_image.image = msg_img;
    conversationcell.conversation_new_label.textColor = [UIColor light_txt];
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:conversationcell.conversation_bottom_view.bounds];
    conversationcell.conversation_bottom_view.layer.masksToBounds = NO;
    conversationcell.conversation_bottom_view.layer.shadowColor = [UIColor blackColor].CGColor;
    conversationcell.conversation_bottom_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    conversationcell.conversation_bottom_view.layer.shadowOpacity = 0.3f;
    conversationcell.conversation_bottom_view.layer.shadowPath = shadowPath.CGPath;
    
    //data
    PFObject *conv = [self.conversation_array objectAtIndex:indexPath.row];
    PFObject *user_a = conv[@"user_a"];
    PFObject *user_b = conv[@"user_b"];
    PFUser *currentuser = [PFUser currentUser];
    if ([user_a.objectId isEqualToString:currentuser.objectId])
    {
        NSString *namestr = [NSString stringWithFormat:@"%@ %@ (%@)", user_b[@"first_name"], user_b[@"last_name"], user_b[@"username"]];
        conversationcell.conversation_name_label.text = namestr;
        //since user is a, check unread msgs for a
        NSNumber *uansnum = conv[@"user_a_unread"];
        int uaint = [uansnum intValue];
        if (uaint==0)
        {
            conversationcell.conversation_new_image.hidden=YES;
            conversationcell.conversation_new_label.hidden=YES;
        }
    }
    else if ([user_b.objectId isEqualToString:currentuser.objectId])
    {
        NSString *namestr = [NSString stringWithFormat:@"%@ %@ (%@)", user_a[@"first_name"], user_a[@"last_name"], user_a[@"username"]];
        conversationcell.conversation_name_label.text = namestr;
        //since user is b, check unread msgs for b
        NSNumber *ubnsnum = conv[@"user_b_unread"];
        int ubint = [ubnsnum intValue];
        if (ubint==0)
        {
            conversationcell.conversation_new_image.hidden=YES;
            conversationcell.conversation_new_label.hidden=YES;
        }
    }
    conversationcell.conversation_msg_label.text = conv[@"last_msg"];
    NSDate *date = conv[@"last_time"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    conversationcell.conversation_time_label.text = dateString;
    
    return conversationcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chosen_conv = [self.conversation_array objectAtIndex:indexPath.row];
    chosen_conv_id = chosen_conv.objectId;
    
    PFUser *cur_user = [PFUser currentUser];
    PFUser *user_a = chosen_conv[@"user_a"];
    PFUser *user_b = chosen_conv[@"user_b"];
    if ([user_a.objectId isEqualToString:cur_user.objectId])
    {
        chosen_conv_other_guy_id = user_b.objectId;
        chosen_conv_other_guy_name = user_b[@"username"];
        chosen_guy = user_b;
        ab_self = @"a";
    }
    else if ([user_b.objectId isEqualToString:cur_user.objectId])
    {
        chosen_conv_other_guy_id = user_a.objectId;
        chosen_conv_other_guy_name = user_a[@"username"];
        chosen_guy = user_a;
        ab_self = @"b";
    }
    
    [self performSegueWithIdentifier:@"chatsegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *destination = [segue destinationViewController];
    destination.conversation_objid = chosen_conv_id;
    destination.is_new_conv = 0;
    destination.other_guy_objid = chosen_conv_other_guy_id;
    destination.other_guy_name = chosen_conv_other_guy_name;
    destination.otherguy = chosen_guy;
    destination.ab_self = ab_self;
}

- (void) preload_chat_with_conv_id: (NSString *) conv_id_from_preload
{
    from_preloaded = 0;
    chosen_conv_id = conv_id_from_preload;
    chosen_conv_other_guy_id = self.preloaded_otherguy_objid;
    chosen_guy = self.preloaded_otherguy;
    chosen_conv_other_guy_name = self.preloaded_otherguy_name;
    ab_self = self.preloaded_abself;
    
    [self performSegueWithIdentifier:@"chatsegue" sender:self];
}

//get conversations and put into conversation_array, or if none, display the empty label
- (void) get_conversations
{
    NSLog(@"getting conversation data");
    
    PFUser *currentuser = [PFUser currentUser];
    //subquery where user_a matches currentuser
    PFQuery *subquery_a = [PFQuery queryWithClassName:@"Conversation"];
    [subquery_a whereKey:@"user_a" equalTo:currentuser];
    //subquery where user_b matches currentuser
    PFQuery *subquery_b = [PFQuery queryWithClassName:@"Conversation"];
    [subquery_b whereKey:@"user_b" equalTo:currentuser];
    //compound query
    PFQuery *conv_query = [PFQuery orQueryWithSubqueries:@[subquery_a, subquery_b]];
    [conv_query orderByDescending:@"last_time"];
    [conv_query includeKey:@"user_a"];
    [conv_query includeKey:@"user_b"];
    /*
    [self.conversation_array removeAllObjects];
    self.conversation_array = [[conv_query findObjects] mutableCopy];
    if ([self.conversation_array count] == 0)
    {
        self.no_conv_label.hidden = NO;
    }
    else
    {
        self.no_conv_label.hidden = YES;
    }
    [self.conversation_list_table reloadData];
    self.conversation_list_table.userInteractionEnabled = YES;
     */
    
    [conv_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self.conversation_array removeAllObjects];
        if ([objects count] == 0)
        {
            self.no_conv_label.hidden = NO;
        }
        else
        {
            self.no_conv_label.hidden = YES;
        }
        self.conversation_array = [objects mutableCopy];
        [self.conversation_list_table reloadData];
        self.conversation_list_table.userInteractionEnabled = YES;
    }];
}

//close conversation list view
- (IBAction)back_to_people_button_tap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

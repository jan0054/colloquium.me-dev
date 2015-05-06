//
//  PeopleTabViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "PeopleTabViewController.h"
#import "PersonDetailViewController.h"
#import "UIColor+ProjectColors.h"
#include <math.h>
#include "ConversationListViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface PeopleTabViewController ()

@end

NSString *tapped_person_objid;
int unread_total;
int unread_one;
int unread_two;
NSString *search_str;
NSMutableArray *search_array;

@implementation PeopleTabViewController
@synthesize person_array;
@synthesize from_event;
@synthesize from_message;
@synthesize event_author_id;
@synthesize conv_id;
@synthesize pullrefresh;
@synthesize preload_chat_abself;
@synthesize preload_chat_isnewconv;
@synthesize preload_chat_otherguy;
@synthesize preload_chat_otherguy_name;
@synthesize preload_chat_otherguy_objid;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.person_array = [[NSMutableArray alloc] init];
    search_array = [[NSMutableArray alloc] init];
    self.peopletable.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.chat_float.layer.cornerRadius = 15;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.peopletable.tableFooterView = [[UIView alloc] init];
    self.search_input.delegate = self;
    search_str = @"";
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.chat_float.bounds];
    self.chat_float.layer.masksToBounds = NO;
    self.chat_float.layer.shadowColor = [UIColor blackColor].CGColor;
    self.chat_float.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.chat_float.layer.shadowOpacity = 0.3f;
    self.chat_float.layer.shadowPath = shadowPath.CGPath;
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.peopletable addSubview:pullrefresh];

    
    [self get_person_info];
    

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //monitor in-app receiving push notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushreload:) name:@"gotchatinapp" object:nil];
    
    //check login status to determine chat button display
    if (![PFUser currentUser])
    {
        self.chat_float.hidden=YES;
        self.chat_float.userInteractionEnabled=NO;
    }
    else
    {
        PFUser *self_obj = [PFUser currentUser];
        NSNumber *is_person = self_obj[@"isperson"];
        int is_person_int = [is_person intValue];
        if (is_person_int ==1)
        {
            self.chat_float.hidden=NO;
            self.chat_float.userInteractionEnabled=YES;
        }
        else
        {
            self.chat_float.hidden=YES;
            self.chat_float.userInteractionEnabled=NO;
        }
    }
    
    if (from_event==1)
    {
        [self chose_person_with_id:event_author_id];
    }
    else if (from_message==1)
    {
        [self chose_conv_with_id:conv_id];
    }
    [self check_unread_count];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotchatinapp" object:nil];
}

- (void) viewDidLayoutSubviews
{
    if ([self.peopletable respondsToSelector:@selector(layoutMargins)]) {
        self.peopletable.layoutMargins = UIEdgeInsetsZero;
    }
}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_person_info];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

//received push notificatio while in-app
- (void) pushreload: (id) sender
{
    [self check_unread_count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.person_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCellTableViewCell *personcell = [tableView dequeueReusableCellWithIdentifier:@"personcell"];
    PFObject *person = [self.person_array objectAtIndex:indexPath.row];
    NSString *lastname = person[@"last_name"];
    NSString *firstname = person[@"first_name"];
    NSString *institution = person[@"institution"];
    personcell.name_label.text = [NSString stringWithFormat:@"%@, %@",lastname, firstname];
    personcell.institution_label.text = institution;
    if ([personcell respondsToSelector:@selector(layoutMargins)]) {
        personcell.layoutMargins = UIEdgeInsetsZero;
    }
    personcell.selectionStyle = UITableViewCellSelectionStyleNone;
    personcell.person_trim_view.backgroundColor = [UIColor light_blue];
    personcell.person_card_view.backgroundColor = [UIColor nu_deep_blue];
    personcell.person_card_view.alpha = 0.8;
    personcell.person_card_view.layer.cornerRadius = 2;
    [personcell.person_detail_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateNormal];
    [personcell.person_detail_button setTitleColor:[UIColor nu_bright_orange] forState:UIControlStateHighlighted];
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:personcell.person_card_view.bounds];
    personcell.person_card_view.layer.masksToBounds = NO;
    personcell.person_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    personcell.person_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    personcell.person_card_view.layer.shadowOpacity = 0.3f;
    personcell.person_card_view.layer.shadowPath = shadowPath.CGPath;

    
    return personcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void) get_person_info
{
    PFQuery *personquery = [PFQuery queryWithClassName:@"person"];
    [personquery orderByAscending:@"last_name"];
    [personquery setLimit:500];
    if (search_str.length > 1)
    {
        [personquery whereKey:@"words" containsAllObjectsInArray:search_array];
        NSLog(@"PERSONQUERY did do search");
    }
    [personquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"person query success: %lu", (unsigned long)[objects count]);
        [self.person_array removeAllObjects];
        for (PFObject *person_obj in objects)
        {
            //check if the person is for debug purposes only and not to be displayed
            NSNumber *dbug_person = person_obj[@"debug"];
            int dbug_person_intval = [dbug_person intValue];
            if ( dbug_person_intval != 1)
            {
                [self.person_array addObject:person_obj];
            }
        }
        [self.peopletable reloadData];
    }];

}

- (IBAction)person_detail_button_tap:(UIButton *)sender {
    PersonCellTableViewCell *cell = (PersonCellTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.peopletable indexPathForCell:cell];
    NSLog(@"people_detail_tap: %ld", (long)tapped_path.row);
    PFObject *tapped_person = [self.person_array objectAtIndex:tapped_path.row];
    [self chose_person_with_id:tapped_person.objectId];
    
}

- (void) chose_person_with_id: (NSString *)objid
{
    self.from_event=0;
    tapped_person_objid = objid;
    [self performSegueWithIdentifier:@"persondetailsegue" sender:self];
}

- (void) chose_conv_with_id: (NSString *)objid
{
    [self performSegueWithIdentifier:@"conversationsegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"persondetailsegue"])
    {
        PersonDetailViewController *destination = [segue destinationViewController];
        destination.person_objid = tapped_person_objid;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Attendees" style:UIBarButtonItemStyleBordered target:nil action:nil];
        [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
        self.navigationItem.backBarButtonItem = backButton;
    }
    else if ([segue.identifier isEqualToString:@"conversationsegue"])
    {
        if (self.from_message==1)
        {
            self.from_message = 0;
            UINavigationController *destination_navcon = [segue destinationViewController];
            ConversationListViewController *destination = [destination_navcon.viewControllers objectAtIndex:0];
            destination.from_preloaded = 1;
            destination.preloaded_conv_id = conv_id;
            destination.preloaded_abself = self.preload_chat_abself;
            destination.preloaded_isnewconv = self.preload_chat_isnewconv;
            destination.preloaded_otherguy = self.preload_chat_otherguy;
            destination.preloaded_otherguy_name = self.preload_chat_otherguy_name;
            destination.preloaded_otherguy_objid = self.preload_chat_otherguy_objid;
        }
    }
}

- (void) check_unread_count
{
    unread_total = 0;
    if ([PFUser currentUser])
    {
        PFUser *currentuser = [PFUser currentUser];
        
        PFQuery *query = [PFQuery queryWithClassName:@"conversation"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"user_a"];
        [query includeKey:@"user_b"];
        [query whereKey:@"user_a" equalTo:currentuser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"conversation query one success with count: %lu", (unsigned long)[objects count]);
            for (PFObject *object in objects)
            {
                NSNumber *unreadanum = object[@"user_a_unread"];
                unread_total += [unreadanum intValue];
                UITabBarItem *tbItem = (UITabBarItem *)[[self tabBarController].tabBar.items objectAtIndex:1];
                if (unread_total>0) {
                    unread_one = 1;
                    self.chat_float.titleLabel.text = @"New";
                    [self.chat_float setTitle:@"New" forState:UIControlStateNormal];
                    [self.chat_float setTitle:@"New" forState:UIControlStateSelected];
                    [self.chat_float setTitle:@"New" forState:UIControlStateHighlighted];
                }
                else
                {
                    unread_one = 0;
                    if (unread_two ==0) {
                        self.chat_float.titleLabel.text = @"";
                        [self.chat_float setTitle:@"" forState:UIControlStateNormal];
                        [self.chat_float setTitle:@"" forState:UIControlStateSelected];
                        [self.chat_float setTitle:@"" forState:UIControlStateHighlighted];
                        
                    }
                }
                
            }
        }];
        
        PFQuery *query_two = [PFQuery queryWithClassName:@"conversation"];
        [query_two orderByDescending:@"createdAt"];
        [query_two includeKey:@"user_a"];
        [query_two includeKey:@"user_b"];
        [query_two whereKey:@"user_b" equalTo:currentuser];
        [query_two findObjectsInBackgroundWithBlock:^(NSArray *objectss, NSError *error) {
            NSLog(@"conversation query two success with count: %lu", (unsigned long)[objectss count]);
            for (PFObject *object in objectss)
            {
                NSNumber *unreadanum = object[@"user_b_unread"];
                unread_total += [unreadanum intValue];
                UITabBarItem *tbItem = (UITabBarItem *)[[self tabBarController].tabBar.items objectAtIndex:1];
                if (unread_total>0) {
                    unread_two = 1;
                    self.chat_float.titleLabel.text = @"New";
                    [self.chat_float setTitle:@"New" forState:UIControlStateNormal];
                    [self.chat_float setTitle:@"New" forState:UIControlStateSelected];
                    [self.chat_float setTitle:@"New" forState:UIControlStateHighlighted];

                }
                else
                {
                    unread_two = 0;
                    if (unread_one ==0) {
                        self.chat_float.titleLabel.text = @"";
                        [self.chat_float setTitle:@"" forState:UIControlStateNormal];
                        [self.chat_float setTitle:@"" forState:UIControlStateSelected];
                        [self.chat_float setTitle:@"" forState:UIControlStateHighlighted];

                    }
                }
            }
        }];
    }
}

- (IBAction)chat_float_tap:(UIButton *)sender {
    [self performSegueWithIdentifier:@"conversationsegue" sender:self];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    float newx = recognizer.view.center.x + translation.x;
    float newy = recognizer.view.center.y + translation.y;
    if (newx*2 < recognizer.view.frame.size.width)
    {
        newx = (recognizer.view.frame.size.width)/2.0f;
    }
    else if (newx+((recognizer.view.frame.size.width)/2.0f) > 320 )
    {
        newx = 320 - ((recognizer.view.frame.size.width)/2.0f) ;
    }
    
    if( IS_IPHONE_5 )
    {
        if (newy + ((recognizer.view.frame.size.height)/2.0f)> 520)
        {
            newy = 520 - ((recognizer.view.frame.size.height)/2.0f) ;
        }
        else if ( newy < 64+((recognizer.view.frame.size.height)/2.0f))
        {
            newy = 64+((recognizer.view.frame.size.height)/2.0f) ;
        }
    }
    else
    {
        if (newy + ((recognizer.view.frame.size.height)/2.0f)> 432)
        {
            newy = 432 - ((recognizer.view.frame.size.height)/2.0f) ;
        }
        else if ( newy < 64+((recognizer.view.frame.size.height)/2.0f))
        {
            newy = 64+((recognizer.view.frame.size.height)/2.0f) ;
        }
    }
    
    recognizer.view.center = CGPointMake(newx,
                                         newy);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)cancel_search_button_tap:(UIButton *)sender {
    [self.search_input resignFirstResponder];
    self.search_input.text = @"";
    search_str = @"";
    [search_array removeAllObjects];
    [self get_person_info];
}

- (IBAction)do_search_button_tap:(UIButton *)sender {
    if (self.search_input.text.length >1)
    {
        search_str = self.search_input.text.lowercaseString;
        NSArray *wordsAndEmptyStrings = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        search_array = [words mutableCopy];
        [self get_person_info];
    }
    [self.search_input resignFirstResponder];
}

@end

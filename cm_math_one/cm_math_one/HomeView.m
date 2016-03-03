//
//  HomeView.m
//  cm_math_one
//
//  Created by csjan on 7/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "HomeView.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "HomeCell.h"
#import "DrawerView.h"

@interface HomeView ()

@end

NSMutableArray *followedEventsArray;
NSMutableDictionary *favedDictionary;   //object id and selection(0/1) key value pair
BOOL disableFav;

@implementation HomeView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    //init
    [super viewDidLoad];
    favedDictionary = [[NSMutableDictionary alloc] init];
    followedEventsArray = [[NSMutableArray alloc] init];
    disableFav = NO;
    if (!self.isSecondLevelEvent)
    {
        [self setupLeftMenuButton];
        self.navigationItem.title = NSLocalizedString(@"homescreen_title", nil);
    }
    else
    {
        self.navigationItem.title = self.parentEvent[@"name"];
        if (self.showDrawer)
        {
            [self setupLeftMenuButton];
        }
    }
    
    
    self.emptyLabel.text = NSLocalizedString(@"empty_label", nil);
    self.emptyLabel.textColor = [UIColor primary_text];
    [self.addEventButton setTitle:NSLocalizedString(@"add_event", nil) forState:UIControlStateNormal];
    [self.addEventButton setTitle:NSLocalizedString(@"add_event", nil) forState:UIControlStateHighlighted];
    [self.addEventButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.addEventButton setTitleColor:[UIColor dark_accent] forState:UIControlStateHighlighted];
    self.emptyLabel.hidden = YES;
    self.emptyLabel.userInteractionEnabled = NO;
    self.addEventButton.hidden = YES;
    self.addEventButton.userInteractionEnabled = NO;
    
    //styling
    self.homeTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.homeTable.estimatedRowHeight = 200.0;
    self.homeTable.rowHeight = UITableViewAutomaticDimension;
    self.homeTable.backgroundColor = [UIColor light_bg];
    self.view.backgroundColor = [UIColor light_bg];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
    
    //data
    if (!self.isSecondLevelEvent)   //normal home screen
    {
        [self getEventsFromLocalList:self];
    }
    else   //second level event screen
    {
        [self getChildrenEvents:self withParent:self.parentEvent];
    }
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.homeTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    if (!self.isSecondLevelEvent)
    {
        [self getEventsFromLocalList:self];
    }
    else
    {
        [self getChildrenEvents:self withParent:self.parentEvent];
    }

    [(UIRefreshControl *)sender endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isSecondLevelEvent)   //normal home screen
    {
        [self getEventsFromLocalList:self];
    }
    else   //second level event screen
    {
        [self getChildrenEvents:self withParent:self.parentEvent];
    }

}

- (void) viewDidLayoutSubviews
{
    if ([self.homeTable respondsToSelector:@selector(layoutMargins)]) {
        self.homeTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)addEventButtonTap:(UIButton *)sender {
    UIViewController *centerViewController;
    centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
}

- (IBAction)favoriteButtonTap:(UIButton *)sender {
    if (!disableFav)
    {
        HomeCell *cell = (HomeCell *)[[[sender superview] superview] superview];
        NSIndexPath *tapped_path = [self.homeTable indexPathForCell:cell];
        [self favButtonForTable:self.homeTable wasTappedAt:tapped_path];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [followedEventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homecell"];
    
    //data
    PFObject *event = [followedEventsArray objectAtIndex:indexPath.row];
    cell.homeObject = event;
    cell.nameLabel.text = event[@"name"];
    cell.contentLabel.text = event[@"content"];
    cell.organizerLabel.text = event[@"organizer"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM/d"];
    NSDate *sdate = event[@"start_time"];
    NSDate *edate = event[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", sstr, estr];
    cell.eventId = event.objectId;
    cell.eventName = event[@"name"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.backgroundCardView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    [cell.flairImage setTintColor:[UIColor primary_color_icon]];
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.timeLabel.backgroundColor = [UIColor clearColor];
    cell.contentLabel.backgroundColor = [UIColor clearColor];
    cell.organizerLabel.backgroundColor = [UIColor clearColor];
    cell.moreLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.moreLabel.textColor = [UIColor dark_accent];
    cell.timeLabel.textColor = [UIColor secondary_text];
    cell.organizerLabel.textColor = [UIColor secondary_text];
    cell.backgroundCardView.layer.shouldRasterize = YES;
    cell.backgroundCardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundCardView.layer.shadowColor = [UIColor shadow_color].CGColor;
    cell.backgroundCardView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    cell.backgroundCardView.layer.shadowOpacity = 0.3f;
    cell.backgroundCardView.layer.shadowRadius = 1.0f;
    [cell.favoriteButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [cell.favoriteButton setTitleColor:[UIColor light_accent] forState:UIControlStateHighlighted];
    cell.moreLabel.text = NSLocalizedString(@"more_button", nil);
    
    //determine selected status
    int sel = [[favedDictionary valueForKey:event.objectId] intValue];
    if (sel == 1)
    {
        [cell.flairImage setTintColor:[UIColor primary_color_icon]];
        UIImage *img = [UIImage imageNamed:@"star_full48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.flairImage.image = img;
        [cell.favoriteButton setTitle:NSLocalizedString(@"unfollow_button", nil) forState:UIControlStateNormal];
    }
    else
    {
        [cell.flairImage setTintColor:[UIColor unselected_icon]];
        UIImage *img = [UIImage imageNamed:@"star_empty48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.flairImage.image = img;
        [cell.favoriteButton setTitle:NSLocalizedString(@"fav_button", nil) forState:UIControlStateNormal];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFObject *selectedEventObject = cell.homeObject;
    NSLog(@"TAPPED ROW: %@", selectedEventObject.objectId);
    if (selectedEventObject[@"childrenEvent"]==nil)   //this is not a parent event
    {
        [self setCurrentEventForObject:selectedEventObject];
        UIViewController *centerViewController;
        centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
        
        //For a better UX, we push the tabbar controller instead of setting it as a drawer, can change in the future if need (original code above)
        //BUT...pushing a tabbar controller causes some issues, so we're disabling this again :(
        //UITabBarController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
        //[self.navigationController pushViewController:controller animated:YES];
    }
    else   //this IS a parent event, and we reload the homeview controller to get the children list
    {
        //NSString *title = selectedEventObject[@"name"];
        //self.isSecondLevelEvent = YES;
        //self.parentEvent = selectedEventObject;
        //self.navigationItem.title = title;
        //[self getChildrenEvents:self withParent:self.parentEvent];
        //instead of updating itself (see above), we push a new instance, to minimize user confusion and make the UX better (see below)
        HomeView *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"home_vc"];
        controller.isSecondLevelEvent = YES;
        controller.parentEvent = selectedEventObject;
        controller.showDrawer = NO;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    disableFav = NO;
    [followedEventsArray removeAllObjects];
    [favedDictionary removeAllObjects];
    followedEventsArray = [results mutableCopy];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventIds = [defaults objectForKey:@"eventIds"];
    for (PFObject *event in followedEventsArray)
    {
        NSString *eid = event.objectId;
        if ([self checkIfStringArray:eventIds containsString:eid])
        {
            [favedDictionary setValue:@1 forKey:eid];
        }
        else
        {
            [favedDictionary setValue:@0 forKey:eid];
        }
    }
    
    [self.homeTable reloadData];
    
    //check if empty
    if (followedEventsArray.count==0)
    {
        self.emptyLabel.hidden = NO;
        self.emptyLabel.userInteractionEnabled = YES;
        self.addEventButton.hidden = NO;
        self.addEventButton.userInteractionEnabled = YES;
    }
    else
    {
        self.emptyLabel.hidden = YES;
        self.emptyLabel.userInteractionEnabled = NO;
        self.addEventButton.hidden = YES;
        self.addEventButton.userInteractionEnabled = NO;
    }
}

- (void)setCurrentEventForObject: (PFObject *)object
{
    NSString *eventId = object.objectId;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:eventId forKey:@"currentEventId"];
    [defaults synchronize];
}

- (void)favButtonForTable: (UITableView *)tableView wasTappedAt: (NSIndexPath *)indexPath
{
    HomeCell *cell = (HomeCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    int selectedStatus = [[favedDictionary valueForKey:cell.eventId] intValue];
    if (selectedStatus == 1)   //selected->unselected
    {
        [cell.flairImage setTintColor:[UIColor unselected_icon]];
        UIImage *img = [UIImage imageNamed:@"star_empty48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.flairImage.image = img;
        [favedDictionary setValue:@0 forKey:cell.eventId];
        [cell.favoriteButton setTitle:NSLocalizedString(@"fav_button", nil) forState:UIControlStateNormal];
        [self tappedFavoriteButtonWithId:cell.eventId withName:cell.eventName withObject:cell.homeObject toSave:NO];
    }
    else   //unselected->selected
    {
        [cell.flairImage setTintColor:[UIColor primary_color_icon]];
        UIImage *img = [UIImage imageNamed:@"star_full48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.flairImage.image = img;
        [favedDictionary setValue:@1 forKey:cell.eventId];
        [cell.favoriteButton setTitle:NSLocalizedString(@"unfollow_button", nil) forState:UIControlStateNormal];
        [self tappedFavoriteButtonWithId:cell.eventId withName:cell.eventName withObject:cell.homeObject toSave:YES];
    }
}

- (void)tappedFavoriteButtonWithId: (NSString *)eventId withName: (NSString *)eventName withObject: (PFObject *)eventObject toSave: (BOOL)saving
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (saving)
    {
        NSMutableArray *eventIds = [[NSMutableArray alloc] init];
        [eventIds addObjectsFromArray:[defaults objectForKey:@"eventIds"]];
        [eventIds addObject:eventId];
        [defaults setObject:eventIds forKey:@"eventIds"];
        
        NSMutableArray *eventNames = [[NSMutableArray alloc] init];
        [eventNames addObjectsFromArray:[defaults objectForKey:@"eventNames"]];
        [eventNames addObject:eventName];
        [defaults setObject:eventNames forKey:@"eventNames"];
        [defaults synchronize];
        
        //save to parse
        if ([PFUser currentUser])
        {
            PFUser *user = [PFUser currentUser];
            [user addUniqueObject:eventObject forKey:@"events"];
            [user saveInBackground];
        }
    }
    else
    {
        NSMutableArray *eventIds = [[NSMutableArray alloc] init];
        [eventIds addObjectsFromArray:[defaults objectForKey:@"eventIds"]];
        if ([eventIds containsObject:eventId])
        {
            [eventIds removeObject:eventId];
        }
        [defaults setObject:eventIds forKey:@"eventIds"];
        
        NSMutableArray *eventNames = [[NSMutableArray alloc] init];
        [eventNames addObjectsFromArray:[defaults objectForKey:@"eventNames"]];
        if ([eventNames containsObject:eventName])
        {
            [eventNames removeObject:eventName];
        }
        [defaults setObject:eventNames forKey:@"eventNames"];
        [defaults synchronize];
        
        //save to parse
        if ([PFUser currentUser])
        {
            PFUser *user = [PFUser currentUser];
            [user removeObject:eventObject forKey:@"events"];
            [user saveInBackground];
        }
    }
    
    NSMutableDictionary *eventDictionary = [[NSMutableDictionary alloc] init];
    [eventDictionary addEntriesFromDictionary:[defaults objectForKey:@"eventDictionary"]];
    if ([eventDictionary objectForKey:eventName] == nil)
    {
        [eventDictionary setObject:eventId forKey:eventName];
        [defaults setObject:eventDictionary forKey:@"eventDictionary"];
    }
    [defaults synchronize];
    
    //update drawer
    DrawerView *drawerViewController = (DrawerView *) self.mm_drawerController.leftDrawerViewController;
    [drawerViewController updateEvents];
    
    //update this view
    disableFav = YES;
    if (!self.isSecondLevelEvent)   //normal home screen
    {
        [self getEventsFromLocalList:self];
    }
    else   //second level event screen
    {
        [self getChildrenEvents:self withParent:self.parentEvent];
    }
}


- (BOOL)checkIfStringArray: (NSArray *)array containsString: (NSString *) string  //utility method, checks an array for a string
{
    for (NSString *str in array)
    {
        if ([str isEqualToString:string])
        {
            return YES;
        }
    }
    return NO;
}

@end

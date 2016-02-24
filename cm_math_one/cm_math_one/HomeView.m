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

NSMutableArray *selectedEventsArray;

@implementation HomeView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    //init
    [super viewDidLoad];
    if (!self.isSecondLevelEvent)
    {
        [self setupLeftMenuButton];
    }
    else
    {
        self.navigationItem.title = self.parentEvent[@"name"];
    }
    
    selectedEventsArray = [[NSMutableArray alloc] init];
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

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [selectedEventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homecell"];
    
    //data
    PFObject *event = [selectedEventsArray objectAtIndex:indexPath.row];
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
    
    UIImage *img = [UIImage imageNamed:@"event48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.flairImage.image = img;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //PFObject *selectedEventObject = [selectedEventsArray objectAtIndex:indexPath.row];
    HomeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFObject *selectedEventObject = cell.homeObject;
    NSLog(@"TAPPED ROW: %@", selectedEventObject.objectId);
    if (selectedEventObject[@"childrenEvent"]==nil)   //this is not a parent event
    {
        [self setCurrentEventIdForRow:indexPath.row];
        UIViewController *centerViewController;
        centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    }
    else   //this IS a parent event, and we reload the homeview controller to get the children list
    {
        //NSString *title = selectedEventObject[@"name"];
        //self.isSecondLevelEvent = YES;
        //self.parentEvent = selectedEventObject;
        //self.navigationItem.title = title;
        //[self getChildrenEvents:self withParent:self.parentEvent];
        //instead of updating itself (see above), we push a new instance, to minimize user confusion and make the ux better (see below)
        HomeView *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"home_vc"];
        controller.isSecondLevelEvent = YES;
        controller.parentEvent = selectedEventObject;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [selectedEventsArray removeAllObjects];
    selectedEventsArray = [results mutableCopy];
    [self.homeTable reloadData];
    
    if (selectedEventsArray.count==0)
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

- (void) setCurrentEventIdForRow: (int)row
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    NSString *name = [eventNames objectAtIndex:row];
    NSDictionary *eventDictionary = [defaults objectForKey:@"eventDictionary"];
    NSString *eid = [eventDictionary objectForKey:name];
    [defaults setObject:eid forKey:@"currentEventId"];
    [defaults synchronize];
    NSLog(@"Current event id set to: %@", eid);
}

@end

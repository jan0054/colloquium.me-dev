//
//  HomeView.m
//  cm_math_one
//
//  Created by csjan on 7/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "HomeView.h"
#import <Parse/Parse.h>
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

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    selectedEventsArray = [[NSMutableArray alloc] init];
    self.homeTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.homeTable.estimatedRowHeight = 220.0;
    self.homeTable.rowHeight = UITableViewAutomaticDimension;
    
    [self getEventsFromLocalList:self];
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
    cell.nameLabel.text = event[@"name"];
    cell.contentLabel.text = event[@"content"];
    cell.organizerLabel.text = event[@"organizer"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = event[@"start_time"];
    NSDate *edate = event[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ to %@", sstr, estr];
    cell.eventId = event.objectId;
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.timeLabel.backgroundColor = [UIColor clearColor];
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.contentLabel.backgroundColor = [UIColor clearColor];
    cell.organizerLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setCurrentEventIdForRow:indexPath.row];
    UIViewController *centerViewController;
    centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [selectedEventsArray removeAllObjects];
    selectedEventsArray = [results mutableCopy];
    [self.homeTable reloadData];
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

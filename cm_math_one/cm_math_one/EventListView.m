//
//  EventListView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "EventListView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "EventCell.h"
#import "DrawerView.h"

NSMutableArray *totalEventArray;
NSMutableArray *selectedIndexPathArray;
NSMutableArray *selectedEventArray;
NSMutableArray *selectedEventIDArray;

@implementation EventListView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    totalEventArray = [[NSMutableArray alloc] init];
    selectedEventArray = [[NSMutableArray alloc] init];
    selectedEventIDArray = [[NSMutableArray alloc] init];
    selectedIndexPathArray = [[NSMutableArray alloc] init];
    self.eventTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.eventTable.estimatedRowHeight = 220.0;
    self.eventTable.rowHeight = UITableViewAutomaticDimension;
    
    [self getEvents:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [selectedEventArray removeAllObjects];
    [selectedEventIDArray removeAllObjects];
    [selectedIndexPathArray removeAllObjects];
    for (NSIndexPath *indexPath in self.eventTable.indexPathsForSelectedRows) {
        [self.eventTable deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void) viewDidLayoutSubviews
{
    if ([self.eventTable respondsToSelector:@selector(layoutMargins)]) {
        self.eventTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)doneButtonTap:(UIBarButtonItem *)sender {
    [self saveEventList:selectedEventArray];
}

- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender {
    for (NSIndexPath *indexPath in self.eventTable.indexPathsForSelectedRows) {
        [self.eventTable deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [totalEventArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventcell"];
    
    //data
    PFObject *event = [totalEventArray objectAtIndex:indexPath.row];
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
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.timeLabel.backgroundColor = [UIColor clearColor];
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.contentLabel.backgroundColor = [UIColor clearColor];
    cell.organizerLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *event = [totalEventArray objectAtIndex:indexPath.row];
    NSString *eventid = event.objectId;
    
    [selectedEventArray addObject:event];
    [selectedEventIDArray addObject:eventid];
    [selectedIndexPathArray addObject:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *event = [totalEventArray objectAtIndex:indexPath.row];
    NSString *eventid = event.objectId;
    
    [selectedEventArray removeObject:event];
    [selectedEventIDArray removeObject:eventid];
    [selectedIndexPathArray removeObject:indexPath];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [totalEventArray removeAllObjects];
    totalEventArray = [results mutableCopy];
    [self.eventTable reloadData];
}

- (void) saveEventList: (NSMutableArray *)selectedEvents
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"eventDictionary"];
    [defaults removeObjectForKey:@"eventNames"];
    NSMutableDictionary *eventNameWithIds = [[NSMutableDictionary alloc] init];
    NSMutableArray *eventNames = [[NSMutableArray alloc] init];
    
    for (PFObject *event in selectedEvents)
    {
        NSString *ename = event[@"name"];
        NSString *eid = event.objectId;
        [eventNameWithIds setObject:eid forKey:ename];
        [eventNames addObject:ename];
    }
    [defaults setObject:eventNameWithIds forKey:@"eventDictionary"];
    [defaults setObject:eventNames forKey:@"eventNames"];
    [defaults synchronize];
    DrawerView *drawerViewController = (DrawerView *) self.mm_drawerController.leftDrawerViewController;
    [drawerViewController updateEvents];
}



@end

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

@implementation EventListView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    totalEventArray = [[NSMutableArray alloc] init];
    self.eventTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.eventTable.estimatedRowHeight = 220.0;
    self.eventTable.rowHeight = UITableViewAutomaticDimension;
    
    [self getEvents:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    NSArray *selected =  self.eventTable.indexPathsForSelectedRows;
    [self saveEventList:selected];
    
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
    [dateFormat setDateFormat: @"MMM-d"];
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
    [cell.selectedImage setTintColor:[UIColor dark_accent]];
    UIImage *img = [UIImage imageNamed:@"checkevent48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.selectedImage.image = img;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = YES;
}

#pragma mark - Data

- (void)processData: (NSArray *) results  //callback for the query to get all existing events
{
    [totalEventArray removeAllObjects];
    totalEventArray = [results mutableCopy];
    [self.eventTable reloadData];
    [self selectExistingEvents];
}

- (void) selectExistingEvents   //check local storage for saved events and set them to selected in the tableview
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventIds = [defaults objectForKey:@"eventIds"];
    
    for (NSInteger i = 0; i < [self.eventTable numberOfRowsInSection:0]; ++i)
    {
        EventCell *cell = (EventCell *)[self.eventTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *eid = cell.eventId;
        if ([self checkIfStringArray:eventIds containsString:eid])
        {
            [self.eventTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            cell.selectedImage.hidden = NO;
        }
        else
        {
            cell.selectedImage.hidden = YES;
        }
    }
}

- (void) saveEventList: (NSArray *)selectedIndexPaths
{
    //save the array of selected events
    NSMutableArray *selectedEvents = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in selectedIndexPaths)
    {
        PFObject *event = [totalEventArray objectAtIndex:indexpath.row];
        [selectedEvents addObject:event];
    }
    
    //save to local storage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *eventNameWithIds = [[NSMutableDictionary alloc] init];
    NSMutableArray *eventNames = [[NSMutableArray alloc] init];
    NSMutableArray *eventIds = [[NSMutableArray alloc] init];
    for (PFObject *event in selectedEvents)
    {
        NSString *ename = event[@"name"];
        NSString *eid = event.objectId;
        [eventNameWithIds setObject:eid forKey:ename];
        [eventNames addObject:ename];
        [eventIds addObject:eid];
    }
    [defaults setObject:eventNameWithIds forKey:@"eventDictionary"];
    [defaults setObject:eventNames forKey:@"eventNames"];
    [defaults setObject:eventIds forKey:@"eventIds"];
    [defaults synchronize];
    
    //update drawer
    DrawerView *drawerViewController = (DrawerView *) self.mm_drawerController.leftDrawerViewController;
    [drawerViewController updateEvents];
    
    //save to parse
    if ([PFUser currentUser])
    {
        PFUser *user = [PFUser currentUser];
        user[@"events"] = selectedEvents;
        [user saveInBackground];
    }
    
    //update current event: check if there's at least 1 event in the list first
    if (selectedEvents.count == 0)
    {
        [defaults setObject:@"" forKey:@"currentEventId"];
        [defaults synchronize];
    }
    else
    {
        [self setCurrentEventWithSelected:selectedEvents];
    }
    
    //alert and open drawer
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Your events have been updated, find them in the left side drawer"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


- (BOOL) checkIfStringArray: (NSArray *)array containsString: (NSString *) string  //utility method
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

- (void) setCurrentEventWithSelected: (NSArray *)selectedEvents
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    if (eventid.length>0) //some current event already set, search if it is among the selected events first
    {
        BOOL stillSelected = NO;
        for (PFObject *event in selectedEvents)
        {
            if ([eventid isEqualToString:event.objectId])  //current event still selected
            {
                stillSelected = YES;
            }
        }
        if (!stillSelected)  //if current event not selected anymore, pick the first one in the list and set it as current event
        {
            PFObject *event = [selectedEvents objectAtIndex:0];
            [defaults setObject:event.objectId forKey:@"currentEventId"];
            [defaults synchronize];
        }
    }
    else  //no current event set
    {
        PFObject *event = [selectedEvents objectAtIndex:0];
        [defaults setObject:event.objectId forKey:@"currentEventId"];
        [defaults synchronize];
    }
}

@end

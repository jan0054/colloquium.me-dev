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
#import "InstructionsViewController.h"

NSMutableArray *totalEventArray;
NSMutableDictionary *selectedDictionary;
InstructionsViewController *controller;

@implementation EventListView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self setupLeftMenuButton];
    totalEventArray = [[NSMutableArray alloc] init];
    selectedDictionary = [[NSMutableDictionary alloc] init];
    self.eventTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.eventTable.estimatedRowHeight = 200.0;
    self.eventTable.rowHeight = UITableViewAutomaticDimension;
    
    [self getEvents:self];
    [self setupInstructions];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.eventTable addSubview:pullrefresh];
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

- (void)refreshctrl:(id)sender
{
    [self.eventTable setNeedsLayout];
    [self.eventTable layoutIfNeeded];
    [self.eventTable reloadData];
    [(UIRefreshControl *)sender endRefreshing];
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

- (IBAction)instructionTap:(UITapGestureRecognizer *)sender {
    [controller.view removeFromSuperview];
    [self.view removeGestureRecognizer:self.tapOutlet];
    NSLog(@"Instructions removed");
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
    cell.eventNameLabel.text = event[@"name"];
    cell.eventContentLabel.text = event[@"content"];
    cell.eventOrganizerLabel.text = event[@"organizer"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormat setDateFormat: @"MMM-d"];
    NSDate *sdate = event[@"start_time"];
    NSDate *edate = event[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    cell.eventTimeLabel.text = [NSString stringWithFormat:@"%@ to %@", sstr, estr];
    cell.eventId = event.objectId;
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.eventNameLabel.backgroundColor = [UIColor clearColor];
    cell.eventTimeLabel.backgroundColor = [UIColor clearColor];
    cell.eventContentLabel.backgroundColor = [UIColor clearColor];
    cell.eventOrganizerLabel.backgroundColor = [UIColor clearColor];
        [cell.eventSelectedImage setTintColor:[UIColor dark_accent]];
    UIImage *img = [UIImage imageNamed:@"checkevent48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.eventSelectedImage.image = img;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.eventOrganizerLabel.textColor = [UIColor dark_primary];
    cell.eventTimeLabel.textColor = [UIColor dark_primary];
    
    int sel = [[selectedDictionary valueForKey:event.objectId] intValue];
    if (sel == 1)
    {
        cell.eventSelectedImage.hidden = NO;
    }
    else
    {
        cell.eventSelectedImage.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.eventSelectedImage.hidden = NO;
    [selectedDictionary setValue:@1 forKey:cell.eventId];

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.eventSelectedImage.hidden = YES;
    [selectedDictionary setValue:@0 forKey:cell.eventId];
}

#pragma mark - Data

- (void)processData: (NSArray *) results  //callback for the query to get all existing events
{
    [totalEventArray removeAllObjects];
    [selectedDictionary removeAllObjects];
    totalEventArray = [results mutableCopy];
    
    //keep a dictionary of which event ids are saved(selected), used to determine the checkmark image for each cell
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventIds = [defaults objectForKey:@"eventIds"];
    for (PFObject *event in totalEventArray)
    {
        NSString *eid = event.objectId;
        if ([self checkIfStringArray:eventIds containsString:eid])
        {
            [selectedDictionary setValue:@1 forKey:eid];
        }
        else
        {
            [selectedDictionary setValue:@0 forKey:eid];
        }
    }
    
    [self.eventTable reloadData];
    [self selectExistingEvents];
}


- (void)selectExistingEvents   //check local storage for saved events and set them to selected in the tableview
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventIds = [defaults objectForKey:@"eventIds"];
    
    for (NSInteger i = 0; i < [totalEventArray count]; ++i)
    {
        EventCell *cell = (EventCell *)[self.eventTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *eid = cell.eventId;
        if ([self checkIfStringArray:eventIds containsString:eid])
        {
            [self.eventTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)saveEventList: (NSArray *)selectedIndexPaths
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
                                                    message:@"Your events have been updated!"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
    UIViewController *centerViewController;
    centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
}


- (BOOL)checkIfStringArray: (NSArray *)array containsString: (NSString *) string  //utility method
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

- (void)setCurrentEventWithSelected: (NSArray *)selectedEvents
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

- (void)setupInstructions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL alreadySetup = [defaults boolForKey:@"chooseeventsetup"];
    if (!alreadySetup)
    {
        controller = (InstructionsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"instruction_vc"];
        [self.view addSubview:controller.view];
        [defaults setBool:YES forKey:@"chooseeventsetup"];
        [defaults synchronize];
    }
    else
    {
        [self.view removeGestureRecognizer:self.tapOutlet];
    }
}

@end

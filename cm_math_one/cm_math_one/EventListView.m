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

NSMutableArray *totalEventArray;           //hold all event pfobjects from query
NSMutableDictionary *selectedDictionary;   //object id and selection(0/1) key value pair
NSMutableArray *selectedEventArray;        //pfobject array for selected events
InstructionsViewController *controller;

@implementation EventListView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    
    //styling
    self.eventTable.backgroundColor = [UIColor light_bg];
    self.view.backgroundColor = [UIColor light_bg];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
    [self.eventFilterSeg setTintColor:[UIColor primary_color]];
    
    //init
    self.navigationItem.title = NSLocalizedString(@"events_title", nil);
    [self.eventFilterSeg setTitle:NSLocalizedString(@"seg_current", nil) forSegmentAtIndex:0];
    [self.eventFilterSeg setTitle:NSLocalizedString(@"seg_past", nil) forSegmentAtIndex:1];
    totalEventArray = [[NSMutableArray alloc] init];
    selectedDictionary = [[NSMutableDictionary alloc] init];
    selectedEventArray = [[NSMutableArray alloc] init];
    self.eventTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.eventTable.estimatedRowHeight = 200.0;
    self.eventTable.rowHeight = UITableViewAutomaticDimension;
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.eventTable addSubview:pullrefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getCurrentEvents:self];      //get events list, callback method is processData
    [self.eventFilterSeg setSelectedSegmentIndex:0];
    [self setupInstructions];   //instruction overlay
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

//not currently used
- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

//remove instruction overlay
- (IBAction)instructionTap:(UITapGestureRecognizer *)sender {
    [controller.view removeFromSuperview];
    [self.view removeGestureRecognizer:self.tapOutlet];
    NSLog(@"Instructions removed");
}

- (IBAction)segChanged:(UISegmentedControl *)sender {
    if (self.eventFilterSeg.selectedSegmentIndex == 0)   //current
    {
        [self getCurrentEvents:self];
    }
    else if (self.eventFilterSeg.selectedSegmentIndex == 1)   //past
    {
        [self getPastEvents:self];
    }
}

- (IBAction)favoriteButtonTap:(UIButton *)sender {
    EventCell *cell = (EventCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.eventTable indexPathForCell:cell];
    [self favButtonForTable:self.eventTable wasTappedAt:tapped_path];
}
- (IBAction)moreButtonTap:(UIButton *)sender {
    EventCell *cell = (EventCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.eventTable indexPathForCell:cell];
    [self moreButtonForTable:self.eventTable wasTappedAt:tapped_path];
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
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM/d"];
    NSDate *sdate = event[@"start_time"];
    NSDate *edate = event[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    cell.eventTimeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", sstr, estr];
    cell.eventId = event.objectId;
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.eventNameLabel.backgroundColor = [UIColor clearColor];
    cell.eventTimeLabel.backgroundColor = [UIColor clearColor];
    cell.eventContentLabel.backgroundColor = [UIColor clearColor];
    cell.eventOrganizerLabel.backgroundColor = [UIColor clearColor];
    [cell.eventSelectedImage setTintColor:[UIColor primary_color_icon]];
    UIImage *imgSelected = [UIImage imageNamed:@"check48"];
    imgSelected = [imgSelected imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.eventSelectedImage.image = imgSelected;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.eventOrganizerLabel.textColor = [UIColor primary_text];
    cell.eventTimeLabel.textColor = [UIColor primary_text];
    cell.backgroundCardView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundCardView.layer.shouldRasterize = YES;
    cell.backgroundCardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundCardView.layer.shadowColor = [UIColor shadow_color].CGColor;
    cell.backgroundCardView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    cell.backgroundCardView.layer.shadowOpacity = 0.3f;
    cell.backgroundCardView.layer.shadowRadius = 1.0f;
    [cell.favoriteButton setTitle:NSLocalizedString(@"fav_button", nil) forState:UIControlStateNormal];
    [cell.moreButton setTitle:NSLocalizedString(@"more_button", nil) forState:UIControlStateNormal];
    [cell.favoriteButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [cell.moreButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [cell.favoriteButton setTitleColor:[UIColor light_accent] forState:UIControlStateHighlighted];
    [cell.moreButton setTitleColor:[UIColor light_accent] forState:UIControlStateHighlighted];
    
    int sel = [[selectedDictionary valueForKey:event.objectId] intValue];
    if (sel == 1)
    {
        [cell.eventSelectedImage setTintColor:[UIColor primary_color_icon]];
        UIImage *img = [UIImage imageNamed:@"star_full48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
    }
    else
    {
        [cell.eventSelectedImage setTintColor:[UIColor unselected_icon]];
        UIImage *img = [UIImage imageNamed:@"star_empty48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView wasTappedAt:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView wasTappedAt:indexPath];
}

#pragma mark - Data

- (void)processData: (NSArray *) results  //callback for the query to get all existing events
{
    [totalEventArray removeAllObjects];
    [selectedDictionary removeAllObjects];
    [selectedEventArray removeAllObjects];
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
    NSLog(@"DIC AT PROCESS DATA:%@", selectedDictionary);
    [self.eventTable reloadData];
    
    int totalSelected = 0;
    for (NSString *key in selectedDictionary)
    {
        int selValue = [[selectedDictionary valueForKey:key] intValue];
        totalSelected = totalSelected + selValue;
        NSLog(@"TOTALVALUE:%i, %i", totalSelected, selValue);
    }

}

- (void)favButtonForTable: (UITableView *)tableView wasTappedAt: (NSIndexPath *)indexPath
{
    EventCell *cell = (EventCell *)[tableView cellForRowAtIndexPath:indexPath];
    int selectedStatus = [[selectedDictionary valueForKey:cell.eventId] intValue];
    if (selectedStatus == 1)
    {
        [cell.eventSelectedImage setTintColor:[UIColor unselected_icon]];
        UIImage *img = [UIImage imageNamed:@"star_empty48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
        [selectedDictionary setValue:@0 forKey:cell.eventId];
    }
    else
    {
        [cell.eventSelectedImage setTintColor:[UIColor primary_color_icon]];
        UIImage *img = [UIImage imageNamed:@"star_full48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
        [selectedDictionary setValue:@1 forKey:cell.eventId];
    }

}

- (void)moreButtonForTable: (UITableView *)tableView wasTappedAt: (NSIndexPath *)indexPath
{
    
}

- (void)tableView: (UITableView *)tableView wasTappedAt: (NSIndexPath *)indexPath
{
    EventCell *cell = (EventCell *)[tableView cellForRowAtIndexPath:indexPath];
    int selectedStatus = [[selectedDictionary valueForKey:cell.eventId] intValue];
    if (selectedStatus == 1)
    {
        [cell.eventSelectedImage setTintColor:[UIColor unselected_icon]];
        UIImage *img = [UIImage imageNamed:@"star_empty48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
        [selectedDictionary setValue:@0 forKey:cell.eventId];
    }
    else
    {
        [cell.eventSelectedImage setTintColor:[UIColor primary_color_icon]];
        UIImage *img = [UIImage imageNamed:@"star_full48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.eventSelectedImage.image = img;
        cell.eventNameLabel.textColor = [UIColor primary_text];
        [selectedDictionary setValue:@1 forKey:cell.eventId];
    }
    
    NSLog(@"DIC AT SELECT DATA:%@", selectedDictionary);
    
    int totalSelected = 0;
    for (NSString *key in selectedDictionary)
    {
        int selValue = [[selectedDictionary valueForKey:key] intValue];
        totalSelected = totalSelected + selValue;
    }
    NSLog(@"SELECTION COUNT:%i", totalSelected);
}

- (void)saveEventList: (NSArray *)selectedIndexPaths
{
    //this will hold the array of selected event objects that we want to save
    NSMutableArray *selectedEvents = [[NSMutableArray alloc] init];
    
    for (PFObject *event in totalEventArray)
    {
        NSString *eid = event.objectId;
        if ( [[selectedDictionary valueForKey:eid] intValue] == 1)
        {
            //then this event was selected, we add it to the selected events array
            [selectedEvents addObject:event];
        }
    }
    
    NSLog(@"DIC AT SAVE DATA:%@, SEL ARRAY COUNT: %lu", selectedDictionary, (unsigned long)selectedEvents.count);
    
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_success", nil)
                                                    message:NSLocalizedString(@"alert_event_update", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                                          otherButtonTitles:nil];
    [alert show];
    UIViewController *centerViewController;
    centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
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

- (void)setCurrentEventWithSelected: (NSArray *)selectedEvents   //sets the current event
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

- (void)setupInstructions  //display the instruction overlay (disabled for now!)
{
    [self.view removeGestureRecognizer:self.tapOutlet];
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL alreadySetup = [defaults boolForKey:@"chooseeventsetup"];
    if (!alreadySetup)
    {
        controller = (InstructionsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"instruction_vc"];
        [self.view addSubview:controller.view];
        [defaults setBool:YES forKey:@"chooseeventsetup"];
        [defaults synchronize];
        self.doneButton.enabled = NO;
    }
    else
    {
        [self.view removeGestureRecognizer:self.tapOutlet];
    }
     */
}



@end

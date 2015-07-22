//
//  OverviewView.m
//  cm_math_one
//
//  Created by csjan on 7/22/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "OverviewView.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"

@interface OverviewView ()

@end

PFUser *admin;
NSMutableArray *newsArray;

@implementation OverviewView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    newsArray = [[NSMutableArray alloc] init];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    [self getEvent:self withId:eventid];
    [self getNewsFromEventId:eventid];
    [self setupAttendance];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)organizerButtonTap:(UIButton *)sender {
    NSString *mail = admin[@"email"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mail]];
}

- (IBAction)attendanceSwitchChanged:(UISwitch *)sender {

}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newscell"];
    
    //data
    PFObject *announcement = [newsArray objectAtIndex:indexPath.row];
    PFUser *author = announcement[@"author"];
    cell.textLabel.text = announcement[@"content"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    
    return cell;
}


#pragma mark - Data

- (void)processEvent: (PFObject *) object
{
    //data source
    NSString *name = object[@"name"];
    NSString *content = object[@"content"];
    NSString *organizer = object[@"organizer"];
    admin = object[@"admin"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = object[@"start_time"];
    NSDate *edate = object[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    
    //interface
    self.timeLabel.text = [NSString stringWithFormat:@"%@ to %@", sstr, estr];
    self.nameLabel.text = name;
    self.contentLabel.text = content;
    [self.organizerButton setTitle:organizer forState:UIControlStateNormal];
    self.attendanceLabel.text = @"I am attending this event:";
}

- (void)getNewsFromEventId: (NSString *)eventId
{
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventId];
    PFQuery *query = [PFQuery queryWithClassName:@"Announcement"];
    [query includeKey:@"author"];
    [query whereKey:@"event" equalTo:event];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu announcements for event", (unsigned long)objects.count);
        [newsArray removeAllObjects];
        newsArray = [objects mutableCopy];
        [self.newsTable reloadData];
    }];
}

- (void)setupAttendance
{
    if (![PFUser currentUser])
    {
        self.attendanceSwitch.enabled = NO;
    }
    else
    {
        self.attendanceSwitch.enabled = YES;
        
    }
}

@end

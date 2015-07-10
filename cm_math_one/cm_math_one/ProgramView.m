//
//  ProgramView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ProgramView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ProgramCell.h"

NSMutableArray *programArray;

@implementation ProgramView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    programArray = [[NSMutableArray alloc] init];
    self.programTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.programTable.estimatedRowHeight = 220.0;
    self.programTable.rowHeight = UITableViewAutomaticDimension;
    
    //styling
    UIImage *img = [UIImage imageNamed:@"search48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setTintColor:[UIColor lightGrayColor]];
    [self.searchButton setImage:img forState:UIControlStateNormal];
    self.searchBackgroundView.backgroundColor = [UIColor whiteColor];

    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];

    [self getProgram:self ofType:0 withOrder:0 forEvent:event];
}

- (void)viewDidLayoutSubviews
{
    if ([self.programTable respondsToSelector:@selector(layoutMargins)]) {
        self.programTable.layoutMargins = UIEdgeInsetsZero;
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
    return [programArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProgramCell *cell = [tableView dequeueReusableCellWithIdentifier:@"programcell"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.timeLabel.backgroundColor = [UIColor clearColor];
    cell.authorLabel.backgroundColor = [UIColor clearColor];
    cell.bottomView.backgroundColor = [UIColor clearColor];
    cell.contentLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //data
    PFObject *program = [programArray objectAtIndex:indexPath.row];
    PFObject *author = program[@"author"];
    cell.nameLabel.text = program[@"name"];
    cell.contentLabel.text = program[@"content"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", author[@"last_name"], author[@"first_name"]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = program[@"start_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    cell.timeLabel.text = sstr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Data

- (IBAction)searchButtonTap:(UIButton *)sender {
}

- (void)processData: (NSArray *) results
{
    [programArray removeAllObjects];
    programArray = [results mutableCopy];
    [self.programTable reloadData];
}

@end

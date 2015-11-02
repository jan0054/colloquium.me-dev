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
#import "ProgramDetailView.h"

NSMutableArray *programArray;
PFObject *selectedProgram;

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
    self.searchInput.delegate = self;
    
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

- (IBAction)searchButtonTap:(UIButton *)sender {
    if (self.searchInput.text.length >1)
    {
        NSString *search_str = self.searchInput.text.lowercaseString;
        NSArray *wordsAndEmptyStrings = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        [self doSearchWithArray:words];
    }
    [self.searchInput resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.searchInput) [self resetSearch];
    return YES;
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
    cell.moreLabel.textColor = [UIColor dark_accent];
    cell.timeLabel.textColor = [UIColor dark_primary];
    cell.locationLabel.textColor = [UIColor dark_primary];
    
    //data
    PFObject *program = [programArray objectAtIndex:indexPath.row];
    PFObject *author = program[@"author"];
    PFObject *location = program[@"location"];
    NSString *locationName = (location[@"name"]!=NULL) ? location[@"name"] : @"";
    cell.nameLabel.text = program[@"name"];
    cell.contentLabel.text = program[@"content"];
    cell.locationLabel.text = locationName;
    cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", author[@"last_name"], author[@"first_name"]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSDate *sdate = program[@"start_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    cell.timeLabel.text = sstr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedProgram = [programArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"programdetailsegue" sender:self];
}

#pragma mark - Data

- (void)resetSearch
{
    NSLog(@"Search reset called");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self ofType:0 withOrder:0 forEvent:event];
}

- (void)doSearchWithArray: (NSArray *)searchArray
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self ofType:0 withOrder:0 withSearch:searchArray forEvent:event];
}

- (void)processData: (NSArray *) results
{
    [programArray removeAllObjects];
    programArray = [results mutableCopy];
    [self.programTable reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"programdetailsegue"]) {
        ProgramDetailView *controller = (ProgramDetailView *) segue.destinationViewController;
        controller.program = selectedProgram;
    }
}

@end

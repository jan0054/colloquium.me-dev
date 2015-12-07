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
@synthesize pullrefresh;

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
    self.navigationController.navigationBar.layer.shadowColor = [UIColor dark_primary].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;


    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self ofType:0 withOrder:0 forEvent:event];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.programTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self ofType:0 withOrder:0 forEvent:event];
    [(UIRefreshControl *)sender endRefreshing];
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
    if (self.searchInput.text.length >0)
    {
        NSString *search_str = self.searchInput.text.lowercaseString;
        
        NSArray *separateBySpace = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *processedWords = [[NSMutableArray alloc] init];
        for (NSString *componentString in separateBySpace)
        {
            CFStringRef compstr = (__bridge CFStringRef)(componentString);
            NSString *lang = CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage(compstr, CFRangeMake(0, componentString.length)));
            if ([lang isEqualToString:@"zh-Hant"])
            {
                //中文
                for (int i=1; i<=componentString.length; i++)
                {
                    NSString *chcomp = [componentString substringWithRange:NSMakeRange(i-1, 1)];
                    [processedWords addObject:chcomp];
                }
            }
            else
            {
                //not中文
                [processedWords addObject:componentString];
            }
        }
        
        [self doSearchWithArray:processedWords];
        NSLog(@"PROCESSEDWORDS:%lu, %@", processedWords.count, processedWords);
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

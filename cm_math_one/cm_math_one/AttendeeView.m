//
//  AttendeeView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AttendeeView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "AttendeeCell.h"
#import "AttendeeDetailView.h"

NSMutableArray *attendeeArrray;
PFObject *selectedAttendee;

@implementation AttendeeView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    attendeeArrray = [[NSMutableArray alloc] init];
    self.searchInput.delegate = self;
    self.attendeeTable.tableFooterView = [[UIView alloc] init];
    
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
    [self getPeople:self forEvent:event];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.attendeeTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    if (self.searchInput.text.length>0)
    {
        [self prepareSearch];
    }
    else
    {
        [self resetSearch];  //just the normal non-search query
    }
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)searchButtonTap:(UIButton *)sender
{
    [self prepareSearch];
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
    return [attendeeArrray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttendeeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendeecell"];
    
    //data
    PFObject *attendee = [attendeeArrray objectAtIndex:indexPath.row];
    NSString *first_name = attendee[@"first_name"];
    NSString *last_name = attendee[@"last_name"];
    NSString *institution = attendee[@"institution"];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@", last_name, first_name];
    cell.institutionLabel.text = institution;
    
    //styling
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.institutionLabel.backgroundColor = [UIColor clearColor];
    cell.moreLabel.backgroundColor = [UIColor clearColor];
    cell.moreLabel.textColor = [UIColor dark_accent];
    cell.institutionLabel.textColor = [UIColor dark_primary];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedAttendee = [attendeeArrray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"attendeedetailsegue" sender:self];
}

#pragma mark - Data

- (void)resetSearch
{
    NSLog(@"Search reset called");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getPeople:self forEvent:event];
}

- (void)prepareSearch   //check if the search empty, then process the string and words, then call the search method with the processed array
{
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
        NSLog(@"PROCESSEDWORDS:%lu, %@", (unsigned long)processedWords.count, processedWords);
    }
}

- (void)doSearchWithArray: (NSArray *)searchArray  //search with the current event and the received word array
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getPeople:self withSearch:searchArray forEvent:event];
}

- (void)processData: (NSArray *) results  //callback for attendee(people) results, with or without search
{
    [attendeeArrray removeAllObjects];
    attendeeArrray = [results mutableCopy];
    [self.attendeeTable reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"attendeedetailsegue"]) {
        AttendeeDetailView *controller = (AttendeeDetailView *) segue.destinationViewController;
        controller.attendee = selectedAttendee;
    }
}

@end

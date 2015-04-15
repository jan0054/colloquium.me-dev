//
//  TimelineViewController.m
//  a_gentle_sunset
//
//  Created by csjan on 3/26/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelineViewController.h"
#import <Parse/Parse.h>
#import <ParseUI.h>
#import "TimelineCell.h"
#import "PostDetailViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface TimelineViewController ()

@end

NSString *selected_post_content;
NSString *selected_elder_name;
NSString *selected_author_name;
NSString *selected_post_time;
PFObject *selected_post;

@implementation TimelineViewController

- (void)commonInit
{
    // The className to query on
    self.parseClassName = @"post";
    
    // The key of the PFObject to display in the label of the default cell style
    self.textKey = @"content";
    
    // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
    self.imageKey = @"image";
    
    // Whether the built-in pull-to-refresh is enabled
    self.pullToRefreshEnabled = YES;
    
    // Whether the built-in pagination is enabled
    self.paginationEnabled = YES;
    
    // The number of objects to show per page
    self.objectsPerPage = 25;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) return nil;
    [self commonInit];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    [self setupLeftMenuButton];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}


 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
     PFQuery *query = [PFQuery queryWithClassName:@"post"];
 
 // If Pull To Refresh is enabled, query against the network by default.
 //if (self.pullToRefreshEnabled) {
 //query.cachePolicy = kPFCachePolicyNetworkOnly;
 //}
 
 //csj: this crashes with local datastore enabled: seems to be a parse bug
 // If no objects are loaded in memory, we look to the cache first to fill the table
 // and then subsequently do a query against the network.
 //if (self.objects.count == 0) {
 //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 //}
 
 [query orderByDescending:@"createdAt"];
 
 return query;
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    static NSString *CellIdentifier = @"timelinecell";
    TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell
    cell.timeline_content.text = [object objectForKey:@"content"];
    cell.timeline_image.image = [UIImage imageNamed:@"placeholder_image"];
    cell.timeline_image.file = [object objectForKey:@"image"];
    [cell.timeline_image loadInBackground];
    cell.timeline_elder_name.text = [object objectForKey:@"source_elder_name"];
    cell.timeline_author_name.text = [object objectForKey:@"author_name"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSDate *created = [object objectForKey:@"post_date"];
    NSString *dateString = [dateFormat stringFromDate:created];
    cell.timeline_time.text = dateString;
    return cell;
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    PFObject *post = [self objectAtIndexPath:indexPath];
    selected_post = post;
    selected_post_content = [post objectForKey:@"content"];
    selected_author_name = [post objectForKey:@"author_name"];
    selected_elder_name = [post objectForKey:@"source_elder_name"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm"];
    NSDate *created = [post objectForKey:@"post_date"];
    NSString *dateString = [dateFormat stringFromDate:created];
    selected_post_time = dateString;
    
    [self performSegueWithIdentifier:@"postdetailsegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"postdetailsegue"])
    {
        PostDetailViewController *destination = [segue destinationViewController];
        destination.timeline_content = selected_post_content;
        destination.timeline_author = selected_author_name;
        destination.timeline_elder = selected_elder_name;
        destination.timeline_time = selected_post_time;
        destination.timeline_post = selected_post;
    }
}

- (IBAction)new_post_button_tap:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"newpostsegue" sender:self];
}

@end

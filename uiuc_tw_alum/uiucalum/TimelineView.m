//
//  TimelineView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelineView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "TimelineCell.h"
#import "TimelineDetailView.h"

NSMutableArray *postArray;
PFObject *selectedPost;
UIImage *selectedImage;

@implementation TimelineView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    postArray = [[NSMutableArray alloc] init];
    
    //styling
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.timelineTable.tableFooterView = [[UIView alloc] init];
    self.noPostLabel.hidden = YES;
    self.noPostLabel.textColor = [UIColor dark_accent];
    self.timelineTable.estimatedRowHeight = 200.0;
    self.timelineTable.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
    self.timelineTable.backgroundColor = [UIColor light_bg];
    self.view.backgroundColor = [UIColor light_bg];

    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getPosts:self forEvent:event];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.timelineTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getPosts:self forEvent:event];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.timelineTable respondsToSelector:@selector(layoutMargins)]) {
        self.timelineTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)addPostButtonTap:(UIBarButtonItem *)sender {
    if ([PFUser currentUser])
    {
        [self performSegueWithIdentifier:@"timelinepostsegue" sender:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_need_account", nil)
                                    message:NSLocalizedString(@"alert_sign_in", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                          otherButtonTitles:nil] show];
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
    return [postArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelinecell"];
    
    //styling
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.timeLabel.textColor = [UIColor secondary_text];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.backgroundCardView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundCardView.layer.shouldRasterize = YES;
    cell.backgroundCardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundCardView.layer.shadowColor = [UIColor shadow_color].CGColor;
    cell.backgroundCardView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    cell.backgroundCardView.layer.shadowOpacity = 0.3f;
    cell.backgroundCardView.layer.shadowRadius = 1.0f;
    [cell.avatarImageView setTintColor:[UIColor shadow_color]];
    UIImage *img = [UIImage imageNamed:@"avatarlight48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.avatarImageView.image = img;
    
    //data
    PFObject *post = [postArray objectAtIndex:indexPath.row];
    PFUser *author = post[@"author"];
    NSDate *time = post.createdAt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MM-dd HH:mm"];
    NSString *timeString = [dateFormat stringFromDate:time];
    
    cell.contentLabel.text = post[@"content"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    cell.timeLabel.text = timeString;
    cell.postImage.clipsToBounds = YES;
    cell.postImage.image = nil;
    cell.postImage.file = [post objectForKey:@"preview"];
    [cell.postImage loadInBackground];
    
    if (cell.postImage.file == NULL)
    {
        cell.imageRatio.active = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *post = [postArray objectAtIndex:indexPath.row];
    selectedPost = post;
    TimelineCell *cell = (TimelineCell *) [self.timelineTable cellForRowAtIndexPath:indexPath];
    selectedImage = cell.postImage.image;
    [self performSegueWithIdentifier:@"timelinedetailsegue" sender:self];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [postArray removeAllObjects];
    postArray = [results mutableCopy];
    [self.timelineTable reloadData];
    
    if (postArray.count >0)
    {
        self.noPostLabel.hidden = YES;
    }
    else
    {
        self.noPostLabel.hidden = NO;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"timelinedetailsegue"]) {
        TimelineDetailView *controller = (TimelineDetailView *) segue.destinationViewController;
        controller.currentPost = selectedPost;
        controller.currentImage = selectedImage;
    }
}

@end

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

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    postArray = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.timelineTable.tableFooterView = [[UIView alloc] init];
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getPosts:self forEvent:event];
}

- (void) viewDidLayoutSubviews
{
    //styling
    if ([self.timelineTable respondsToSelector:@selector(layoutMargins)]) {
        self.timelineTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)addPostButtonTap:(UIBarButtonItem *)sender {
    
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

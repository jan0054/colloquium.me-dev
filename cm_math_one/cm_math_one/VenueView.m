//
//  VenueView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "VenueView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "VenueCell.h"
#import <MapKit/MapKit.h>

NSMutableArray *venueArray;

@implementation VenueView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    venueArray = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.venueTable.estimatedRowHeight = 120.0;
    self.venueTable.rowHeight = UITableViewAutomaticDimension;
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getVenue:self forEvent:event];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.venueTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getVenue:self forEvent:event];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)callButtonTap:(UIButton *)sender {
    VenueCell *cell = (VenueCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venueTable indexPathForCell:cell];
    PFObject *venue = [venueArray objectAtIndex:tapped_path.row];
    NSString *rawphone = venue[@"phone"];
    if (rawphone.length>1)
    {
        NSString *phonenumber = [@"tel:" stringByAppendingString:rawphone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenumber]];
    }
}

- (IBAction)webButtonTap:(UIButton *)sender {
    VenueCell *cell = (VenueCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venueTable indexPathForCell:cell];
    PFObject *venue = [venueArray objectAtIndex:tapped_path.row];
    NSString *urlstr = venue[@"url"];
    if (urlstr.length>1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
    }
}

- (IBAction)navButtonTap:(UIButton *)sender {
    VenueCell *cell = (VenueCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venueTable indexPathForCell:cell];
    PFObject *venue = [venueArray objectAtIndex:tapped_path.row];
    PFGeoPoint *location = venue[@"coord"];
    if (location != NULL)
    {
        double lat = location.latitude;
        double lon = location.longitude;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:venue[@"name"]];
        [self displayRegionCenteredOnMapItem:mapItem];
    }
}

- (void) viewDidLayoutSubviews
{
    if ([self.venueTable respondsToSelector:@selector(layoutMargins)]) {
        self.venueTable.layoutMargins = UIEdgeInsetsZero;
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [venueArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venuecell"];
    PFObject *venue = [venueArray objectAtIndex:indexPath.row];
    
    //data
    PFFile *venueimage = venue[@"image"];
    [venueimage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.venueImage.image = [UIImage imageWithData:imageData];
        }
    }];
    cell.nameLabel.text = venue[@"name"];
    cell.contentLabel.text = venue[@"content"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImage *img1 = [UIImage imageNamed:@"phone48"];
    img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.callButton setTintColor:[UIColor dark_button_txt]];
    [cell.callButton setImage:img1 forState:UIControlStateNormal];
    [cell.callButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    UIImage *img2 = [UIImage imageNamed:@"web48"];
    img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //[cell.webButton setTintColor:[UIColor dark_button_txt]];
    //[cell.webButton setImage:img2 forState:UIControlStateNormal];
    [cell.webButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    UIImage *img3 = [UIImage imageNamed:@"nav48"];
    img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.navButton setTintColor:[UIColor dark_button_txt]];
    [cell.navButton setImage:img3 forState:UIControlStateNormal];
    [cell.navButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    cell.venueImage.layer.cornerRadius = 30.0;
    cell.venueImage.clipsToBounds = YES;
    
    return cell;
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [venueArray removeAllObjects];
    venueArray = [results mutableCopy];
    [self.venueTable reloadData];
}

- (void)displayRegionCenteredOnMapItem:(MKMapItem*)from {
    CLLocation* fromLocation = from.placemark.location;
    
    // Create a region centered on the starting point with a 2km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 2000, 2000);
    
    // Open the item in Maps, specifying the map region to display.
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:from]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}


@end

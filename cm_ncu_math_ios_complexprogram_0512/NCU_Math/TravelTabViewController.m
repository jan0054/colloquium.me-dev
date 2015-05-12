//
//  TravelTabViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "TravelTabViewController.h"
#import "UIColor+ProjectColors.h"
#import "VenueCellTableViewCell.h"

@interface TravelTabViewController ()

@end

@implementation TravelTabViewController
@synthesize venue_array;
@synthesize pullrefresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.venue_array = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor background];
    self.venuetable.backgroundColor = [UIColor clearColor];
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.venuetable addSubview:pullrefresh];
    
    [self get_venue_data];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.venuetable.tableFooterView = [[UIView alloc] init];
}

- (void) viewDidLayoutSubviews
{
    if ([self.venuetable respondsToSelector:@selector(layoutMargins)]) {
        self.venuetable.layoutMargins = UIEdgeInsetsZero;
    }
}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_venue_data];
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.venue_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueCellTableViewCell *venuecell = [tableView dequeueReusableCellWithIdentifier:@"venuecell"];
    
    PFObject *venue = [self.venue_array objectAtIndex:indexPath.row];
    venuecell.venue_name_label.text = venue[@"name"];
    venuecell.venue_address_label.text = venue[@"address"];
    venuecell.venue_description_textview.text = venue[@"content"];
    PFFile *venueimage = venue[@"image"];
    [venueimage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            venuecell.venue_photo.image = [UIImage imageWithData:imageData];
        }
    }];
    
    venuecell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([venuecell respondsToSelector:@selector(layoutMargins)]) {
        venuecell.layoutMargins = UIEdgeInsetsZero;
    }
    
    venuecell.card_view.backgroundColor = [UIColor light_bg];
    venuecell.card_view.alpha = 1.0;
    venuecell.venue_address_label.textColor = [UIColor light_txt];
    venuecell.venue_trim_view.backgroundColor = [UIColor clearColor];
    venuecell.venue_bar_view.backgroundColor = [UIColor dark_bg];
    //venuecell.card_view.layer.cornerRadius = 2;
    
    //add shadow to views
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:venuecell.venue_background_view.bounds];
    venuecell.venue_background_view.layer.masksToBounds = NO;
    venuecell.venue_background_view.layer.shadowColor = [UIColor blackColor].CGColor;
    venuecell.venue_background_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    venuecell.venue_background_view.layer.shadowOpacity = 0.3f;
    venuecell.venue_background_view.layer.shadowPath = shadowPath.CGPath;
    
    UIImage *call_img = [UIImage imageNamed:@"action_call.png"];
    call_img = [call_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [venuecell.venue_call_button setTintColor:[UIColor dark_button_txt]];
    [venuecell.venue_call_button setImage:call_img forState:UIControlStateNormal];
    [venuecell.venue_call_button setImage:call_img forState:UIControlStateSelected];
    
    UIImage *web_img = [UIImage imageNamed:@"action_website.png"];
    web_img = [web_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [venuecell.venue_website_button setTintColor:[UIColor dark_button_txt]];
    [venuecell.venue_website_button setImage:web_img forState:UIControlStateNormal];
    [venuecell.venue_website_button setImage:web_img forState:UIControlStateSelected];
    
    UIImage *nav_img = [UIImage imageNamed:@"action_navigation.png"];
    nav_img = [nav_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [venuecell.venue_navigate_button setTintColor:[UIColor light_button_txt]];
    [venuecell.venue_navigate_button setImage:nav_img forState:UIControlStateNormal];
    [venuecell.venue_navigate_button setImage:nav_img forState:UIControlStateSelected];
    
    return venuecell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) get_venue_data
{
    PFQuery *venuequery = [PFQuery queryWithClassName:@"Venue"];
    [venuequery orderByDescending:@"order"];
    [venuequery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"poi query success");
        [self.venue_array removeAllObjects];
        for (PFObject *poi_obj in objects)
        {
            [self.venue_array addObject:poi_obj];
        }
        [self.venuetable reloadData];
    }];

}

- (IBAction)venue_call_tap:(UIButton *)sender {
    VenueCellTableViewCell *cell = (VenueCellTableViewCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venuetable indexPathForCell:cell];
    NSLog(@"venue_call_tap: %ld", (long)tapped_path.row);
    PFObject *venue = [self.venue_array objectAtIndex:tapped_path.row];
    NSString *rawphone = venue[@"phone"];
    NSString *phonenumber = [@"tel:" stringByAppendingString:rawphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenumber]];
}




- (IBAction)venue_navigate_tap:(UIButton *)sender {
    VenueCellTableViewCell *cell = (VenueCellTableViewCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venuetable indexPathForCell:cell];
    NSLog(@"venue_navigate_tap: %ld", (long)tapped_path.row);
    PFObject *venue = [self.venue_array objectAtIndex:tapped_path.row];
    PFGeoPoint *location = venue[@"coord"];
    double lat = location.latitude;
    double lon = location.longitude;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:venue[@"name"]];
    [self displayRegionCenteredOnMapItem:mapItem];
}

- (IBAction)venue_website_tap:(UIButton *)sender {
    VenueCellTableViewCell *cell = (VenueCellTableViewCell *)[[[[sender superview] superview] superview] superview];
    NSIndexPath *tapped_path = [self.venuetable indexPathForCell:cell];
    NSLog(@"venue_website_tap: %ld", (long)tapped_path.row);
    PFObject *venue = [self.venue_array objectAtIndex:tapped_path.row];
    NSString *urlstr = venue[@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];

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

//
//  VenueCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VenueCellTableViewCell : UITableViewCell
//@property (strong, nonatomic) IBOutlet MKMapView *venuemap;
@property (strong, nonatomic) IBOutlet UILabel *venue_name_label;
@property (strong, nonatomic) IBOutlet UILabel *venue_address_label;
@property (strong, nonatomic) IBOutlet UIButton *venue_call_button;
@property (strong, nonatomic) IBOutlet UIButton *venue_navigate_button;
@property (strong, nonatomic) IBOutlet UIButton *venue_website_button;

@property (strong, nonatomic) IBOutlet UIView *card_view;
@property (strong, nonatomic) IBOutlet UIImageView *venue_photo;
@property (strong, nonatomic) IBOutlet UIView *venue_trim_view;
@property (strong, nonatomic) IBOutlet UIView *venue_background_view;
@property (strong, nonatomic) IBOutlet UIView *venue_bar_view;
@property (strong, nonatomic) IBOutlet UIView *venue_transparent_background;
@property (weak, nonatomic) IBOutlet UITextView *venue_description_textview;




@end

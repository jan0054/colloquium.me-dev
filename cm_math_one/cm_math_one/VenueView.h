//
//  VenueView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ParseQueries.h"

@interface VenueView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *venueTable;
- (IBAction)callButtonTap:(UIButton *)sender;
- (IBAction)webButtonTap:(UIButton *)sender;
- (IBAction)navButtonTap:(UIButton *)sender;
- (void)processData: (NSArray *) results;

@end

//
//  ElderCell.h
//  a_gentle_sunset
//
//  Created by csjan on 4/28/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PFTableViewCell.h"

@interface ElderCell : PFTableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *elder_image;
@property (strong, nonatomic) IBOutlet UILabel *elder_name;
@property (strong, nonatomic) IBOutlet UILabel *elder_age;

@end

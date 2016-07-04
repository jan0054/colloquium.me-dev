//
//  StreamLinkCell.h
//  cm_math_one
//
//  Created by csjan on 3/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamLinkCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *backgroundCardView;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *viewLabel;
@property NSString *videoId;
@end

//
//  WordSharingCell.h
//  cm_math_one
//
//  Created by csjan on 4/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WordSharingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *shareTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *shareDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property PFObject *sharedItem;
@end

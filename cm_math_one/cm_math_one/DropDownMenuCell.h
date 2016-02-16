//
//  DropDownMenuCell.h
//  cm_math_one
//
//  Created by csjan on 2/16/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YALContextMenuCell.h"

@interface DropDownMenuCell : UITableViewCell<YALContextMenuCell>
@property (strong, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *menuImageView;
@end

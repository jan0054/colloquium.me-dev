//
//  ChatOptionCell.h
//  cm_math_one
//
//  Created by csjan on 8/7/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatOptionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *institutionLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;



@end

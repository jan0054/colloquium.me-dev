//
//  DropDownMenuCell.m
//  cm_math_one
//
//  Created by csjan on 2/16/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import "DropDownMenuCell.h"
@interface DropDownMenuCell ()

@end
@implementation DropDownMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.masksToBounds = YES;
    //self.layer.shadowOffset = CGSizeMake(0, 2);
    //self.layer.shadowColor = [[UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1] CGColor];
    //self.layer.shadowRadius = 5;
    //self.layer.shadowOpacity = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - YALContextMenuCell

- (UIView *)animatedContent {
    return self.menuTitleLabel;
}

- (UIView*)animatedIcon {
    return self.menuImageView;
}

@end

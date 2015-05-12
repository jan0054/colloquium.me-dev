//
//  DiscussionTableViewCell.h
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/30/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussionTableViewCell : UITableViewCell<UITextFieldDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *author_label;
@property (weak, nonatomic) IBOutlet UILabel *content_label;

@end

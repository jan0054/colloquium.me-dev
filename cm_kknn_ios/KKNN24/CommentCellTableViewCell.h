//
//  CommentCellTableViewCell.h
//  KKNN24
//
//  Created by csjan on 5/25/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *comment_author_label;
@property (strong, nonatomic) IBOutlet UILabel *comment_time_label;
@property (strong, nonatomic) IBOutlet UILabel *comment_content_label;

@end

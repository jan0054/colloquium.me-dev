//
//  PostCommentCell.h
//  a_gentle_sunset
//
//  Created by csjan on 4/8/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PFTableViewCell.h"

@interface PostCommentCell : PFTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *comment_content;
@property (strong, nonatomic) IBOutlet UILabel *comment_author;
@property (strong, nonatomic) IBOutlet UILabel *comment_time;

@end

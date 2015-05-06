//
//  ConversationCellTableViewCell.h
//  SQuInt2014
//
//  Created by csjan on 10/13/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *conversation_name_label;
@property (strong, nonatomic) IBOutlet UILabel *conversation_msg_label;
@property (strong, nonatomic) IBOutlet UILabel *conversation_time_label;
@property (strong, nonatomic) IBOutlet UIImageView *conversation_new_image;
@property (weak, nonatomic) IBOutlet UILabel *conversation_new_label;

@property (strong, nonatomic) IBOutlet UIView *conversation_card_view;

@end

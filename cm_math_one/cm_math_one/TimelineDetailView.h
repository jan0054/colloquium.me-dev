//
//  TimelineDetailView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TimelineDetailView : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *commentTable;
@property (strong, nonatomic) IBOutlet UIView *inputBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendButtonTap:(UIButton *)sender;

@property PFObject *currentPost;
@property UIImage *currentImage;

- (void)processData: (NSArray *) results;
- (void)commentPostedCallback;

@end

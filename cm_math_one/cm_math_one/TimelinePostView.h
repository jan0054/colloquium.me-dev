//
//  TimelinePostView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@interface TimelinePostView : UIViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *horizontalBarBackground;
@property (strong, nonatomic) IBOutlet SZTextView *inputTextView;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UIButton *addPhotoButton;
- (IBAction)addPhotoButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *keyboardButton;
- (IBAction)keyboardButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelPhotoButton;
- (IBAction)cancelPhotoButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendPostButton;
- (IBAction)sendPostButtonTap:(UIBarButtonItem *)sender;

- (void)postCallback;

@end

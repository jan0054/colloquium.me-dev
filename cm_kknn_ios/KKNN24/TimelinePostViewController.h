//
//  TimelinePostViewController.h
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"


@interface TimelinePostViewController : UIViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *confirm_post_button;
- (IBAction)confirm_post_button_tap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancel_post_button;
- (IBAction)cancel_post_button_tap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet SZTextView *content_textview;

@property (strong, nonatomic) IBOutlet UIImageView *post_image;
@property (strong, nonatomic) IBOutlet UIButton *cancel_image_button;
- (IBAction)cancel_image_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *bottom_view;

@property (strong, nonatomic) IBOutlet UIButton *library_button;
- (IBAction)library_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *bottom_view_trim;
@property (strong, nonatomic) IBOutlet UIView *cancel_image_button_guide;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_keyboard_spacing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textview_keyboard_spacing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *image_ratio;
@property (strong, nonatomic) IBOutlet UIButton *dismiss_keyboard_button;
- (IBAction)dismiss_beyboard_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom_bar_height;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *image_to_bottom_bar;

@end

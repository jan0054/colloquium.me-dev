//
//  NewPostViewController.h
//  a_gentle_sunset
//
//  Created by csjan on 3/26/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface NewPostViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *image_preview;
- (IBAction)camera_button_tap:(UIButton *)sender;
- (IBAction)library_button_tap:(UIButton *)sender;
- (IBAction)post_button_tap:(UIBarButtonItem *)sender;
- (IBAction)cancel_button_tap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIButton *library_button;
@property (strong, nonatomic) IBOutlet UIButton *camera_button;
@property (strong, nonatomic) IBOutlet UITextView *post_content;

@end

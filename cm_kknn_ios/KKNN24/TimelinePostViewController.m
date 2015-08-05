//
//  TimelinePostViewController.m
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelinePostViewController.h"
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>
#import "GKImagePicker.h"

@interface TimelinePostViewController ()<GKImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) GKImagePicker *imagePicker;

@end

BOOL is_new_photo;
BOOL photo_is_set;


@implementation TimelinePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    self.view.backgroundColor = [UIColor background];
    self.bottom_view.backgroundColor = [UIColor light_bg];
    self.bottom_view_trim.backgroundColor = [UIColor divider_color];
    [self.library_button setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.library_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    self.cancel_image_button.layer.masksToBounds = NO;
    self.cancel_image_button.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cancel_image_button.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.cancel_image_button.layer.shadowOpacity = 0.3f;
    self.cancel_image_button.layer.shadowRadius = 0.5f;
    UIImage *cam_img = [UIImage imageNamed:@"camera48.png"];
    cam_img = [cam_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.library_button setTintColor:[UIColor dark_accent]];
    [self.library_button setImage:cam_img forState:UIControlStateNormal];
    [self.library_button setImage:cam_img forState:UIControlStateSelected];
    UIImage *key_img = [UIImage imageNamed:@"key_down48.png"];
    key_img = [key_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.dismiss_keyboard_button setTintColor:[UIColor dark_accent]];
    [self.dismiss_keyboard_button setImage:key_img forState:UIControlStateNormal];
    [self.dismiss_keyboard_button setImage:key_img forState:UIControlStateSelected];

    //init
    self.cancel_image_button.hidden = YES;
    self.cancel_image_button.userInteractionEnabled = NO;
    self.textview_keyboard_spacing.active = NO;
    self.image_ratio.active = NO;
    self.dismiss_keyboard_button.hidden = YES;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UI Actions

- (IBAction)confirm_post_button_tap:(UIBarButtonItem *)sender {
    [self upload_post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel_post_button_tap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel_image_button_tap:(UIButton *)sender {
    self.post_image.image = nil;
    photo_is_set = NO;
    self.image_ratio.active = NO;
    self.cancel_image_button.hidden = YES;
    self.cancel_image_button.userInteractionEnabled = NO;
    [self.content_textview resignFirstResponder];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsDisplay];
}

- (IBAction)library_button_tap:(UIButton *)sender {
    //[self useLibrary:nil];
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(640, 640);
    self.imagePicker.delegate = self;
    self.imagePicker.useFrontCameraAsDefault = NO;

    [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:sender];
}

#pragma mark - Data

- (void) upload_post
{
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    PFUser *user = [PFUser currentUser];
    post[@"author_name"] = user[@"username"];
    post[@"author"] = user;
    post[@"content"] = self.content_textview.text;
    if (photo_is_set)
    {
        CGSize img_param = CGSizeMake(1080.0, 1080.0);
        UIImage *smallpic = [self shrinkImage:self.post_image.image withSize:img_param];
        NSData *imageData = UIImagePNGRepresentation(smallpic);
        PFFile *imageFile = [PFFile fileWithName:[self generate_filename] data:imageData];
        post[@"image"] = imageFile;
    }
    
    [post saveInBackground];
}

- (NSString *) generate_filename {
    PFUser *user = [PFUser currentUser];
    NSString *uname = user.username;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyyMMddHHmm"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"%@%@.png",uname,dateString];
    return filename;
}

#pragma mark - Imaging

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    self.post_image.image = image;
    photo_is_set = YES;
    self.cancel_image_button.hidden = NO;
    self.cancel_image_button.userInteractionEnabled = YES;
    self.image_ratio.active = YES;
}

- (UIImage *)shrinkImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboard will show");
    self.dismiss_keyboard_button.hidden = NO;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photo_is_set)
    {
        self.textview_keyboard_spacing.active = YES;
        //30 is up to how much of the top of the photo you want to show
        self.textview_keyboard_spacing.constant = height+self.bottom_bar_height.constant+30;
        self.bottom_keyboard_spacing.constant = height;
        self.image_to_bottom_bar.active = NO;
    }
    else
    {
        self.bottom_keyboard_spacing.constant = height;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboard will hide");
    self.dismiss_keyboard_button.hidden = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photo_is_set)
    {
        self.textview_keyboard_spacing.active = NO;
        self.bottom_keyboard_spacing.constant = 0;
        self.image_to_bottom_bar.active = YES;
    }
    else
    {
        self.textview_keyboard_spacing.active = NO;
        self.bottom_keyboard_spacing.constant = 0;
        self.image_to_bottom_bar.active = YES;
    }
    
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (IBAction)dismiss_beyboard_button_tap:(UIButton *)sender {
    [self.content_textview resignFirstResponder];
}

@end

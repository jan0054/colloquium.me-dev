//
//  TimelinePostView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelinePostView.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "GKImagePicker.h"

@interface TimelinePostView ()<GKImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) GKImagePicker *imagePicker;

@end

BOOL photoSet;

@implementation TimelinePostView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    self.cancelPhotoButton.hidden = YES;
    self.cancelPhotoButton.userInteractionEnabled = NO;
    //self.textview_keyboard_spacing.active = NO;
    //self.image_ratio.active = NO;
    self.keyboardButton.hidden = YES;

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

- (IBAction)addPhotoButtonTap:(UIButton *)sender {
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(640, 640);
    self.imagePicker.delegate = self;
    self.imagePicker.useFrontCameraAsDefault = NO;
    
    [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:sender];
}

- (IBAction)keyboardButtonTap:(UIButton *)sender {
    [self.inputTextView resignFirstResponder];
}

- (IBAction)cancelPhotoButtonTap:(UIButton *)sender {
    self.postImageView.image = nil;
    photoSet = NO;
    //self.image_ratio.active = NO;
    self.cancelPhotoButton.hidden = YES;
    self.cancelPhotoButton.userInteractionEnabled = NO;
    [self.inputTextView resignFirstResponder];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsDisplay];

}

- (IBAction)sendPostButtonTap:(UIBarButtonItem *)sender {
    if ([PFUser currentUser] && self.inputTextView.text.length>0)
    {
        [self doProcessPost];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Data

- (void)doProcessPost
{
    CGSize img_param = CGSizeMake(1080.0, 1080.0);
    UIImage *smallpic = [self shrinkImage:self.postImageView.image withSize:img_param];
    NSData *imageData = UIImagePNGRepresentation(smallpic);
    PFFile *imageFile = [PFFile fileWithName:[self generate_filename] data:imageData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self sentPost:self withAuthor:[PFUser currentUser] withContent:self.inputTextView.text withImage:imageFile forEvent:event];
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
    self.postImageView.image = image;
    photoSet = YES;
    self.cancelPhotoButton.hidden = NO;
    self.cancelPhotoButton.userInteractionEnabled = YES;
    //self.image_ratio.active = YES;
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
    self.keyboardButton.hidden = NO;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photoSet)
    {
        //self.textview_keyboard_spacing.active = YES;
        //30 is up to how much of the top of the photo you want to show
        //self.textview_keyboard_spacing.constant = height+self.bottom_bar_height.constant+30;
        //self.bottom_keyboard_spacing.constant = height;
        //self.image_to_bottom_bar.active = NO;
    }
    else
    {
        //self.bottom_keyboard_spacing.constant = height;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboard will hide");
    self.keyboardButton.hidden = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photoSet)
    {
        //self.textview_keyboard_spacing.active = NO;
        //self.bottom_keyboard_spacing.constant = 0;
        //self.image_to_bottom_bar.active = YES;
    }
    else
    {
        //self.textview_keyboard_spacing.active = NO;
        //self.bottom_keyboard_spacing.constant = 0;
        //self.image_to_bottom_bar.active = YES;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}


@end
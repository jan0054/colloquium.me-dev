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

@interface TimelinePostViewController ()

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
    [self.add_photo_label setTextColor:[UIColor dark_txt]];
    [self.camera_button setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.camera_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    [self.library_button setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.library_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    
    //init
    self.cancel_image_button.hidden = YES;
    self.cancel_image_button.userInteractionEnabled = NO;
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
    self.cancel_image_button.hidden = YES;
    self.cancel_image_button.userInteractionEnabled = NO;
}

- (IBAction)camera_button_tap:(UIButton *)sender {
    [self newPhoto:nil];
}

- (IBAction)library_button_tap:(UIButton *)sender {
    [self useLibrary:nil];
}

#pragma mark - Data

- (void) upload_post
{
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    PFUser *user = [PFUser currentUser];
    post[@"author_name"] = user[@"username"];
    post[@"author"] = user;
    post[@"content"] = self.content_textview.text;
    CGSize img_param = CGSizeMake(400.0, 400.0);
    UIImage *smallpic = [self shrinkImage:self.post_image.image withSize:img_param];
    NSData *imageData = UIImagePNGRepresentation(smallpic);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    post[@"image"] = imageFile;
    
    [post saveInBackground];
}

#pragma mark - Imaging

- (void) newPhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        is_new_photo = YES;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}

- (void) useLibrary:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = NO;
        is_new_photo = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
}

- (UIImage *)shrinkImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.post_image.image = image;
    photo_is_set = YES;
    self.cancel_image_button.hidden = NO;
    self.cancel_image_button.userInteractionEnabled = YES;
    if (is_new_photo)
    {
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:didFinishSavingWithError:contextInfo:),
                                       nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


@end

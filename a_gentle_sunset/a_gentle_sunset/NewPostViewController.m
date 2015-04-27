//
//  NewPostViewController.m
//  a_gentle_sunset
//
//  Created by csjan on 3/26/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "NewPostViewController.h"

@interface NewPostViewController ()

@end

BOOL is_new_photo;
BOOL photo_is_set;

@implementation NewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (IBAction)camera_button_tap:(UIButton *)sender {
    [self newPhoto:nil];
}

- (IBAction)library_button_tap:(UIButton *)sender {
    [self useLibrary:nil];
}

- (IBAction)post_button_tap:(UIBarButtonItem *)sender {
    [self upload_post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel_button_tap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //self.image_preview.contentMode = UIViewContentModeScaleAspectFill;
    self.image_preview.image = image;
    photo_is_set = YES;
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

- (void) upload_post
{
    PFObject *new_post = [PFObject objectWithClassName:@"post"];
    new_post[@"post_date"] = [NSDate date];
    //new_post[@"source_elder"] =
    //new_post[@"source_elder_name"] =
    PFUser *curu = [PFUser currentUser];
    new_post[@"author_name"] = curu[@"username"];
    new_post[@"author"] = curu;
    new_post[@"content"] = self.post_content.text;
    NSData *imageData = UIImagePNGRepresentation(self.image_preview.image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    new_post[@"image"] = imageFile;
    
    [new_post saveInBackground];
}


@end

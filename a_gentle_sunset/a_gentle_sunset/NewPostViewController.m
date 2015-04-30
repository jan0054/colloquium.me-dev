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
NSMutableArray *received_elder_list;

@implementation NewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    received_elder_list = [[NSMutableArray alloc] init];
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
    PFRelation *elder_relation = [new_post relationForKey:@"source_elder"];
    NSString *elder_names = @"";
    for (PFObject *elder in received_elder_list)
    {
        [elder_relation addObject:elder];
        elder_names = [NSString stringWithFormat:@"%@ %@", elder_names, elder[@"name"]];
    }
    new_post[@"source_elder_name"] = elder_names;
    PFUser *curu = [PFUser currentUser];
    new_post[@"author_name"] = curu[@"username"];
    new_post[@"author"] = curu;
    new_post[@"content"] = self.post_content.text;
    CGSize img_param = CGSizeMake(400.0, 400.0);
    UIImage *smallpic = [self shrinkImage:self.image_preview.image withSize:img_param];
    NSData *imageData = UIImagePNGRepresentation(smallpic);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    new_post[@"image"] = imageFile;
    
    [new_post saveInBackground];
}


- (IBAction)select_elder_button_tap:(UIButton *)sender {
    [self performSegueWithIdentifier:@"selecteldersegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selecteldersegue"])
    {
        //going to select elder controller, set the delegate
        UINavigationController *controller = [segue destinationViewController];
        ChooseElderTableViewController *tvcon = [controller.viewControllers objectAtIndex:0];
        tvcon.elder_delegate = self;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void) getElderList:(NSMutableArray *)elder_list
{
    [received_elder_list removeAllObjects];
    received_elder_list = elder_list;
    NSString *list = @"";
    for (PFObject *elder in received_elder_list)
    {
        NSString *name = elder[@"name"];
        list = [NSString stringWithFormat:@"%@ %@", list, name];
    }
    self.elder_list_label.text = [NSString stringWithFormat:@"照護對象:%@", list];
}

- (UIImage *)shrinkImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end

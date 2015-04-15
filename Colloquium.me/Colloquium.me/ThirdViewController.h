//
//  ThirdViewController.h
//  Colloquium.me
//
//  Created by csjan on 3/20/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)camera_tap:(UIButton *)sender;
- (IBAction)upload_tap:(UIButton *)sender;
- (IBAction)library_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *preview_imageview;


@end

//
//  SecondViewController.h
//  Colloquium.me
//
//  Created by csjan on 3/20/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SecondViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property AVCaptureSession *captureSession;


@end

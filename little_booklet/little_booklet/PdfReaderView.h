//
//  PdfReaderView.h
//  cm_math_one
//
//  Created by csjan on 12/1/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PdfReaderView : UIViewController<UIDocumentInteractionControllerDelegate, UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *pdfWebView;
@property (strong, nonatomic) IBOutlet UIView *bottomControlView;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)shareButtonTap:(UIButton *)sender;
- (IBAction)exitButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
- (IBAction)webViewTapped:(UITapGestureRecognizer *)sender;

@property PFFile *pdfPFFile;

@end

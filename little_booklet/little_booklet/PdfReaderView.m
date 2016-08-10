//
//  PdfReaderView.m
//  cm_math_one
//
//  Created by csjan on 12/1/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import "PdfReaderView.h"
#import "UIColor+ProjectColors.h"

BOOL bottomIsVisible;
UIDocumentInteractionController *docController;
NSURL *localUrl;

@implementation PdfReaderView

#pragma mark - Interface

- (void)viewDidLoad {
    
    //init
    [super viewDidLoad];
    bottomIsVisible = NO;
    self.bottomControlView.hidden = YES;
    self.loadingLabel.hidden = NO;
    
    //styling
    self.bottomControlView.backgroundColor = [UIColor dark_bg];
    [self.exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.shareButton.imageView setTintColor:[UIColor whiteColor]];
    UIImage* img = [UIImage imageNamed:@"share48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.shareButton setImage:img forState:UIControlStateNormal];
    [self.shareButton setImage:img forState:UIControlStateHighlighted];
    [self.shareButton setTitle:NSLocalizedString(@"open_with", nil) forState:UIControlStateNormal];
    [self.shareButton setTitle:NSLocalizedString(@"open_with", nil) forState:UIControlStateHighlighted];
    [self.exitButton setTitle:NSLocalizedString(@"exit", nil) forState:UIControlStateNormal];
    [self.exitButton setTitle:NSLocalizedString(@"exit", nil) forState:UIControlStateHighlighted];
    
    //data
    NSString *origName = self.pdfPFFile.name;
    NSString *docPath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
    NSString *filePath = [docPath
                          stringByAppendingPathComponent:origName];
    NSLog(@"FILE:%@", filePath);
    //if we haven't downloaded this file before, do it now
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        //download the file
        [self.pdfPFFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error==NULL)
            {
                NSLog(@"PDF data loaded from parse!");
                BOOL success = [data writeToFile:filePath atomically:YES];
                if (success)
                {
                    NSLog(@"file creation success");
                }
                self.loadingLabel.hidden = YES;
                // Now create Request for the file that was saved in your documents folder
                localUrl = [NSURL fileURLWithPath:filePath];
                NSURLRequest *requestObj = [NSURLRequest requestWithURL:localUrl];
                [self.pdfWebView setDelegate:self];
                [self.pdfWebView loadRequest:requestObj];
            }
        }];
    }
    else
    {
        self.loadingLabel.hidden = YES;
        NSLog(@"PDF data loaded from existing file");
        // Now create Request for the file that was saved in your documents folder
        localUrl = [NSURL fileURLWithPath:filePath];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:localUrl];
        [self.pdfWebView setDelegate:self];
        [self.pdfWebView loadRequest:requestObj];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (IBAction)shareButtonTap:(UIButton *)sender {
    docController = [UIDocumentInteractionController interactionControllerWithURL:localUrl];
    docController.delegate = self;
    [docController presentOpenInMenuFromRect:CGRectZero
                                           inView:self.view animated:YES];
}

- (IBAction)exitButtonTap:(UIButton *)sender {
    [self exitOut];
}

- (IBAction)webViewTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"webview tapped");
    if (bottomIsVisible)
    {
        self.bottomControlView.hidden = YES;
        bottomIsVisible = NO;
    }
    else
    {
        self.bottomControlView.hidden = NO;
        bottomIsVisible = YES;
    }
}

#pragma mark - Data

- (void)exitOut
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

//
//  AbstractPdfViewController.h
//  SQuInt2014
//
//  Created by csjan on 9/10/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AbstractPdfViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *abstract_name_label;
@property (strong, nonatomic) IBOutlet UILabel *abstract_author_label;
@property (strong, nonatomic) IBOutlet UIWebView *abstract_pdf_webview;
@property NSString *abstract_name;
@property NSString *abstract_objid;
@property int from_author;
@property (strong, nonatomic) IBOutlet UIView *abstract_trim_view;
@property (strong, nonatomic) IBOutlet UIView *abstract_card_view;
@property (strong, nonatomic) IBOutlet UIView *pdf_trim_view;
- (IBAction)author_detail_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *author_detail_button;
@property (weak, nonatomic) IBOutlet UITextView *abstract_content_textview;
@property (weak, nonatomic) IBOutlet UIView *abstract_detail_card_view;
@property (weak, nonatomic) IBOutlet UIButton *abstract_open_button;
- (IBAction)abstract_open_button_tap:(UIButton *)sender;

@end

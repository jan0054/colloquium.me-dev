//
//  WordSharingView.m
//  cm_math_one
//
//  Created by csjan on 4/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import "WordSharingView.h"
#import <Parse/Parse.h>
#import "WordSharingCell.h"
#import "WordSharingInputCell.h"
#import "UrlUploadCell.h"
#import "PhotoUploadCell.h"
#import "UIColor+ProjectColors.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

NSMutableArray *sharedResults;
BOOL isReceiveMode;   //yes = receive, no = upload

@interface WordSharingView ()

@end

@implementation WordSharingView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    sharedResults = [[NSMutableArray alloc] init];
    [self.sharingToggle setTintColor:[UIColor primary_color]];
    self.view.backgroundColor = [UIColor light_bg];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;
    self.receiveBackgroundView.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.receiveBackgroundView.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.receiveBackgroundView.layer.shadowOpacity = 0.3f;
    self.receiveBackgroundView.layer.shadowRadius = 2.0f;
    self.segBackgroundView.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.segBackgroundView.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.segBackgroundView.layer.shadowOpacity = 0.3f;
    self.segBackgroundView.layer.shadowRadius = 2.0f;

    self.emptyLabel.hidden = YES;
    isReceiveMode = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.shareActionButton setTitle:NSLocalizedString(@"action_button_search", nil)];
    [self setupLeftMenuButton];

}

- (void) viewDidLayoutSubviews
{
    if ([self.resultsTable respondsToSelector:@selector(layoutMargins)]) {
        self.resultsTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)sharingToggleChanged:(UISegmentedControl *)sender {
    if (self.sharingToggle.selectedSegmentIndex == 0)
    {
        isReceiveMode = YES;
        [self.shareActionButton setTitle:NSLocalizedString(@"action_button_search", nil)];
    }
    else if (self.sharingToggle.selectedSegmentIndex == 1)
    {
        isReceiveMode = NO;
        [self.shareActionButton setTitle:NSLocalizedString(@"action_button_upload", nil)];
    }
    
    [self.resultsTable reloadData];
    self.emptyLabel.hidden = YES;
    
    WordSharingInputCell *cell1 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    WordSharingInputCell *cell2 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    WordSharingInputCell *cell3 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell1.sharingInput.text=@"";
    cell2.sharingInput.text=@"";
    cell3.sharingInput.text=@"";
}

- (IBAction)shareActionButtonTap:(UIBarButtonItem *)sender {
    WordSharingInputCell *cell1 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    WordSharingInputCell *cell2 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    WordSharingInputCell *cell3 = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *str1 = cell1.sharingInput.text;
    NSString *str2 = cell2.sharingInput.text;
    NSString *str3 = cell3.sharingInput.text;
    if (str1 == NULL)
    {
        str1 = @"";
    }
    if (str2 == NULL)
    {
        str2 = @"";
    }
    if (str3 == NULL)
    {
        str3 = @"";
    }
    str1 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    str3 = [str3 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (isReceiveMode)
    {
        if (str1 != NULL && ![str1 isEqualToString:@""])
        {
            [self performSearchWithWord1: str1 word2: str2 word3: str3];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                        message:NSLocalizedString(@"alert_please_fill_one", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                              otherButtonTitles:nil] show];
        }
    }
    else
    {
        UrlUploadCell *cell = [self.resultsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        NSString *urlStr = cell.urlInput.text;
        if (str1 != NULL && ![str1 isEqualToString:@""] && urlStr != NULL && ![urlStr isEqualToString:@""])
        {
            [self performUploadWithWord1:str1 word2:str2 word3:str3 uploadUrl:urlStr];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error", nil)
                                        message:NSLocalizedString(@"alert_please_fill_one", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                              otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isReceiveMode)
    {
        return [sharedResults count] + 3;
    }
    else
    {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WordSharingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wordsharingcell"];
    WordSharingInputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:@"wordsharinginputcell"];
    UrlUploadCell *urlUploadCell = [tableView dequeueReusableCellWithIdentifier:@"urluploadcell"];
    //PhotoUploadCell *photoUploadCell = [tableView dequeueReusableCellWithIdentifier:@"photouploadcell"];
    
    if ([cell respondsToSelector:@selector(layoutMargins)])
    {
        cell.layoutMargins = UIEdgeInsetsZero;
        inputCell.layoutMargins = UIEdgeInsetsZero;
        urlUploadCell.layoutMargins = UIEdgeInsetsZero;
        //photoUploadCell.layoutMargins = UIEdgeInsetsZero;
    }
    
    if (isReceiveMode)
    {
        if (indexPath.row <=2)
        {
            inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0)
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"search_hint_1", nil);
            }
            else if (indexPath.row == 1)
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"search_hint_2", nil);
            }
            else
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"search_hint_3", nil);
            }
            return inputCell;
        }
        else
        {
            //styling
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.shareTypeLabel.textColor = [UIColor secondary_text];
            cell.shareDateLabel.textColor = [UIColor secondary_text];
            cell.contentLabel.textColor = [UIColor primary_text];
            
            //data
            PFObject *sharedItem = [sharedResults objectAtIndex:indexPath.row-3];
            cell.sharedItem = sharedItem;
            NSNumber *typeNum = sharedItem[@"type"];
            int type = [typeNum intValue];
            if (type == 0)
            {
                NSString *urlStr = sharedItem[@"content"];
                cell.contentLabel.text = urlStr;
                cell.shareTypeLabel.text = NSLocalizedString(@"type_url", nil);
            }
            else if (type == 1)
            {
                cell.shareTypeLabel.text = NSLocalizedString(@"type_file", nil);
            }
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormat setDateFormat: @"MMM-d"];
            NSDate *date = sharedItem.createdAt;
            NSString *dateStr = [dateFormat stringFromDate:date];
            cell.shareDateLabel.text = dateStr;
            
            return cell;
        }
    }
    else
    {
        if (indexPath.row <=2)
        {
            inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0)
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"upload_hint_1", nil);
            }
            else if (indexPath.row == 1)
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"upload_hint_2", nil);
            }
            else
            {
                inputCell.sharingInput.placeholder = NSLocalizedString(@"upload_hint_3", nil);
            }
            return inputCell;
        }
        else
        {
            urlUploadCell.selectionStyle = UITableViewCellSelectionStyleNone;
            urlUploadCell.promptLabel.text = NSLocalizedString(@"url_prompt", nil);
            urlUploadCell.urlInput.placeholder = NSLocalizedString(@"url_placeholder", nil);
            return urlUploadCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isReceiveMode)
    {
        if (indexPath.row >=3)
        {
            WordSharingCell *cell = [self.resultsTable cellForRowAtIndexPath:indexPath];
            PFObject *object = cell.sharedItem;
            NSNumber *typeNum = object[@"type"];
            int type = [typeNum intValue];
            if (type == 0)
            {
                NSString *urlStr = object[@"content"];
                NSURL *url = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication] openURL:url];
            }
            else if (type == 1)
            {
                PFFile *sharedFile = object[@"file"];
                NSString *fileUrlStr = sharedFile.url;
                NSURL *fileUrl = [NSURL URLWithString:fileUrlStr];
                [[UIApplication sharedApplication] openURL:fileUrl];
            }
        }
    }
}

#pragma mark - Data

- (void)performSearchWithWord1: (NSString *)word1 word2: (NSString *)word2 word3: (NSString *)word3
{
    PFQuery *query = [PFQuery queryWithClassName:@"Shared"];
    [query whereKey:@"word1" equalTo:word1];
    [query whereKey:@"word2" equalTo:word2];
    [query whereKey:@"word3" equalTo:word3];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu search items", (unsigned long)objects.count);
        if (objects.count > 0)
        {
            self.emptyLabel.hidden = YES;
            [sharedResults removeAllObjects];
            sharedResults = [objects mutableCopy];
        }
        else
        {
            self.emptyLabel.hidden = NO;
            self.emptyLabel.text = NSLocalizedString(@"empty_search", nil);
        }
        [self.resultsTable reloadData];
    }];
}

- (void)performUploadWithWord1: (NSString *)word1 word2: (NSString *)word2 word3: (NSString *)word3 uploadUrl: (NSString *)uploadUrl
{
    PFObject *object = [PFObject objectWithClassName:@"Shared"];
    object[@"type"] = @0;
    object[@"word1"] = word1;
    object[@"word2"] = word2;
    object[@"word3"] = word3;
    object[@"content"] = uploadUrl;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_success", nil)
                                        message:NSLocalizedString(@"alert_upload_success", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                              otherButtonTitles:nil] show];
        }
        else
        {
            //error processing
        }
    }];
}

@end

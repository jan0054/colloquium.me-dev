//
//  StreamListView.m
//  cm_math_one
//
//  Created by csjan on 3/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import "StreamListView.h"
#import "StreamPlayerView.h"
#import "UIColor+ProjectColors.h"
#import "StreamLinkCell.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *selectedId;
NSMutableArray *videoItems;

@interface StreamListView ()

@end

@implementation StreamListView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    //init
    videoItems = [[NSMutableArray alloc] init];
    [self setupLeftMenuButton];
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.streamTable addSubview:pullrefresh];
    self.empty_label.textColor = [UIColor dark_accent];
    self.empty_label.text = NSLocalizedString(@"stream_empty_label", nil);
    
    //styling
    [self.openChannelButton setTitle:NSLocalizedString(@"open_channel_button", nil) forState:UIControlStateNormal];
    [self.openChannelButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    self.streamTable.backgroundColor = [UIColor light_bg];
    self.view.backgroundColor = [UIColor light_bg];
    self.topBarBackground.backgroundColor = [UIColor light_bg];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self callYoutubeApi];
}

- (void)refreshctrl:(id)sender
{
    [self callYoutubeApi];
    //[(UIRefreshControl *)sender endRefreshing];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)openChannelButtonTap:(UIButton *)sender {
    NSString *channelName = @"UCqiUSoddzJL3MZqr_Wr_96w";
    
    NSURL *linkToAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"youtube://www.youtube.com/channel/%@",channelName]];
    NSURL *linkToWebURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/channel/%@",channelName]];
    
    if ([[UIApplication sharedApplication] canOpenURL:linkToAppURL]) {
        // Can open the youtube app URL so launch the youTube app with this URL
        [[UIApplication sharedApplication] openURL:linkToAppURL];
    }
    else{
        // Can't open the youtube app URL so launch Safari instead
        [[UIApplication sharedApplication] openURL:linkToWebURL];
    }
}

#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [videoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreamLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streamlinkcell"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundCardView.backgroundColor = [UIColor whiteColor];
    cell.backgroundCardView.layer.shouldRasterize = YES;
    cell.backgroundCardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundCardView.layer.shadowColor = [UIColor shadow_color].CGColor;
    cell.backgroundCardView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    cell.backgroundCardView.layer.shadowOpacity = 0.3f;
    cell.backgroundCardView.layer.shadowRadius = 1.0f;
    cell.viewLabel.textColor = [UIColor dark_accent];
    cell.viewLabel.text = NSLocalizedString(@"view_stream_button", nil);
    cell.descriptionLabel.textColor = [UIColor secondary_text];
    cell.statusLabel.textColor = [UIColor redColor];
    
    //data
    NSDictionary *videoDictionary = [videoItems objectAtIndex:indexPath.row];
    NSDictionary *vidDictionary = [videoDictionary objectForKey:@"id"];
    NSString *vid = [vidDictionary objectForKey:@"videoId"];
    cell.videoId = vid;
    NSDictionary *snippetDictionary = [videoDictionary objectForKey:@"snippet"];
    NSDictionary *thumbnailsDictionary = [snippetDictionary objectForKey:@"thumbnails"];
    NSDictionary *smallThumbnailDictionary = [thumbnailsDictionary objectForKey:@"default"];
    NSString *imageUrl = [smallThumbnailDictionary objectForKey:@"url"];
    NSString *videoTitle = [snippetDictionary objectForKey:@"title"];
    NSString *videoDecription = [snippetDictionary objectForKey:@"description"];
    NSString *videoStatus = [snippetDictionary objectForKey:@"liveBroadcastContent"];
    if ([videoStatus isEqualToString:@"live"])
    {
        cell.statusLabel.text = NSLocalizedString(@"stream_status_live", nil);
    }
    else
    {
        cell.statusLabel.text = NSLocalizedString(@"stream_status_none", nil);
    }
    cell.titleLabel.text = videoTitle;
    cell.descriptionLabel.text = videoDecription;
    [cell.videoThumbnail sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:[UIImage imageNamed:@"stream_default"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreamLinkCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedId = cell.videoId;
    [self performSegueWithIdentifier:@"stream_player_segue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"stream_player_segue"])
    {
        StreamPlayerView *controller = (StreamPlayerView *)[segue destinationViewController];
        controller.videoId = selectedId;
    }
}

#pragma mark - Data

- (void)callYoutubeApi
{
    // Set up api query URL
    NSString *youtubeApi = @"https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCqiUSoddzJL3MZqr_Wr_96w&maxResults=50&order=date&type=video&key=AIzaSyCyA3EXv5cl3bMfnFvwhg5SNRT5cjExb0c";
    youtubeApi = [youtubeApi stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [[NSURL alloc] initWithString:youtubeApi];
    
    // Create request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Send the request
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        // Callback, parse the data and check for errors
        if (data && !connectionError) {
            NSError *jsonError;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (!jsonError)
            {
                NSLog(@"Response from YouTube: %@", jsonResult);
                [videoItems removeAllObjects];
                videoItems = [jsonResult objectForKey:@"items"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.streamTable reloadData];
                    [self.pullrefresh endRefreshing];
                    if (videoItems.count > 0)
                    {
                        self.empty_label.hidden = YES;
                    }
                    else
                    {
                        self.empty_label.hidden = NO;
                    }

                });
            }
            else
            {
                NSLog(@"Response error: %@", jsonError);
            }
        }
    }];
}
@end

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

NSString *selectedId;


@interface StreamListView ()

@end

@implementation StreamListView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    [self.openChannelButton setTitle:NSLocalizedString(@"open_channel_button", nil) forState:UIControlStateNormal];
    [self.openChannelButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self callYoutubeApi];
    
}

- (IBAction)openChannelButtonTap:(UIButton *)sender {
    NSString *channelName = @"UCqiUSoddzJL3MZqr_Wr_96w";
    
    NSURL *linkToAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"youtube://www.youtube.com/channel/%@",channelName]];
    NSURL *linkToWebURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/channel/%@",channelName]];
    
    if ([[UIApplication sharedApplication] canOpenURL:linkToAppURL]) {
        // Can open the youtube app URL so launch the youTube app with this URL
        NSLog(@"native open YT");
        [[UIApplication sharedApplication] openURL:linkToAppURL];
    }
    else{
        // Can't open the youtube app URL so launch Safari instead
        NSLog(@"web open YT");
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
    
    return 0;
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
    /*
    cell.backgroundCardView.backgroundColor = [UIColor whiteColor];
    cell.backgroundCardView.layer.shouldRasterize = YES;
    cell.backgroundCardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundCardView.layer.shadowColor = [UIColor shadow_color].CGColor;
    cell.backgroundCardView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    cell.backgroundCardView.layer.shadowOpacity = 0.3f;
    cell.backgroundCardView.layer.shadowRadius = 1.0f;
     */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: set selectedId
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
    NSLog(@"Started youtube api call");
    // Set up your URL
    NSString *youtubeApi = @"https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=UC4xO15BR3bk0ZO5Jr-X7zeA&key=AIzaSyCyA3EXv5cl3bMfnFvwhg5SNRT5cjExb0c";
    youtubeApi = [youtubeApi stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [[NSURL alloc] initWithString:youtubeApi];
    
    // Create your request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Send the request asynchronously
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"Async request done, response: %@", response);
        NSLog(@"Async request done, data: %@", data);
        NSLog(@"Async request done, error: %@", connectionError);
        // Callback, parse the data and check for errors
        if (data && !connectionError) {
            NSError *jsonError;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (!jsonError)
            {
                NSLog(@"Response from YouTube: %@", jsonResult);
            }
            else
            {
                NSLog(@"Response error: %@", jsonError);
            }
        }
    }];
}
@end

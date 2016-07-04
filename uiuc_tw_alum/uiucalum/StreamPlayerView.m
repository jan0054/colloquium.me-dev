//
//  StreamPlayerView.m
//  cm_math_one
//
//  Created by csjan on 3/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import "StreamPlayerView.h"

@interface StreamPlayerView ()

@end

@implementation StreamPlayerView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playerView loadWithVideoId:self.videoId];
}


@end

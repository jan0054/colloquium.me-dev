//
//  StreamPlayerView.h
//  cm_math_one
//
//  Created by csjan on 3/15/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface StreamPlayerView : UIViewController

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@property NSString *videoId;

@end

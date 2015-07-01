//
//  InterfaceController.h
//  KKNN24 WatchKit Extension
//
//  Created by csjan on 7/1/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *eventNameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *eventLocationLabel;
- (IBAction)nextEventTap;

@end

//
//  InterfaceController.m
//  KKNN24 WatchKit Extension
//
//  Created by csjan on 7/1/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self requestEventFromPhone];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)nextEventTap {

}

- (void) requestEventFromPhone
{
    [WKInterfaceController openParentApplication:@{@"request":@"event"} reply:^(NSDictionary *replyInfo, NSError *error) {
        if (error == nil) {
            //got event from iphone app
            NSDictionary *event = replyInfo[@"event"];
            [self.eventNameLabel setText:event[@"name"]];
            [self.eventLocationLabel setText:event[@"location"]];
            [self.eventTimeLabel setText:event[@"time"]];
        }
    }];
    
}

@end
//
//  UserPreferenceView.m
//  cm_math_one
//
//  Created by csjan on 6/24/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UserPreferenceView.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"

@implementation UserPreferenceView

#pragma mark - TableView

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end

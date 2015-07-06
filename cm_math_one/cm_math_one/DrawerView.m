//
//  DrawerView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "DrawerView.h"
#import "UIViewController+MMDrawerController.h"
#import <Parse/Parse.h>
#import "DrawerCell.h"

@interface DrawerView ()

@end

int currentIndex;

@implementation DrawerView

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = 0;
    [self.tableView setContentInset:UIEdgeInsetsMake(35.0, 0.0, 0.0, 0.0)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drawercell"];
    switch (indexPath.row) {
        case 0:
            cell.drawerTitle.text = @"Edit Events";
            break;
        case 1:
            cell.drawerTitle.text = @"Event";
            break;
        case 2:
            cell.drawerTitle.text = @"Chat";
            break;
        case 3:
            cell.drawerTitle.text = @"Career";
            break;
        case 4:
            cell.drawerTitle.text = @"Settings";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentIndex == indexPath.row)
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        return;
    }
    
    UIViewController *centerViewController;
    switch (indexPath.row) {
        case 0:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
            break;
        case 1:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
            break;
        case 2:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"conversation_nc"];
            break;
        case 3:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"career_nc"];
            break;
        case 4:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings_nc"];
            break;
        default:
            break;
    }
    
    if (centerViewController) {
        currentIndex = indexPath.row;
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

@end

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
#import "UIColor+ProjectColors.h"

@interface DrawerView ()

@end

NSIndexPath *currentIndex;

@implementation DrawerView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    [self.tableView setContentInset:UIEdgeInsetsMake(35.0, 0.0, 0.0, 0.0)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor dark_primary];
    self.tableView.backgroundColor = [UIColor dark_primary];
    
    //set default "currentIndex" depending on whether there are already saved events
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    if (eventNames.count >=1)  //already exist previously selected events
    {
        currentIndex = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    else  //no existing selected events
    {
        currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

- (void)viewDidLayoutSubviews {
    /*
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
     */
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];

    if (section == 0)
    {
        return 2 + [eventNames count];
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drawercell"];
    
    //styling
    /*
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
     */
    //cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.bounds)/2.0, 0, CGRectGetWidth(cell.bounds)/2.0);
    cell.lowerSeparator.hidden = YES;
    cell.upperSeparator.hidden = YES;
    cell.drawerBackground.backgroundColor = [UIColor clearColor];
    [cell.drawerImage setTintColor:[UIColor accent_color]];
    UIImage *img = [[UIImage alloc] init];
    cell.drawerTitle.backgroundColor = [UIColor clearColor];
    cell.drawerTitle.textColor = [UIColor light_txt];
    cell.contentView.backgroundColor = [UIColor dark_primary];
    
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    NSString *name = @"";
    if (indexPath.section == 0 && indexPath.row != 0 && indexPath.row != 1)  //if dynamic event row, set name
    {
        name = [eventNames objectAtIndex:indexPath.row-2];
    }
    
    if (indexPath.section == 1)   //bottom 3 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_chat", nil);
                img = [UIImage imageNamed:@"chat48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                cell.upperSeparator.hidden = NO;
                cell.upperSeparator.backgroundColor = [UIColor divider_color];
                break;
            case 1:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_career", nil);
                img = [UIImage imageNamed:@"career48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            case 2:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_settings", nil);
                img = [UIImage imageNamed:@"setting48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            default:
                break;
        }
        return cell;
    }
    else     //dynamic event rows + first "edit event" row + second "home" row
    {
        switch (indexPath.row) {
            case 0:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_edit", nil);
                img = [UIImage imageNamed:@"addevent48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            case 1:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_home", nil);
                img = [UIImage imageNamed:@"eventhome48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                cell.lowerSeparator.hidden = NO;
                cell.lowerSeparator.backgroundColor = [UIColor divider_color];
                break;
                
            default:
                cell.drawerTitle.text = name;
                img = [UIImage imageNamed:@"event48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
                
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DRAWER: selected indexpath %li - %li", (long)indexPath.section, (long)indexPath.row);
    
    /*
    if (currentIndex.row == indexPath.row && currentIndex.section == indexPath.section) //close drawer if we're already on whatever page we tapped
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        NSLog(@"Close Drawer for Same Page");
        return;
    }
     */
    
    UIViewController *centerViewController;
    
    if (indexPath.section == 1)   //bottom 3 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"conversation_nc"];
                break;
            case 1:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"career_nc"];
                break;
            case 2:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings_nc"];
                break;
            default:
                break;
        }
    }
    else     //dynamic event rows + first edit event row + second home row
    {
        switch (indexPath.row) {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
                NSLog(@"Open Event Chooser");
                break;
            case 1:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
                NSLog(@"Open Home");
                break;
            default:
                [self setCurrentEventIdForRow:indexPath.row-2];
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
                NSLog(@"Open Main Tab Controller");
                break;
        }
    }
    
    if (centerViewController) {
        currentIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void) setCurrentEventIdForRow: (int)row
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    NSString *name = [eventNames objectAtIndex:row];
    NSDictionary *eventDictionary = [defaults objectForKey:@"eventDictionary"];
    NSString *eid = [eventDictionary objectForKey:name];
    [defaults setObject:eid forKey:@"currentEventId"];
    [defaults synchronize];
    NSLog(@"Current event id set to: %@", eid);
}

- (void)updateEvents
{
    [self.tableView reloadData];
}

@end

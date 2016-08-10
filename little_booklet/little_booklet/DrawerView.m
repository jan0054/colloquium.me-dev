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
#import "UIViewController+ParseQueries.h"
#import "HomeView.h"

@interface DrawerView ()

@end

NSIndexPath *currentSelectedIndex;
NSMutableArray *favoriteEventsArray;

@implementation DrawerView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    favoriteEventsArray = [[NSMutableArray alloc] init];
    
    //styling
    [self.tableView setContentInset:UIEdgeInsetsMake(35.0, 0.0, 0.0, 0.0)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor drawer_background];
    self.tableView.backgroundColor = [UIColor drawer_background];
    
    //init data
    currentSelectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];  //default selection on app open
    [self getEventsFromLocalList:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getEventsFromLocalList:self];
    NSLog(@"Drawer current index:%ld, %ld", (long)currentSelectedIndex.row, (long)currentSelectedIndex.section);
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
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSArray *eventNames = [defaults objectForKey:@"eventNames"];

    if (section == 0)
    {
        return 2 + [favoriteEventsArray count];
    }
    else
    {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drawercell"];
    
    //styling
    cell.lowerSeparator.hidden = YES;
    cell.upperSeparator.hidden = YES;
    cell.drawerBackground.backgroundColor = [UIColor clearColor];
    UIImage *img = [[UIImage alloc] init];
    cell.drawerTitle.backgroundColor = [UIColor clearColor];
    cell.drawerTitle.textColor = [UIColor light_button_txt];
    cell.contentView.backgroundColor = [UIColor drawer_background];
    if (indexPath.row == currentSelectedIndex.row && indexPath.section == currentSelectedIndex.section)   //selected cell background color
    {
        cell.drawerBackground.backgroundColor = [UIColor drawer_selection_background];
    }
    
    //data
    if (indexPath.section == 0 && indexPath.row != 0 && indexPath.row != 1)  //if dynamic event row, set name
    {
        PFObject *eventObj = [favoriteEventsArray objectAtIndex:indexPath.row-2];
        cell.eventObject = eventObj;
        cell.eventId = eventObj.objectId;
        cell.eventName = eventObj[@"name"];
    }
    
    if (indexPath.section == 1)   //bottom 5 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_chat", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"chat48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                cell.upperSeparator.hidden = NO;
                cell.upperSeparator.backgroundColor = [UIColor divider_color];
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
            case 1:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_career", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"career48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
            case 2:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_stream", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"vidcamera48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
            case 3:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_share", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"sharelink48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
            case 4:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_settings", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"setting48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
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
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"addevent48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
            case 1:
                cell.drawerTitle.text = NSLocalizedString(@"drawer_home", nil);
                [cell.drawerImage setTintColor:[UIColor drawer_icon_primary]];
                img = [UIImage imageNamed:@"eventhome48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                cell.lowerSeparator.hidden = NO;
                cell.lowerSeparator.backgroundColor = [UIColor divider_color];
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                break;
                
            default:
                cell.drawerTitle.text = cell.eventName;
                [cell.drawerImage setTintColor:[UIColor drawer_icon_secondary]];
                img = [UIImage imageNamed:@"event48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                [cell.drawerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DRAWER: selected indexpath %li - %li", (long)indexPath.section, (long)indexPath.row);
    DrawerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    /*
    if (currentIndex.row == indexPath.row && currentIndex.section == indexPath.section) //close drawer if we're already on whatever page we tapped
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        NSLog(@"Close Drawer for Same Page");
        return;
    }
     */
    
    UIViewController *centerViewController;
    
    if (indexPath.section == 1)   //bottom 5 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"conversation_nc"];
                break;
            case 1:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"career_nc"];
                break;
            case 2:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"streamlist_nc"];
                break;
            case 3:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"wordshare_nc"];
                break;
            case 4:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings_nc"];
                break;
            default:
                break;
        }
    }
    else     //dynamic event rows + first edit event row + second home row
    {
        switch (indexPath.row)
        {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
                NSLog(@"Open Event Chooser");
                break;
            case 1:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
                NSLog(@"Open Home");
                break;
            default:
                if (cell.eventObject != nil)
                {
                    PFObject *event = cell.eventObject;
                    if (event[@"childrenEvent"]==nil)   //this is not a parent event
                    {
                        [self setCurrentEventForObject:event];
                        centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
                    }
                    else   //this is a parent event
                    {
                        UINavigationController *navCon = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"home_nc"];
                        HomeView *controller = [navCon.viewControllers objectAtIndex:0];
                        controller.isSecondLevelEvent = YES;
                        controller.parentEvent = event;
                        controller.showDrawer = YES;
                        centerViewController = navCon;
                    }
                }
                break;
        }
    }
    
    if (centerViewController)
    {
        currentSelectedIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [self.tableView reloadData];   //reload the tableview here so that the selected row will already be colored when we next open the drawer
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    }
    else
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - Data
/*
- (void)setCurrentEventForName: (NSString *)eventName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *eventDictionary = [defaults objectForKey:@"eventDictionary"];
    NSString *eid = [eventDictionary objectForKey:eventName];
    [defaults setObject:eid forKey:@"currentEventId"];
    [defaults synchronize];
}
*/
- (void)setCurrentEventForObject: (PFObject *)object
{
    NSString *eventId = object.objectId;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:eventId forKey:@"currentEventId"];
    [defaults synchronize];
}

- (void)processData: (NSArray *) results
{
    [favoriteEventsArray removeAllObjects];
    favoriteEventsArray = [results mutableCopy];
    [self.tableView reloadData];
}

- (void)updateEvents
{
    //[self.tableView reloadData];
    [self getEventsFromLocalList:self];
}

@end

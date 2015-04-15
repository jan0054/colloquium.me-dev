//
//  DrawerTableViewController.m
//  Colloquium.me
//
//  Created by csjan on 3/20/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "DrawerTableViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface DrawerTableViewController ()

@end

int currentIndex;

@implementation DrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = 0;

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
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"firstitem_nc"];
            break;
        case 1:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"seconditem_nc"];
            break;
        case 2:
            centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"thirditem_nc"];
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

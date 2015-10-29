//
//  CareerView.m
//  cm_math_one
//
//  Created by csjan on 6/17/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "CareerView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "CareerCell.h"
#import "CareerDetailTableViewController.h"
#import "CareerPostView.h"

NSMutableArray *careerArray;
PFObject *selectedCareer;

@implementation CareerView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    careerArray = [[NSMutableArray alloc] init];
    self.careerTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //data
    [self getCareer:self];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) viewDidLayoutSubviews
{
    if ([self.careerTable respondsToSelector:@selector(layoutMargins)]) {
        self.careerTable.layoutMargins = UIEdgeInsetsZero;
    }
}


- (IBAction)addCareerButtonTap:(UIBarButtonItem *)sender {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_career_title", nil)
                          message:NSLocalizedString(@"alert_career_detail", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"alert_career_contact", nil), nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://support@colloquium.me"]];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [careerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CareerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"careercell"];
    
    //styling
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.moreLabel.textColor = [UIColor dark_accent];
    cell.typeLabel.textColor = [UIColor dark_primary];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PFObject *career = [careerArray objectAtIndex:indexPath.row];
    
    cell.typeLabel.text = [career[@"hiring"] intValue] == 1 ? NSLocalizedString(@"type_hiring", nil) : NSLocalizedString(@"type_seeking", nil);
    cell.institutionLabel.text = career[@"institution"];
    cell.contentLabel.text = career[@"content"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCareer = [careerArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"careerdetailsegue" sender:self];
}

#pragma mark - Data

- (void)processData: (NSArray *) results
{
    [careerArray removeAllObjects];
    careerArray = [results mutableCopy];
    [self.careerTable reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"careerdetailsegue"]) {
        CareerDetailTableViewController *controller = (CareerDetailTableViewController *) segue.destinationViewController;
        controller.currentCareer = selectedCareer;
    }
}

@end

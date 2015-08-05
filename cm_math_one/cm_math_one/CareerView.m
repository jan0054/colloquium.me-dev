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

NSMutableArray *careerArray;

@implementation CareerView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    careerArray = [[NSMutableArray alloc] init];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)addCareerButtonTap:(UIBarButtonItem *)sender {

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
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"careerdetailsegue" sender:self];
}


@end

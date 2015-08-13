//
//  CareerDetailTableViewController.m
//  cm_math_one
//
//  Created by csjan on 8/6/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "CareerDetailTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"

@interface CareerDetailTableViewController ()

@end

@implementation CareerDetailTableViewController
@synthesize currentCareer;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];

    //styling
    [self.contactButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.linkButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    
    //data
    self.institutionLabel.text = [NSString stringWithFormat:@"Institute: %@", currentCareer[@"institution"]];
    self.contentLabel.text = [NSString stringWithFormat:@"Job description: %@", currentCareer[@"content"]];
    self.contactLabel.text = [NSString stringWithFormat:@"Contact: %@", currentCareer[@"contact_name"]];


    self.tableView.estimatedRowHeight = 250.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (IBAction)contactButtonTap:(UIButton *)sender {
    NSString *mailstr = [NSString stringWithFormat:@"mailto://%@", currentCareer[@"contact_email"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
}

- (IBAction)linkButtonTap:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentCareer[@"link"]]];
}

- (void) viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end

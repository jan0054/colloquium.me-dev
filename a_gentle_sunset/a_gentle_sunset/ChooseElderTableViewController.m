//
//  ChooseElderTableViewController.m
//  a_gentle_sunset
//
//  Created by csjan on 4/28/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChooseElderTableViewController.h"
#import "ElderCell.h"

@interface ChooseElderTableViewController ()

@end

NSMutableArray *elder_array;
NSMutableArray *selected_elders;

@implementation ChooseElderTableViewController
@synthesize elder_delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    elder_array = [[NSMutableArray alloc] init];
    selected_elders = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    [self get_elder_list];
    
}

- (void) get_elder_list
{
    PFQuery *elder_query = [PFQuery queryWithClassName:@"elder"];
    [elder_query orderByDescending:@"name"];
    [elder_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [elder_array removeAllObjects];
        elder_array = [objects mutableCopy];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [elder_array count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ElderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eldercell" forIndexPath:indexPath];
    PFObject *elder = [elder_array objectAtIndex:indexPath.row];
    cell.elder_image.image = [UIImage imageNamed:@"placeholder_image"];
    cell.elder_image.file = elder[@"photo"];
    [cell.elder_image loadInBackground];
    cell.elder_name.text = elder[@"name"];
    NSDate *dob = elder[@"birthday"];
    cell.elder_age.text = [NSString stringWithFormat:@"%ld",(long)[self age_from_birth:dob]];
    
    return cell;
}


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

- (NSInteger)age_from_birth: (NSDate *) dob {
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:dob
                                       toDate:today
                                       options:0];
    return ageComponents.year;
}

- (void) get_selected_elders
{
    [selected_elders removeAllObjects];
    NSArray *selected_paths = (NSArray *)[self.tableView indexPathsForSelectedRows];
    for ( NSIndexPath *ip in selected_paths)
    {
        int place = ip.row;
        PFObject *elder = [elder_array objectAtIndex:place];
        [selected_elders addObject:elder];
    }
    [elder_delegate getElderList:selected_elders];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)select_elder_done_tap:(UIBarButtonItem *)sender {
    
    [self get_selected_elders];
    
}

@end

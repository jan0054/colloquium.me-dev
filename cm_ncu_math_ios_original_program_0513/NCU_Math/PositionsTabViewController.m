//
//  PositionsTabViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "PositionsTabViewController.h"
#import "PositionDetailViewController.h"
#import "UIColor+ProjectColors.h"
#import "PositionPostViewController.h"

@interface PositionsTabViewController ()

@end

NSString *tapped_objid;
int unread_total;

@implementation PositionsTabViewController
@synthesize career_array;
@synthesize pullrefresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.career_array = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor background];
    self.careertable.backgroundColor = [UIColor clearColor];
    
    self.empty_career_label.hidden = YES;
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.careertable addSubview:pullrefresh];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.careertable.tableFooterView = [[UIView alloc] init];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.post_career_button.enabled = NO;
    if ([PFUser currentUser])
    {
        //ok, there's someone logged in, check if it's a registered attendee
        NSNumber *isperson = [PFUser currentUser][@"isperson"];
        int isperson_int = [isperson intValue];
        if (isperson_int == 1)
        {
            //ok, its a registered attendee, we can let him post new job
            self.post_career_button.enabled = YES;
        }
    }
    [self get_career_data];
}

- (void) viewDidLayoutSubviews
{
    if ([self.careertable respondsToSelector:@selector(layoutMargins)]) {
        self.careertable.layoutMargins = UIEdgeInsetsZero;
    }
}

//called when pulling downward on the tableview
- (void)refreshctrl:(id)sender
{
    //refresh code here
    [self get_career_data];
    
    // End Refreshing
    [(UIRefreshControl *)sender endRefreshing];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.career_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CareerCellTableViewCell *careercell = [tableView dequeueReusableCellWithIdentifier:@"careercell"];
    
    //data
    PFObject *career = [self.career_array objectAtIndex:indexPath.row];
    NSString *position = career[@"position"];
    NSString *institution = career[@"institution"];
    careercell.career_position_label.text = position;
    careercell.career_institution_label.text = institution;
    PFObject *author = career[@"posted_by"];
    NSString *name = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    careercell.career_author_label.text = [NSString stringWithFormat:@"Posted by: %@", name];
    NSNumber *type = career[@"offer_seek"]; // 0=offer, 1=seek
    int type_int = [type intValue];
    if (type_int == 1)
    {
        //is seek
        careercell.career_type_label.text = @"Seeking position:";
    }
    else
    {
        //is offer
        careercell.career_type_label.text = @"Position available:";
    }
    
    //styling
    careercell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([careercell respondsToSelector:@selector(layoutMargins)]) {
        careercell.layoutMargins = UIEdgeInsetsZero;
    }
    careercell.career_card_view.backgroundColor = [UIColor primary_color];
    careercell.career_card_view.alpha = 0.8;
    careercell.career_trim_view.backgroundColor = [UIColor light_primary];
    careercell.career_card_view.layer.cornerRadius = 2;
    [careercell.career_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [careercell.career_detail_button setTitleColor:[UIColor accent_color] forState:UIControlStateHighlighted];
    careercell.career_type_label.textColor = [UIColor light_primary];
    //add shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:careercell.career_card_view.bounds];
    careercell.career_card_view.layer.masksToBounds = NO;
    careercell.career_card_view.layer.shadowColor = [UIColor blackColor].CGColor;
    careercell.career_card_view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    careercell.career_card_view.layer.shadowOpacity = 0.3f;
    careercell.career_card_view.layer.shadowPath = shadowPath.CGPath;
    
    return careercell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"positiontodetailsegue" sender:self];
}

- (void) get_career_data
{
    PFQuery *careerquery = [PFQuery queryWithClassName:@"career"];
    [careerquery includeKey:@"posted_by"];
    [careerquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"career query success");
        if ([objects count] == 0)
        {
            //empty list
            self.empty_career_label.hidden = NO;
        }
        else
        {
            self.empty_career_label.hidden = YES;
        }
        [self.career_array removeAllObjects];
        for (PFObject *career_obj in objects)
        {
            [self.career_array addObject:career_obj];
        }
        [self.careertable reloadData];
    }];
}

- (IBAction)career_detail_tap:(UIButton *)sender {
    CareerCellTableViewCell *cell = (CareerCellTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *tapped_path = [self.careertable indexPathForCell:cell];
    NSLog(@"career_detail_tap: %ld", (long)tapped_path.row);
    PFObject *tapped_career = [self.career_array objectAtIndex:tapped_path.row];
    tapped_objid = tapped_career.objectId;
    [self performSegueWithIdentifier:@"positiontodetailsegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PositionDetailViewController *destination = [segue destinationViewController];
    destination.career_objid = tapped_objid;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Career" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [backButton setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] , NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
    
}



- (IBAction)post_career_button_tap:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"New post" message:@"Choose post type" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Position Available", @"Seeking Position", nil];
    [alert show];}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        //offer position
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PositionPostViewController *controller = (PositionPostViewController *)[storyboard instantiateViewControllerWithIdentifier:@"postcareerview"];
        controller.career_post_type = 0;
        [self presentViewController:controller animated:YES completion:nil];

    }
    else if (buttonIndex == 2)
    {
        //seek position
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PositionPostViewController *controller = (PositionPostViewController *)[storyboard instantiateViewControllerWithIdentifier:@"postcareerview"];
        controller.career_post_type = 1;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end

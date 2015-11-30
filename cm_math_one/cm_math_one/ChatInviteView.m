//
//  ChatInviteView.m
//  cm_math_one
//
//  Created by csjan on 8/10/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ChatInviteView.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ChatInviteCell.h"

NSMutableArray *inviteArray;
NSMutableArray *selectedArray;
NSMutableArray *holderArray;
NSMutableDictionary *inviteeDictionary;

@implementation ChatInviteView

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    inviteArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    holderArray = [[NSMutableArray alloc] init];
    inviteeDictionary = [[NSMutableDictionary alloc] init];
    self.chatInviteTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.searchField.delegate = self;
    self.inviteDoneButton.enabled = NO;
    
    //styling
    UIImage *img = [UIImage imageNamed:@"search48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setTintColor:[UIColor lightGrayColor]];
    [self.searchButton setImage:img forState:UIControlStateNormal];
    self.searchBackgroundView.backgroundColor = [UIColor whiteColor];
    
    [self getInviteeList:self withoutUsers:@[[PFUser currentUser]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [holderArray removeAllObjects];
}

- (void) viewDidLayoutSubviews
{
    if ([self.chatInviteTable respondsToSelector:@selector(layoutMargins)]) {
        self.chatInviteTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)inviteDoneButtonTap:(UIBarButtonItem *)sender {
    /*
    [selectedArray removeAllObjects];
    NSArray *selectedPaths =  self.chatInviteTable.indexPathsForSelectedRows;
    for ( NSIndexPath *ip in selectedPaths)
    {
        int place = ip.row;
        PFUser *user = [inviteArray objectAtIndex:place];
        [selectedArray addObject:user];
    }
    [selectedArray addObject:[PFUser currentUser]];
    [self createConcersation:self withParticipants:selectedArray];
     */
    [holderArray addObject:[PFUser currentUser]];
    [self createConcersation:self withParticipants:holderArray];
    
}

- (IBAction)searchButtonTap:(UIButton *)sender {
    if (self.searchField.text.length >0)
    {
        NSString *search_str = self.searchField.text.lowercaseString;
        
        NSArray *separateBySpace = [search_str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *processedWords = [[NSMutableArray alloc] init];
        for (NSString *componentString in separateBySpace)
        {
            CFStringRef compstr = (__bridge CFStringRef)(componentString);
            NSString *lang = CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage(compstr, CFRangeMake(0, componentString.length)));
            if ([lang isEqualToString:@"zh-Hant"])
            {
                //中文
                for (int i=1; i<=componentString.length; i++)
                {
                    NSString *chcomp = [componentString substringWithRange:NSMakeRange(i-1, 1)];
                    [processedWords addObject:chcomp];
                }
            }
            else
            {
                //not中文
                [processedWords addObject:componentString];
            }
        }
        
        [self getInviteeList:self withoutUsers:@[[PFUser currentUser]] withSearch:processedWords];
        NSLog(@"PROCESSEDWORDS:%lu, %@", processedWords.count, processedWords);
    }
    [self.searchField resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.searchField) [self resetSearch];
    return YES;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return inviteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatinvitecell"];
    
    //styling
    //cell.nameLabel.textColor = [UIColor dark_txt];
    cell.institutionLabel.textColor = [UIColor dark_primary];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.inviteLabel.textColor = [UIColor dark_accent];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //data
    PFObject *user = [inviteArray objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
    NSString *institution = user[@"institution"];
    
    cell.nameLabel.text = name;
    cell.institutionLabel.text = institution;
    
    //determine invite/selection status
    int match = 0;
    for (PFUser *holderUser in holderArray)  //check if this user is in the holder array
    {
        if ([user.objectId isEqualToString:holderUser.objectId])
        {
            match = 1;
        }
    }
    if (match == 0)  //no match
    {
        cell.inviteLabel.text = NSLocalizedString(@"person_invite", nil);
        [cell.selectionImage setTintColor:[UIColor primary_color]];
        UIImage *img = [UIImage imageNamed:@"emptycircle48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionImage.image = img;
        
    }
    else if (match == 1)  //matched
    {
        cell.inviteLabel.text = NSLocalizedString(@"person_invited", nil);
        [cell.selectionImage setTintColor:[UIColor dark_accent]];
        UIImage *img = [UIImage imageNamed:@"check48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionImage.image = img;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapCell:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapCell:indexPath];
}

#pragma mark - Data

- (void)tapCell: (NSIndexPath *)indexPath
{
    NSLog(@"TAP CELL");
    ChatInviteCell *cell = (ChatInviteCell *)[self.chatInviteTable cellForRowAtIndexPath:indexPath];
    PFUser *cellUser = [inviteArray objectAtIndex:indexPath.row];
    int match = 0;
    
    for (PFUser *holderUser in holderArray)  //check if this user was in the holder array
    {
        if ([cellUser.objectId isEqualToString:holderUser.objectId])
        {
            match = 1;
        }
    }
    if (match == 0)  //no match, select the user
    {
        cell.inviteLabel.text = NSLocalizedString(@"person_invited", nil);
        [holderArray addObject:cellUser];
        [cell.selectionImage setTintColor:[UIColor dark_accent]];
        UIImage *img = [UIImage imageNamed:@"check48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionImage.image = img;
        NSLog(@"TAP CELL SELECTING");
    }
    else if (match == 1)  //matched, deselect the user
    {
        cell.inviteLabel.text = NSLocalizedString(@"person_invite", nil);
        NSMutableArray *toBeDeleted = [[NSMutableArray alloc] init];
        for (PFUser *hUser in holderArray)
        {
            if ([hUser.objectId isEqualToString:cellUser.objectId])
            {
                [toBeDeleted addObject:hUser];
            }
        }
        [holderArray removeObjectsInArray:toBeDeleted];
        [cell.selectionImage setTintColor:[UIColor primary_color]];
        UIImage *img = [UIImage imageNamed:@"emptycircle48"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectionImage.image = img;
        NSLog(@"TAP CELL DESELECTING");
    }
    NSLog(@"HOLDER: %lu", (unsigned long)holderArray.count);
    if (holderArray.count>0)
    {
        self.inviteDoneButton.enabled = YES;
    }
    else
    {
        self.inviteDoneButton.enabled = NO;
    }
}

- (void)processInviteeData:(NSArray *)results  //callback for total chat-enabled user query, minus current participants
{
    [inviteArray removeAllObjects];
    inviteArray = [results mutableCopy];
    [self.chatInviteTable reloadData];
}

- (void)createConvSuccess  //callback for done button tap
{
    UINavigationController *navCon = self.navigationController;
    [navCon popViewControllerAnimated:YES];
}

- (void)resetSearch
{
    NSLog(@"Search reset called");
    [self getInviteeList:self withoutUsers:@[[PFUser currentUser]]];
}


@end

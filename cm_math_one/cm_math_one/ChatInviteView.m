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

@implementation ChatInviteView

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    inviteArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    self.chatInviteTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.searchField.delegate = self;
    
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
}

- (void) viewDidLayoutSubviews
{
    if ([self.chatInviteTable respondsToSelector:@selector(layoutMargins)]) {
        self.chatInviteTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (IBAction)inviteDoneButtonTap:(UIBarButtonItem *)sender {
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
    
    //data
    PFObject *user = [inviteArray objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
    NSString *institution = user[@"institution"];
    
    cell.nameLabel.text = name;
    cell.institutionLabel.text = institution;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = (ChatInviteCell *)[self.chatInviteTable cellForRowAtIndexPath:indexPath];
    cell.inviteLabel.text = @"Selected";
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatInviteCell *cell = (ChatInviteCell *)[self.chatInviteTable cellForRowAtIndexPath:indexPath];
    cell.inviteLabel.text = @"Invite";
}

#pragma mark - Data



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

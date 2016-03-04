//
//  ProgramView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "ProgramView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "ProgramCell.h"
#import "ProgramDetailView.h"

#import "DropDownMenuCell.h"

NSMutableArray *programArray;
NSMutableArray *sectionedProgramArray;
PFObject *selectedProgram;
NSMutableArray *sessionArray;
PFObject *currentFilter;
PFObject *selectedEvent;
NSMutableArray *dayArray;
NSMutableArray *headerTitleArray;

@implementation ProgramView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    programArray = [[NSMutableArray alloc] init];
    sessionArray = [[NSMutableArray alloc] init];
    sectionedProgramArray = [[NSMutableArray alloc] init];
    dayArray = [[NSMutableArray alloc] init];
    headerTitleArray = [[NSMutableArray alloc] init];
    self.menuTitles = [[NSMutableArray alloc] init];
    self.programTable.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.programTable.estimatedRowHeight = 220.0;
    self.programTable.rowHeight = UITableViewAutomaticDimension;
    self.filterButton.title = NSLocalizedString(@"filter_button", nil);
    self.searchInput.delegate = self;
    self.filterButton.enabled = NO;   //we turn it back on when the session list is available;
    
    //styling
    UIImage *img = [UIImage imageNamed:@"search48"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.searchButton setTintColor:[UIColor lightGrayColor]];
    [self.searchButton setImage:img forState:UIControlStateNormal];
    self.searchBackgroundView.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.layer.shadowColor = [UIColor shadow_color].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.3f;
    self.navigationController.navigationBar.layer.shadowRadius = 2.0f;


    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    selectedEvent = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self getProgram:self ofType:0 withOrder:0 forEvent:selectedEvent];
    [self getSessions:self forEvent:selectedEvent];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.programTable addSubview:pullrefresh];
    
    
}

- (void)refreshctrl:(id)sender
{
    if (currentFilter == nil)
    {
        [self getProgram:self ofType:0 withOrder:0 forEvent:selectedEvent];
    }
    else
    {
        [self getFilteredProgram:self ofType:0 withOrder:0 forEvent:selectedEvent forSession:currentFilter];
    }
    
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)viewDidLayoutSubviews
{
    if ([self.programTable respondsToSelector:@selector(layoutMargins)]) {
        self.programTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)searchButtonTap:(UIButton *)sender {
    if (self.searchInput.text.length >0)
    {
        NSString *search_str = self.searchInput.text.lowercaseString;
        
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
        
        [self doSearchWithArray:processedWords];
        NSLog(@"PROCESSEDWORDS:%lu, %@", processedWords.count, processedWords);
    }
    [self.searchInput resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.searchInput) [self resetSearch];
    return YES;
}

- (IBAction)filterButtonTap:(UIBarButtonItem *)sender {
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView.tag = 2;
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.0;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"DropDownMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:@"dropdownmenucell"];
    }
    
    float barH = self.navigationController.navigationBar.frame.size.height;
    float paddingTop = 20.0;
    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(barH + paddingTop, 0, 0, 0) animated:YES];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag==1)
    {
        NSArray* uniqueDays = [dayArray valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", @"integerValue"]];
        return uniqueDays.count;
    }
    else   //dropdown menu table
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        NSMutableArray *oneDayArray = [sectionedProgramArray objectAtIndex:section];
        return oneDayArray.count;
    }
    else   //dropdown menu table
    {
        return self.menuTitles.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        NSString *title = [headerTitleArray objectAtIndex:section];
        return [NSString stringWithFormat:@"  %@", title];
    }
    else   //dropdown menu table
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        return 40;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProgramCell *cell = [tableView dequeueReusableCellWithIdentifier:@"programcell"];
    DropDownMenuCell *menucell = [tableView dequeueReusableCellWithIdentifier:@"dropdownmenucell"];
    
    if (tableView.tag == 1)   //program cell
    {
        //styling
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        cell.timeLabel.backgroundColor = [UIColor clearColor];
        cell.authorLabel.backgroundColor = [UIColor clearColor];
        cell.bottomView.backgroundColor = [UIColor clearColor];
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.moreLabel.textColor = [UIColor dark_accent];
        cell.timeLabel.textColor = [UIColor secondary_text];
        cell.locationLabel.textColor = [UIColor secondary_text];
        
        //data
        NSMutableArray *oneDayArray = [sectionedProgramArray objectAtIndex:indexPath.section];
        PFObject *program = [oneDayArray objectAtIndex:indexPath.row];
        PFObject *author = program[@"author"];
        PFObject *location = program[@"location"];
        NSString *locationName = (location[@"name"]!=NULL) ? location[@"name"] : @"";
        cell.nameLabel.text = program[@"name"];
        cell.contentLabel.text = program[@"content"];
        cell.locationLabel.text = locationName;
        cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", author[@"last_name"], author[@"first_name"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormat setDateFormat: @"MMM-d HH:mm"];
        NSDate *sdate = program[@"start_time"];
        NSString *sstr = [dateFormat stringFromDate:sdate];
        cell.timeLabel.text = sstr;
        
        return cell;
    }
    else   //dropdown menu cell
    {
        menucell.backgroundColor = [UIColor clearColor];
        menucell.menuTitleLabel.textColor = [UIColor primary_text];
        menucell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        if (currentFilter == nil)
        {
            if (indexPath.row == 0)
            {
                menucell.menuTitleLabel.textColor = [UIColor accent_color];
            }
        }
        else
        {
            NSString *currentTitle = currentFilter[@"name"];
            if ([currentTitle isEqualToString:[self.menuTitles objectAtIndex:indexPath.row]])
            {
                menucell.menuTitleLabel.textColor = [UIColor accent_color];
            }
        }
        return menucell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1)
    {
        NSMutableArray *oneDayArray = [sectionedProgramArray objectAtIndex:indexPath.section];
        selectedProgram = [oneDayArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"programdetailsegue" sender:self];
    }
    else
    {
        YALContextMenuTableView *tablemenu = tableView;
        [tablemenu dismisWithIndexPath:indexPath];
    }
}

#pragma mark - Data

- (void)processSessions: (NSArray *) results   //receives a list of all the sessions to use for filtering
{
    [sessionArray removeAllObjects];
    [self.menuTitles removeAllObjects];
    [self.menuTitles addObject:NSLocalizedString(@"menu_all", nil)];
    sessionArray = [results mutableCopy];
    for (PFObject *session in sessionArray)
    {
        NSString *nameStr = session[@"name"];
        [self.menuTitles addObject:nameStr];
    }
    self.filterButton.enabled = YES;
}

- (void)resetSearch
{
    NSLog(@"Search reset called");
    if (currentFilter == nil)
    {
        [self getProgram:self ofType:0 withOrder:0 forEvent:selectedEvent];
    }
    else
    {
        [self getFilteredProgram:self ofType:0 withOrder:0 forEvent:selectedEvent forSession:currentFilter];
    }
}

- (void)doSearchWithArray: (NSArray *)searchArray
{
    currentFilter = nil;
    [self getProgram:self ofType:0 withOrder:0 withSearch:searchArray forEvent:selectedEvent];
}

//main results for the program data
- (void)processData: (NSArray *) results
{
    [programArray removeAllObjects];            //all the result objects
    [dayArray removeAllObjects];                //nsnumber values of day components
    [sectionedProgramArray removeAllObjects];   //array of arrays with result objects, grouped by day
    [headerTitleArray removeAllObjects];        //header titles array
    
    programArray = [results mutableCopy];
    
    for (PFObject *prog in programArray)
    {
        NSInteger dayComp = [self getStartDayfromProgram:prog];
        NSNumber *dayCompNSNum = [NSNumber numberWithInteger:dayComp];
        [dayArray addObject:dayCompNSNum];
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dayArray];
    NSSet *uniqueDaysSet = [orderedSet set];
    NSArray *uniqueDays = [uniqueDaysSet allObjects];
    for (NSNumber *dayNum in uniqueDays)
    {
        NSInteger dayInt = dayNum.integerValue;
        NSMutableArray *arrayForDay = [[NSMutableArray alloc] init];
        NSDate *sampleDate;
        for (PFObject *obj in programArray)
        {
            NSInteger objDayInt = [self getStartDayfromProgram:obj];
            if (dayInt == objDayInt)
            {
                [arrayForDay addObject:obj];
                sampleDate = obj[@"start_time"];
            }
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormat setDateFormat: @"yyyy-MMM-d"];
        NSString *headerTitle = [dateFormat stringFromDate:sampleDate];
        
        [sectionedProgramArray addObject:arrayForDay];
        [headerTitleArray addObject:headerTitle];
    }
    
    [self.programTable reloadData];
}

- (NSInteger)getStartDayfromProgram: (PFObject *)obj
{
    NSDate *startDate = obj[@"start_time"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
    NSInteger day = [components day];
    return day;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"programdetailsegue"]) {
        ProgramDetailView *controller = (ProgramDetailView *) segue.destinationViewController;
        controller.program = selectedProgram;
    }
}

#pragma mark - Dropdown Menu

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    [self.contextMenuTableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.contextMenuTableView updateAlongsideRotation];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //should be called after rotation animation completed
        [self.contextMenuTableView reloadData];
    }];
    [self.contextMenuTableView updateAlongsideRotation];
}

//callback for menu tap
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Menu dismissed with indexpath = %li", (long)indexPath.row);
    if (indexPath.row == 0)
    {
        currentFilter = nil;
        self.navigationItem.title = NSLocalizedString(@"title_all", nil);
        self.searchInput.text = @"";
        [self getProgram:self ofType:0 withOrder:0 forEvent:selectedEvent];
    }
    else
    {
        currentFilter = [sessionArray objectAtIndex: (indexPath.row - 1)];
        self.navigationItem.title = currentFilter[@"name"];
        self.searchInput.text = @"";
        [self getFilteredProgram:self ofType:0 withOrder:0 forEvent:selectedEvent forSession:currentFilter];
    }
}

@end

//
//  iTelevisionDetailViewController.m
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 5/30/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import "iTelevisionDetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Schedule.h"
#import <DDXMLElementAdditions.h>

@interface iTelevisionDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
    MPMoviePlayerController *moviePlayer;
    UIDatePicker *datePickerView;
    UIBarButtonItem *datebarButtonItem;
}
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation iTelevisionDetailViewController
@synthesize teleVisionItem;
@synthesize currentDate;
@synthesize itemsArray;
@synthesize tableView = _tableView;
#pragma mark - UIViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"iTEL";
    if (!moviePlayer) {
        moviePlayer = [[MPMoviePlayerController alloc] init];
        moviePlayer.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 500);
        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:moviePlayer.view];
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 500, self.view.bounds.size.width, self.view.bounds.size.height-500)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
    }
    self.tableView.rowHeight = 55;
    {
        NSMutableArray *tempArray = [NSMutableArray array];
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleBordered target:self action:@selector(prevDay)];
            [tempArray addObject:item];
        }
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [tempArray addObject:item];
        }
        {
            datebarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"today", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(showPicker:)];
            [tempArray addObject:datebarButtonItem];
        }
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [tempArray addObject:item];
        }
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStyleBordered target:self action:@selector(nextDay)];
            [tempArray addObject:item];
        }
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolbar setItems:tempArray];
        self.tableView.tableHeaderView = toolbar;
    }
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.currentDate = [NSDate date];
}

#pragma mark - AFNetWorking

- (void)setTeleVisionItem:(TelevisionItem *)_teleVisionItem {
    teleVisionItem = _teleVisionItem;
    [moviePlayer stop];
    self.currentDate = [NSDate date];
    self.title = teleVisionItem.teleVisionName;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *getURL = [NSString stringWithFormat:@"http://tv.univision.mn/tv/getStreamUrl?version=&os=ios&username=dorjsuren&archive=&live=%@", teleVisionItem.streamURL];
    ATLogURL(@"getURL %@",getURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getURL]];
    [request setTimeoutInterval:10.0f];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSString *responsString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        ATLogResponse(@"responsString %@",responsString);
        moviePlayer.contentURL = [NSURL URLWithString:responsString];
        [moviePlayer play];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        ATLogError(@"error %@",error);
    }];
    [operation start];
}

- (void) setCurrentDate:(NSDate *)_currentDate {
    currentDate = _currentDate;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *stringFromDate = [formatter stringFromDate:currentDate];
    [datebarButtonItem setTitle:stringFromDate];
    NSString *refreshURL = [NSString stringWithFormat:@"http://tv.univision.mn/tv/xmlByChannel?username=dorjsuren&channel=%@&date=%@",teleVisionItem.teleVisionID,stringFromDate];
    ATLogURL(@"%@",refreshURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:refreshURL]];
    [request setTimeoutInterval:10.f];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:nil];
        NSArray *channel = [doc nodesForXPath:@"programme" error:nil];
        if ([channel count] > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            DDXMLElement *chann = [channel objectAtIndex:0];
            NSArray *items = [chann elementsForName:@"item"];
            for (DDXMLElement *xmlElement in items) {
                [tempArray addObject:[[Schedule alloc] initWithDDXMLElement:xmlElement]];
            }
            self.itemsArray = tempArray;
            [self.tableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ATLogError(@"failed %@",error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    [operation start];
}

#pragma mark - UIButton Target

- (void) prevDay {
    self.currentDate = [currentDate dateByAddingTimeInterval:-60*60*24];
}

- (void) showPicker :(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"chooseDate", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"choose", nil) otherButtonTitles:nil];
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, 320, 320)];
    picker.maximumDate = [NSDate date];
    [picker setDate:self.currentDate];
    picker.datePickerMode = UIDatePickerModeDate;
    [actionSheet addSubview:picker];
    [actionSheet showInView:self.view.window];
    datePickerView = picker;
}

- (void) nextDay {
    self.currentDate = [currentDate dateByAddingTimeInterval:60*60*24];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.currentDate = datePickerView.date;
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"SongDetailCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        cell.textLabel.numberOfLines = 2;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    Schedule *item = [self.itemsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",item.startTime,item.endTime];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Schedule *item = self.itemsArray[indexPath.row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[moviePlayer stop];

    NSString *refreshURL = [NSString stringWithFormat:@"http://tv.univision.mn/tv/getStreamUrl?version=&os=ios&username=dorjsuren&archive=%@&live=",item.archiveurl];
    ATLogURL(@"%@",refreshURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:refreshURL]];
    [request setTimeoutInterval:10];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSString *responsString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        ATLogResponse(@"responsString %@",responsString);
        moviePlayer.contentURL = [NSURL URLWithString:responsString];
        [moviePlayer play];
        MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:responsString]];
        [self presentMoviePlayerViewControllerAnimated:controller];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ATLogError(@"%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - UISplitViewController

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc
{
    [barButtonItem setTitle:NSLocalizedString(@"title", nil)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}
@end

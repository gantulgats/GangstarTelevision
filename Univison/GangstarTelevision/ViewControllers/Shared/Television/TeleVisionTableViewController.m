//
//  TeleVisionTableViewController.m
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 3/17/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import "TeleVisionTableViewController.h"
#import <AFNetworking.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "TelevisionItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD.h>
#import "TelevisionDetailTableViewController.h"
@interface TeleVisionTableViewController ()
@property (nonatomic, strong) NSArray *itemsArray;
@end

@implementation TeleVisionTableViewController
@synthesize itemsArray;
@synthesize detailController;
#pragma mark - UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 66;
    self.title = NSLocalizedString(@"title", nil);
    //self.title = NSLocalizedString(@"appName", nil);
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    [self refreshData];

}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.itemsArray count] == 0) {
    }
}
- (void)uploadImage {
    
}
#pragma mark - AFNetWorking

- (void) refreshData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *url = @"http://tv.univision.mn/tv/xml?id=dorjsuren";
    ATLogURL(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:10.f];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //ATLogResponse(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:responseObject options:0 error:nil];
        NSArray *channel = [doc nodesForXPath:@"channel" error:nil];
        if ([channel count] > 0) {
            NSMutableArray *tempArray = [NSMutableArray array];
            DDXMLElement *chann = [channel objectAtIndex:0];
            NSArray *items = [chann elementsForName:@"item"];
            for (DDXMLElement *xmlElement in items)
                [tempArray addObject:[[TelevisionItem alloc] initWithDDXMLElement:xmlElement]];
            self.itemsArray = tempArray;
        }
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshControl endRefreshing];
        if (isIPAD & [itemsArray count] > 0) {
            [self selectedTeleVisionItem:self.itemsArray[0]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ATLogError(@"Error %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshControl endRefreshing];
    }];
    [operation start];
}

#pragma mark - TableView DataSource

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
        cell.detailTextLabel.numberOfLines = 2;
        //ell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (isIPAD) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    TelevisionItem *item = [self.itemsArray objectAtIndex:indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.imageURL] placeholderImage:[UIImage imageNamed:@"icon-60"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.detailTextLabel.text = item.schedule;
    cell.textLabel.text = item.teleVisionName;
    return cell;
}

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    TelevisionItem *item = [self.itemsArray objectAtIndex:indexPath.row];
    TelevisionDetailTableViewController *controller = [[TelevisionDetailTableViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.teleVisonItem = item;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TelevisionItem *item = itemsArray[indexPath.row];
    [self selectedTeleVisionItem:item];
}

- (void) selectedTeleVisionItem :(TelevisionItem *)tItem {
    if (isIPAD) {
        detailController.teleVisionItem = tItem;
    }
    else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *getURL = [NSString stringWithFormat:@"http://tv.univision.mn/tv/getStreamUrl?version=&os=ios&username=dorjsuren&archive=&live=%@", tItem.streamURL];
        ATLogURL(@"getURL %@",getURL);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getURL]];
        [request setTimeoutInterval:10.0f];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSString *responsString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            ATLogResponse(@"responsString %@",responsString);
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:responsString]];
            [self presentMoviePlayerViewControllerAnimated:controller];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            ATLogError(@"error %@",error);
        }];
        [operation start];
    }
}
@end

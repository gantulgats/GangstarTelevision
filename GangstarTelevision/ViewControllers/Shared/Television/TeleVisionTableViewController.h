//
//  TeleVisionTableViewController.h
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 3/17/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iTelevisionDetailViewController.h"
@interface TeleVisionTableViewController : UITableViewController
@property (nonatomic, strong) iTelevisionDetailViewController *detailController;
@end

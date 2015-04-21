//
//  iTelevisionDetailViewController.h
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 5/30/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TelevisionItem.h"
@interface iTelevisionDetailViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) TelevisionItem *teleVisionItem;
@end

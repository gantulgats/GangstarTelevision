//
//  AppDelegate.m
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 3/17/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TeleVisionTableViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <ATLog.h>
#import "iTelevisionDetailViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    ATLog(@"Normal %@",@" Message");
    ATLogError(@"Error  %@",@"Error Message");
    ATLogWarning(@"Warning %@",@"Нойл орчоод утаас татаад гэрлээ унтраа");
    ATLogURL(@"SORAKO - %@", @"http://sorako.mn/");
    ATLogResponse(@"Json Responce %@",@"{\"xCode\":5.1.1}");
    ATLog(@"Normal %@",@" Message");

    [Crashlytics startWithAPIKey:@"997f24978fc6a4c7535352991bad07eb263200cf"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ATLog(@"%@",[[UIScreen mainScreen] bounds]);
    if (isIPAD) {
        UISplitViewController *rootController = [[UISplitViewController alloc] initWithNibName:nil bundle:nil];
        rootController.presentsWithGesture = YES;
        TeleVisionTableViewController *masterController = [[TeleVisionTableViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *masterNavController = [[UINavigationController alloc] initWithRootViewController:masterController];
        iTelevisionDetailViewController *detailController = [[iTelevisionDetailViewController alloc] initWithNibName:nil bundle:nil];
        masterController.detailController = detailController;
        rootController.delegate = detailController;
        UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:detailController];
        detailController.navigationController.navigationBar.translucent = NO;
        rootController.viewControllers = @[masterNavController,detailNavController];
        self.window.rootViewController = rootController;
    }
    else {
        TeleVisionTableViewController *controller = [[TeleVisionTableViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.window.rootViewController = navController;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

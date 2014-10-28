//
//  Schedule.m
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 3/17/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import "Schedule.h"
#import <DDXMLElementAdditions.h>

@implementation Schedule
@synthesize startTime;
@synthesize endTime;
@synthesize title;
@synthesize archiveurl;
- (id)initWithDDXMLElement:(DDXMLElement *)element {
    self = [super init];
    if (self) {
        self.startTime = [[[[element elementForName:@"starttime"] stringValue] substringFromIndex:11] substringToIndex:5];
        self.endTime = [[[[element elementForName:@"endtime"] stringValue] substringFromIndex:11] substringToIndex:5];
        self.title = [[element elementForName:@"title"] stringValue];
        self.archiveurl = [[element elementForName:@"archiveurl"] stringValue];
    }
    return self;
}

@end

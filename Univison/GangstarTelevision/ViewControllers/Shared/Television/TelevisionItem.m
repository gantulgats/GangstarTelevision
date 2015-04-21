//
//  TelevisionItem.m
//  TestUnivison
//
//  Created by Gantulga Tsendsuren on 10/24/13.
//  Copyright (c) 2013 SpoMobile. All rights reserved.
//

#import "TelevisionItem.h"
#import <DDXMLElementAdditions.h>

@implementation TelevisionItem
@synthesize teleVisionName;
@synthesize teleVisionID;
@synthesize schedule;
@synthesize imageURL;
@synthesize streamURL;
- (id)initWithDDXMLElement:(DDXMLElement *)element {
    self = [super init];
    if (self) {
        self.teleVisionName = [[element elementForName:@"title"] stringValue];
        self.teleVisionID = [[element elementForName:@"id"] stringValue];
        self.schedule = [[element elementForName:@"schedule"] stringValue];
        self.imageURL = [NSString stringWithFormat:@"http://tv.univision.mn/uploads/tv/%@.png",[[element elementForName:@"image"] stringValue]];
        self.streamURL = [[element elementForName:@"url"] stringValue];
    }
    return self;
}
@end

//
//  Schedule.h
//  GangstarTelevision
//
//  Created by Gantulga Tsendsuren on 3/17/14.
//  Copyright (c) 2014 Sorako LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDXML.h>

@interface Schedule : NSObject
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *archiveurl;

- (id)initWithDDXMLElement:(DDXMLElement *)element;

@end

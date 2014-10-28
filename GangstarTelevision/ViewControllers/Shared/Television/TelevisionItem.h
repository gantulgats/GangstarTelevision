//
//  TelevisionItem.h
//  TestUnivison
//
//  Created by Gantulga Tsendsuren on 10/24/13.
//  Copyright (c) 2013 SpoMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDXML.h>
@interface TelevisionItem : NSObject
@property (nonatomic, strong) NSString *teleVisionName;
@property (nonatomic, strong) NSString *teleVisionID;
@property (nonatomic, strong) NSString *schedule;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *streamURL;

- (id)initWithDDXMLElement:(DDXMLElement *)element;
@end

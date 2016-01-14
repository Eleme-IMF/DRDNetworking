//
//  DRDTestCase.h
//  Durandal
//
//  Created by 圣迪 on 15/12/17.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Expecta.h"
#import "OCMock.h"

extern NSString * const DRDNetworkingTestsBaseURLString;
extern NSUInteger normalTimeout;

@interface DRDTestCase : XCTestCase

- (NSString *)baseURLStr;

@end
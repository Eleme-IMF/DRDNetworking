//
//  DRDTestCase.m
//  Durandal
//
//  Created by 圣迪 on 15/12/17.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDAPIManager.h"
#import "DRDConfig.h"
#import <Expecta/Expecta.h>

NSString * const DRDNetworkingTestsBaseURLString = @"http://httpbin.org/";
NSUInteger normalTimeout = 30;

@implementation DRDTestCase

- (void)setUp {
    [super setUp];

    [Expecta setAsynchronousTestTimeout:normalTimeout];
}

- (void)tearDown {
    DRDConfig *nilConfiguration = [[DRDConfig alloc]init];
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:nilConfiguration];
    [super tearDown];
}
- (NSString *)baseURLStr {
    return DRDNetworkingTestsBaseURLString;
}

@end

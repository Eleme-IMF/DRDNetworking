//
//  DRDConfigTest.m
//  Durandal
//
//  Created by 圣迪 on 15/12/17.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"
#import "DRDConfig.h"

@interface DRDAPIManager (UnitTesting)

- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI  *)api;
- (NSString *)requestBaseUrlStringWithAPI:(DRDBaseAPI  *)api;

@end

@interface DRDConfigTest : DRDTestCase

@end

@implementation DRDConfigTest

- (void)testUserAgent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testUserAgent"];
    NSString *userAgentStr = @"Hellcoming";
    
    DRDConfig *configuration = [[DRDConfig alloc] init];
    configuration.userAgent  = userAgentStr;
    configuration.baseUrlStr = nil;
    
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:configuration];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc]initWithRequestMethod:@"user-agent"];
    api.baseUrl        = [self baseURLStr] ;
    api.apiRequestMethodType      = DRDRequestMethodTypeGET;
    api.apiRequestSerializerType  = DRDRequestSerializerTypeJSON;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        if (!error) {
            XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
            XCTAssert([[((NSDictionary *)responseObject) allKeys] containsObject:@"user-agent"]);
            XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"user-agent"] isEqualToString:userAgentStr]);
        }
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testBaseUrl {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBaseUrl"];
    
    NSString *baseUrlStr = @"http://www.ele.me/hello";
    
    DRDConfig *configuration = [[DRDConfig alloc] init];
    configuration.userAgent  = nil;
    configuration.baseUrlStr = baseUrlStr;
    
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:configuration];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc]init];
    api.apiRequestSerializerType  = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    __weak DRDGeneralAPI *weakAPI = api;
    api.apiRequestDidSentBlock = ^{
        __strong typeof(weakAPI) strongAPI = weakAPI;
        XCTAssert(strongAPI.baseUrl == nil);
        XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestBaseUrlStringWithAPI:strongAPI]
                   isEqualToString:@"http://www.ele.me/"]);
        XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:strongAPI]
                   isEqualToString:@"hello"]);
        [expectation fulfill];
    };
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testCopy {
    DRDConfig *configuration = [[DRDConfig alloc] init];
    configuration.userAgent  = @"user-agent";
    configuration.baseUrlStr = nil;
    
    DRDConfig *newConfig     = [configuration copy];
    XCTAssert(newConfig != configuration);
    XCTAssert([newConfig.userAgent isEqualToString:configuration.userAgent]);
    XCTAssertNil(configuration.baseUrlStr);
    XCTAssertNil(newConfig.baseUrlStr);
    XCTAssert(newConfig.maxHttpConnectionPerHost == configuration.maxHttpConnectionPerHost);
    XCTAssert(newConfig.isErrorCodeDisplayEnabled == configuration.isErrorCodeDisplayEnabled);
    XCTAssert([newConfig.generalErrorTypeStr isEqualToString:configuration.generalErrorTypeStr]);
    XCTAssert([newConfig.frequentRequestErrorStr isEqualToString:configuration.frequentRequestErrorStr]);
    XCTAssert([newConfig.networkNotReachableErrorStr isEqualToString:configuration.networkNotReachableErrorStr]);
    XCTAssert(newConfig.isNetworkingActivityIndicatorEnabled == configuration.isNetworkingActivityIndicatorEnabled);
}

@end


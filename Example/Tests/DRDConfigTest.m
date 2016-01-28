//
//  DRDConfigTest.m
//  Durandal
//
//  Created by 圣迪 on 15/12/17.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import <DRDGeneralAPI.h>
#import <DRDAPIManager.h>
#import <DRDConfig.h>

@interface DRDAPIManager (UnitTesting)

- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI  *)api;
- (NSString *)requestBaseUrlStringWithAPI:(DRDBaseAPI  *)api;

@end

@interface DRDConfigTest : DRDTestCase

@end

@implementation DRDConfigTest

- (void)testUserAgent {
    NSString *userAgentStr = @"Hellcoming";
    
    DRDConfig *configuration = [[DRDConfig alloc] init];
    configuration.userAgent  = userAgentStr;
    
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:configuration];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc]initWithRequestMethod:@"user-agent"];
    api.baseUrl        = [self baseURLStr] ;
    api.apiRequestMethodType      = DRDRequestMethodTypeGET;
    api.apiRequestSerializerType  = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        if (!error) {
            XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
            XCTAssert([[((NSDictionary *)responseObject) allKeys] containsObject:@"user-agent"]);
            XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"user-agent"] isEqualToString:userAgentStr]);
        }
    }];
    [api start];
}

- (void)testBaseUrl {
    NSString *baseUrlStr = @"http://www.ele.me/hello";
    
    DRDConfig *configuration = [[DRDConfig alloc] init];
    configuration.baseUrlStr = baseUrlStr;
    
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:configuration];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc]initWithRequestMethod:@""];
    api.apiRequestSerializerType  = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    __weak DRDGeneralAPI *weakAPI = api;
    api.apiRequestDidSentBlock = ^{
        XCTAssert(weakAPI.baseUrl == nil);
        XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestBaseUrlStringWithAPI:weakAPI]
                   isEqualToString:@"http://www.ele.me/"]);
        XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:weakAPI]
                   isEqualToString:@"hello"]);
    };
    [api start];
}

@end


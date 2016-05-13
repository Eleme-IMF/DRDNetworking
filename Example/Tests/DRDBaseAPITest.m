//
//  DRDBaseAPITest.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/13.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"

NSString *eleUrl = @"http://www.ele.me/home/";

@interface DRDAPIManager (UnitTesting)

- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI  *)api;
- (NSString *)requestBaseUrlStringWithAPI:(DRDBaseAPI  *)api;

@end

@interface DRDNoProtocolImpAPI : DRDBaseAPI

@end

@implementation DRDNoProtocolImpAPI

@end

@interface DRDBaseAPITest : DRDTestCase

@end

@implementation DRDBaseAPITest

- (void)testCustomUrl {
    DRDGeneralAPI *generalapi   = [[DRDGeneralAPI alloc] init];
    generalapi.baseUrl          = self.baseURLStr;
    generalapi.customRequestUrl = eleUrl;

    NSString *baseUrlStr = [[DRDAPIManager sharedDRDAPIManager] requestBaseUrlStringWithAPI:generalapi];
    
    XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:generalapi]
               isEqualToString:[eleUrl stringByReplacingOccurrencesOfString:baseUrlStr
                                                                 withString:@""]]);
    
    DRDGeneralAPI *generalapiWithRequestMethod   = [[DRDGeneralAPI alloc] init];
    generalapiWithRequestMethod.baseUrl          = self.baseURLStr;
    generalapiWithRequestMethod.requestMethod    = @"get";
    generalapiWithRequestMethod.customRequestUrl = eleUrl;
    
    XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:generalapiWithRequestMethod]
               isEqualToString:[eleUrl stringByReplacingOccurrencesOfString:baseUrlStr
                                                                 withString:@""]]);
    XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestBaseUrlStringWithAPI:generalapiWithRequestMethod]
              isEqualToString:@"http://www.ele.me/"]);
}

@end

//
//  DRDBaseAPITest.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/13.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import <DRDGeneralAPI.h>
#import <DRDAPIManager.h>

NSString *eleUrl = @"http://ele.me";

@interface DRDAPIManager (UnitTesting)

- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI<DRDAPI> *)api;

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

    XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:generalapi]
               isEqualToString:eleUrl]);
    
    DRDGeneralAPI *generalapiWithRequestMethod = [[DRDGeneralAPI alloc] init];
    generalapiWithRequestMethod.baseUrl = self.baseURLStr;
    generalapiWithRequestMethod.requestMethod = @"get";
    generalapiWithRequestMethod.customRequestUrl = eleUrl;
    
    XCTAssert([[[DRDAPIManager sharedDRDAPIManager] requestUrlStringWithAPI:generalapiWithRequestMethod]
               isEqualToString:eleUrl]);
}

- (void)testNotImplementProtocol {
    BOOL exceptioinHappend = NO;
    @try {
        __unused DRDNoProtocolImpAPI *noImpApi = [[DRDNoProtocolImpAPI alloc] init];
    }
    @catch (NSException *exception) {
        exceptioinHappend = YES;
    }
    @finally {
        XCTAssert(exceptioinHappend == YES);
    }
}

@end

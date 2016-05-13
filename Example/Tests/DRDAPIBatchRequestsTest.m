//
//  DRDAPIBatchRequestsTest.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/13.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDAPIBatchAPIRequests.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"
#import "DRDConfig.h"
#import "AFNetworking.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "OHHTTPStubs.h"

@interface DRDAPIManager (UnitTesting)

- (AFHTTPSessionManager *)sessionManagerWithAPI:(DRDBaseAPI*)api;

@end


@interface DRDAPIBatchRequestsTest : DRDTestCase

@end

@implementation DRDAPIBatchRequestsTest

- (void)testAddAPIRequest {
    DRDAPIBatchAPIRequests *apiBatchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    DRDGeneralAPI *generalAPI = [[DRDGeneralAPI alloc] init];
    generalAPI.baseUrl        = self.baseURLStr;
    generalAPI.requestMethod  = @"generalAPI";
    
    DRDGeneralAPI *generalGet = [[DRDGeneralAPI alloc] init];
    generalGet.baseUrl        = self.baseURLStr;
    generalGet.requestMethod  = @"GetAPI";
    
    [apiBatchRequests addAPIRequest:generalAPI];
    [apiBatchRequests addAPIRequest:generalGet];
    
    NSSet *apiSet = apiBatchRequests.apiRequestsSet;
    XCTAssert([apiSet containsObject:generalAPI]);
    XCTAssert([apiSet containsObject:generalGet]);
    
}

- (void)testAddBatchAPIRequests {
    DRDAPIBatchAPIRequests *apiBatchRequests = [[DRDAPIBatchAPIRequests alloc] init];

    DRDGeneralAPI *generalAPI                = [[DRDGeneralAPI alloc] init];
    generalAPI.baseUrl                       = self.baseURLStr;
    generalAPI.requestMethod                 = @"generalAPI";

    DRDGeneralAPI *generalGet                = [[DRDGeneralAPI alloc] init];
    generalGet.baseUrl                       = self.baseURLStr;
    generalGet.requestMethod                 = @"GetAPI";
    generalGet.apiRequestMethodType          = DRDRequestMethodTypePOST;
    
    NSMutableSet *multiSet    = [[NSMutableSet alloc] initWithObjects:generalGet, generalAPI, nil];
    [apiBatchRequests addBatchAPIRequests:multiSet];
    
    NSSet *apiSet = apiBatchRequests.apiRequestsSet;
    XCTAssert([apiSet containsObject:generalAPI]);
    XCTAssert([apiSet containsObject:generalGet]);
    
    DRDAPIBatchAPIRequests *apiSomewrongBatchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    NSMutableSet *multiSomewrongSet = [[NSMutableSet alloc] initWithObjects:generalAPI, @"hello", nil];
    BOOL exceptionHappend = NO;
    @try {
        [apiSomewrongBatchRequests addBatchAPIRequests:multiSomewrongSet];
    }
    @catch (NSException *exception) {
        exceptionHappend = YES;
    }
    @finally {
        XCTAssert(exceptionHappend == YES);
    }
    
    DRDAPIBatchAPIRequests *nilBatchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    NSMutableSet *nilSet = [[NSMutableSet alloc]init];
    exceptionHappend = NO;
    @try {
        [nilBatchRequests addBatchAPIRequests:nilSet];
    }
    @catch (NSException *exception) {
        exceptionHappend = YES;
    }
    @finally {
        XCTAssert(exceptionHappend == YES);
    }
    
}

- (void)testStart {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testStart"];
    DRDAPIBatchAPIRequests *apiBatchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    
    DRDGeneralAPI *generalAPI                = [[DRDGeneralAPI alloc] init];
    generalAPI.requestMethod                 = @"get";
    generalAPI.baseUrl                       = self.baseURLStr;
    generalAPI.apiRequestMethodType          = DRDRequestMethodTypeGET;
    [generalAPI setApiCompletionHandler:^(id obj, NSError * error) {
        XCTAssert(error == nil);
        [expectation fulfill];
    }];
    
    [apiBatchRequests addAPIRequest:generalAPI];
    
    [apiBatchRequests start];
    
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

@end

//
//  DRDAPIManagerTest.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/13.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "OCMock.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"
#import "DRDAPIBatchAPIRequests.h"
#import "AFNetworking.h"
#import "DRDNetworkErrorObserverProtocol.h"
#import "OHHTTPStubs.h"

@interface NetworkErrorObserver : NSObject<DRDNetworkErrorObserverProtocol>

@end

@implementation NetworkErrorObserver

- (void)networkErrorWithErrorInfo:(NSError *)error {

}

@end

@interface DRDAPIManager (UnitTesting)

- (AFHTTPSessionManager *)sessionManagerWithAPI:(DRDBaseAPI *)api;
@property (nonatomic, strong, readonly) NSMutableSet *errorObservers;

@end

@interface DRDAPIManagerTest : DRDTestCase

@end

@implementation DRDAPIManagerTest

- (void)testSharedManager {
    DRDAPIManager *manager = [[DRDAPIManager alloc] init];
    XCTAssert(manager == [DRDAPIManager sharedDRDAPIManager]);
}

- (void)testSendBatchAPIRequests {
    id afnSession  = OCMPartialMock([[AFHTTPSessionManager alloc]
                                     initWithBaseURL:[NSURL URLWithString:@"http://ele.me"]]);
    id partialMock = OCMPartialMock([DRDAPIManager sharedDRDAPIManager]);
    OCMStub([partialMock sessionManagerWithAPI:[OCMArg any]]).andReturn(afnSession);
    
    DRDGeneralAPI *generalAPIGet        = [[DRDGeneralAPI alloc] init];
    generalAPIGet.apiRequestMethodType  = DRDRequestMethodTypeGET;
    generalAPIGet.baseUrl               = self.baseURLStr;

    DRDGeneralAPI *generalAPIPost       = [[DRDGeneralAPI alloc] init];
    generalAPIPost.apiRequestMethodType = DRDRequestMethodTypePOST;
    generalAPIPost.baseUrl              = self.baseURLStr;
    generalAPIPost.requestMethod        = @"post";
    
    DRDAPIBatchAPIRequests *batchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    [batchRequests addAPIRequest:generalAPIGet];
    [batchRequests addAPIRequest:generalAPIPost];
    
    [[DRDAPIManager sharedDRDAPIManager] sendBatchAPIRequests:batchRequests];
    
    OCMVerify([afnSession GET:[OCMArg any]
                   parameters:[OCMArg any]
                     progress:[OCMArg any]
                      success:[OCMArg any]
                      failure:[OCMArg any]]);
    OCMVerify([afnSession POST:[OCMArg any]
                    parameters:[OCMArg any]
                      progress:[OCMArg any]
                       success:[OCMArg any]
                       failure:[OCMArg any]]);
    [partialMock stopMocking];
    [afnSession stopMocking];
}

- (void)testErrorObserverAddRemove {
    NetworkErrorObserver *observer = [[NetworkErrorObserver alloc]init];
    [[DRDAPIManager sharedDRDAPIManager] registerNetworkErrorObserver:observer];
    XCTAssert([[ DRDAPIManager sharedDRDAPIManager].errorObservers containsObject:observer] == true);
    
    [[DRDAPIManager sharedDRDAPIManager] removeNetworkErrorObserver:observer];
    XCTAssert([[DRDAPIManager sharedDRDAPIManager].errorObservers containsObject:observer] == false);
    
    NetworkErrorObserver *observer2 = [[NetworkErrorObserver alloc]init];
    [[DRDAPIManager sharedDRDAPIManager] registerNetworkErrorObserver:observer];
    [[DRDAPIManager sharedDRDAPIManager] registerNetworkErrorObserver:observer];
    XCTAssert([[DRDAPIManager sharedDRDAPIManager].errorObservers count] == 1);
    
    [[DRDAPIManager sharedDRDAPIManager] registerNetworkErrorObserver:observer2];
    XCTAssert([[DRDAPIManager sharedDRDAPIManager].errorObservers count] == 2);
    
    [[DRDAPIManager sharedDRDAPIManager] removeNetworkErrorObserver:observer2];
    [[DRDAPIManager sharedDRDAPIManager] removeNetworkErrorObserver:observer];
    XCTAssert([[DRDAPIManager sharedDRDAPIManager].errorObservers count] == 0);
}

- (void)testObserverNotify {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testObserverNotify"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"ele.me"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary *errorInfo = @{
                                    NSLocalizedFailureReasonErrorKey: @"Error Reason",
                                    NSLocalizedRecoverySuggestionErrorKey: @"No Suggestions",
                                    NSLocalizedDescriptionKey: @"This is the Error Descriptions"
                                    };
        NSError *error = [NSError errorWithDomain:@"elemeErrorDomain"
                                             code:404
                                         userInfo:errorInfo];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    id networkErroObserver = OCMClassMock([NetworkErrorObserver class]);
    [[DRDAPIManager sharedDRDAPIManager] registerNetworkErrorObserver:networkErroObserver];
    DRDGeneralAPI *generalAPIGet        = [[DRDGeneralAPI alloc] init];
    generalAPIGet.apiRequestMethodType  = DRDRequestMethodTypeGET;
    generalAPIGet.customRequestUrl      = @"http://ele.me";
    [generalAPIGet setApiCompletionHandler:^(id obj, NSError *error) {
        OCMVerify([networkErroObserver networkErrorWithErrorInfo:[OCMArg any]]);
        [[DRDAPIManager sharedDRDAPIManager] removeNetworkErrorObserver:networkErroObserver];
        [networkErroObserver stopMocking];
        [expectation fulfill];
    }];
    [generalAPIGet start];
    
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

@end

//
//  DRDAPIManagerTest.m
//  Durandal
//
//  Created by 圣迪 on 15/12/17.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"
#import "DRDConfig.h"
#import "AFURLRequestSerialization.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

@interface DRDAPITest : DRDTestCase

@end

@implementation DRDAPITest

- (void)testCancelAPI {
    // FIX-ME:
    // How to test a Cancel API?
#if 0
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCancelAPI"];
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://ele.me";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc]initWithRequestMethod:@"home"];
    __weak DRDGeneralAPI *weakAPI =api;
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert(NO);
        [expectation fulfill];
    }];
    [api setApiRequestWillBeSentBlock:^{
        [weakAPI cancel];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssert(YES);
#endif
}

- (void)testAPIGET {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGETAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@"get"];
    api.apiRequestMethodType = DRDRequestMethodTypeGET;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;

    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"url"] isEqualToString:@"http://httpbin.org/get"]);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testAPIPOST {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPOSTAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@"post"];
    api.apiRequestMethodType = DRDRequestMethodTypePOST;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"url"] isEqualToString:@"http://httpbin.org/post"]);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testAPIPostConstructingBody {
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"testAPIPostConstructingBody"];
    DRDConfig *config = [[DRDConfig alloc] init];
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@""];
    api.customRequestUrl = @"http://httpbin.org/post";
    api.apiRequestMethodType = DRDRequestMethodTypePOST;
    api.apiRequestSerializerType = DRDRequestSerializerTypeJSON;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert(responseObject != nil);
        XCTAssert(error == nil);
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        NSArray *allKeys = [(NSDictionary *)responseObject allKeys];
        XCTAssert([allKeys containsObject:@"files"]);
        @try {
            NSDictionary *filesField = [(NSDictionary *)responseObject objectForKey:@"files"];
            XCTAssert([[filesField allKeys] containsObject:@"pictures"]);
        } @catch(NSException *e) {
            
        } @finally {
            
        }
    }];
    [api setApiRequestConstructingBodyBlock:^(id <DRDMultipartFormData>formData) {
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"test"]);
        [formData appendPartWithFileData:imageData name:@"pictures" fileName:@"test" mimeType:@"image/jpeg"];
    }];
    [api setApiProgressBlock:^(NSProgress * progress) {
        XCTAssert(progress != nil);
        NSLog(@"fractionCompleted = %f", progress.fractionCompleted);
        BOOL flag = (fabs((1.0f) - (progress.fractionCompleted)) < FLT_EPSILON);
        flag ? [expectation fulfill] : nil;
    }];
    [api start];
    
    [self waitForExpectationsWithTimeout:normalTimeout * 2 handler:nil];
}

- (void)testAPIPatch {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPatchAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@"patch"];
    api.apiRequestMethodType = DRDRequestMethodTypePATCH;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"url"] isEqualToString:@"http://httpbin.org/patch"]);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testAPIPut {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPUTAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@"put"];
    api.apiRequestMethodType = DRDRequestMethodTypePUT;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"url"] isEqualToString:@"http://httpbin.org/put"]);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testAPIDelete {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testDeleteAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] initWithRequestMethod:@"delete"];
    api.apiRequestMethodType = DRDRequestMethodTypeDELETE;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        XCTAssert([[((NSDictionary *)responseObject) objectForKey:@"url"] isEqualToString:@"http://httpbin.org/delete"]);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

- (void)testAPIHEAD {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testHEADAPI"];
    
    DRDConfig *config = [[DRDConfig alloc]init];
    config.baseUrlStr = @"http://httpbin.org";
    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:config];
    
    DRDGeneralAPI *api = [[DRDGeneralAPI alloc] init];
    api.apiRequestMethodType = DRDRequestMethodTypeHEAD;
    api.apiRequestSerializerType = DRDRequestSerializerTypeHTTP;
    api.apiResponseSerializerType = DRDResponseSerializerTypeJSON;
    
    [api setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert(responseObject == nil);
        XCTAssert(error == nil);
        [expectation fulfill];
    }];
    [api start];
    [self waitForExpectationsWithTimeout:normalTimeout handler:nil];
}

@end

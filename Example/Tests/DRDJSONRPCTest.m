//
//  DRDJSONRPCTest.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/13.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIManager.h"
#import "DRDJsonRpcVersionTwo.h"

@interface TestAuthor : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@end

@implementation TestAuthor

@end

static NSString *jsonRPCUrl = @"http://www.raboof.com/projects/jayrock/demo.ashx?test";

@interface DRDJSONRPCTest : DRDTestCase

@end

@implementation DRDJSONRPCTest

- (void)testJsonRpcNumber {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testJSONRPCNumber"];

    DRDGeneralAPI *generalAPI = [[DRDGeneralAPI alloc]init];
    generalAPI.apiRequestMethodType = DRDRequestMethodTypePOST;
    generalAPI.apiRequestSerializerType = DRDRequestSerializerTypeJSON;
    generalAPI.rpcDelegate = [DRDJsonRpcVersionTwo sharedJsonRpcVersionTwo];
    generalAPI.baseUrl     = jsonRPCUrl;
    
    generalAPI.requestMethod = @"add";
    generalAPI.requestParameters = @{
                                     @"a" : @1,
                                     @"b" : @3
                                     };
    
    [generalAPI setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSNumber class]]);
        XCTAssert([((NSNumber *)responseObject) integerValue] == 4);
        XCTAssert(error == nil);
        if (expectation) {
            [expectation fulfill];
        }
    }];
    [generalAPI start];
    [self waitForExpectationsWithTimeout:normalTimeout * 2 handler:nil];
}

- (void)testJsonRpcArray {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testJSONRPCArray"];
    
    DRDGeneralAPI *generalAPI           = [[DRDGeneralAPI alloc]init];
    generalAPI.apiRequestMethodType     = DRDRequestMethodTypePOST;
    generalAPI.apiRequestSerializerType = DRDRequestSerializerTypeJSON;
    generalAPI.rpcDelegate              = [DRDJsonRpcVersionTwo sharedJsonRpcVersionTwo];
    generalAPI.baseUrl                  = jsonRPCUrl;
    
    generalAPI.requestMethod = @"getRowArray";
    generalAPI.requestParameters = @{};
    
    [generalAPI setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[NSArray class]]);
        XCTAssert(error == nil);
        [expectation fulfill];
    }];
    [generalAPI start];
    [self waitForExpectationsWithTimeout:normalTimeout * 2 handler:nil];
}

- (void)testJsonRpcThrowError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testJSONRPCError"];
    
    DRDGeneralAPI *generalAPI = [[DRDGeneralAPI alloc]init];
    generalAPI.apiRequestMethodType = DRDRequestMethodTypePOST;
    generalAPI.apiRequestSerializerType = DRDRequestSerializerTypeJSON;
    generalAPI.rpcDelegate = [DRDJsonRpcVersionTwo sharedJsonRpcVersionTwo];
    generalAPI.baseUrl     = jsonRPCUrl;
    
    generalAPI.requestMethod = @"throwError";
    generalAPI.requestParameters = @{};
    
    [generalAPI setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert(error != nil);
        XCTAssert(responseObject == nil);
        [expectation fulfill];
    }];
    [generalAPI start];
    [self waitForExpectationsWithTimeout:normalTimeout * 2 handler:nil];
}

- (void)testJsonRpcJsonToModelConvert {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testJSONRPCJsonToModelConvert"];
    
    DRDGeneralAPI *generalAPI = [[DRDGeneralAPI alloc]init];
    generalAPI.apiRequestMethodType = DRDRequestMethodTypePOST;
    generalAPI.apiRequestSerializerType = DRDRequestSerializerTypeJSON;
    generalAPI.rpcDelegate = [DRDJsonRpcVersionTwo sharedJsonRpcVersionTwo];
    generalAPI.baseUrl     = jsonRPCUrl;
    
    generalAPI.requestMethod = @"getAuthor";
    generalAPI.requestParameters = @{};
    
    [generalAPI setApiResponseObjReformerBlock:^id  (id responseObject, NSError * error) {
        XCTAssert(error == nil);
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        TestAuthor *author = [[TestAuthor alloc] init];
        BOOL exceptionHappend = NO;
        @try {
            author.firstName   = [((NSDictionary *)responseObject) objectForKey:@"FirstName"];
            author.lastName    = [((NSDictionary *)responseObject) objectForKey:@"LastName"];
        }
        @catch (NSException *exception) {
            exceptionHappend = YES;
        }
        @finally {
            XCTAssert(exceptionHappend == NO);
        }
        if (author.firstName && author.lastName) {
            return author;
        } else {
            return nil;
        }
    }];
    
    [generalAPI setApiCompletionHandler:^(id responseObject, NSError *error) {
        XCTAssert([responseObject isKindOfClass:[TestAuthor class]]);
        [expectation fulfill];
    }];
    [generalAPI start];
    [self waitForExpectationsWithTimeout:normalTimeout * 2 handler:nil];
}

@end

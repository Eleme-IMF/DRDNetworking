//
//  DRDSecurityPolicyTest.m
//  Durandal
//
//  Created by 圣迪 on 16/1/27.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDTestCase.h"
#import "DRDNetworking.h"

@interface DRDSecurityPolicyTest : DRDTestCase

@end

@implementation DRDSecurityPolicyTest

- (void)testSecurityValue {
    DRDSecurityPolicy *nonePolicy = [DRDSecurityPolicy policyWithPinningMode:DRDSSLPinningModeNone];
    XCTAssert(nonePolicy.allowInvalidCertificates == NO);
    XCTAssert(nonePolicy.validatesDomainName == YES);
    XCTAssert(nonePolicy.SSLPinningMode == DRDSSLPinningModeNone);
    
    nonePolicy.allowInvalidCertificates = YES;
    XCTAssert(nonePolicy.allowInvalidCertificates == YES);
    nonePolicy.validatesDomainName = NO;
    XCTAssert(nonePolicy.validatesDomainName == NO);

    DRDSecurityPolicy *publicKeyPolicy = [DRDSecurityPolicy policyWithPinningMode:DRDSSLPinningModePublicKey];
    XCTAssert(publicKeyPolicy.allowInvalidCertificates == NO);
    XCTAssert(publicKeyPolicy.validatesDomainName == YES);
    XCTAssert(publicKeyPolicy.SSLPinningMode == DRDSSLPinningModePublicKey);
    
    DRDSecurityPolicy *certFilePolicy = [DRDSecurityPolicy policyWithPinningMode:DRDSSLPinningModeCertificate];
    XCTAssert(certFilePolicy.allowInvalidCertificates == NO);
    XCTAssert(certFilePolicy.validatesDomainName == YES);
    XCTAssert(certFilePolicy.SSLPinningMode == DRDSSLPinningModeCertificate);
}

@end

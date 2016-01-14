//
//  DRDSecurityPolicy.m
//  Pods
//
//  Created by 圣迪 on 16/1/8.
//
//

#import "DRDSecurityPolicy.h"
#import "AFNetworking.h"

@interface DRDSecurityPolicy ()

@property (readwrite, nonatomic, assign) DRDSSLPinningMode SSLPinningMode;

@end

@implementation DRDSecurityPolicy

+ (instancetype)policyWithPinningMode:(DRDSSLPinningMode)pinningMode {
    DRDSecurityPolicy *securityPolicy = [[DRDSecurityPolicy alloc] init];
    if (securityPolicy) {
        securityPolicy.SSLPinningMode           = pinningMode;
        securityPolicy.allowInvalidCertificates = NO;
        securityPolicy.validatesDomainName      = YES;
    }
    return securityPolicy;
}

@end

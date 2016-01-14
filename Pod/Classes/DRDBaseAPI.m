//
//  DRDBaseAPI.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDBaseAPI.h"
#import "AFNetworking.h"
#import "DRDAPIManager.h"
#import "DRDRPCProtocol.h"
#import "DRDSecurityPolicy.h"

@interface DRDBaseAPI ()

@property (nonatomic, weak) id apiSpec;

@end

@implementation DRDBaseAPI

- (instancetype)init {
    self = [super init];
    if ([self conformsToProtocol:@protocol(DRDAPI)]) {
        self.apiSpec = (id)self;
    } else {
        NSAssert(NO, @"具体的api实现须实现 DRDAPI protocol");
    }
    return self;
}

- (NSString *)customRequestUrl {
    return nil;
}

- (nullable NSString *)apiAddtionalRequestFunction {
    return nil;
}

- (nullable NSDictionary *)apiAddtionalRPCParams {
    return nil;
}

- (nullable id<DRDRPCProtocol>)rpcDelegate {
    return nil;
}

- (DRDRequestMethodType)apiRequestMethodType {
    return DRDRequestMethodTypePOST;
}

- (DRDRequestSerializerType)apiRequestSerializerType {
    return DRDRequestSerializerTypeJSON;
}

- (DRDResponseSerializerType)apiResponseSerializerType {
    return DRDResponseSerializerTypeJSON;
}

- (NSURLRequestCachePolicy)apiRequestCachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSTimeInterval)apiRequestTimeoutInterval {
    return DRD_API_REQUEST_TIME_OUT;
}

- (nullable NSDictionary *)apiRequestHTTPHeaderField {
    return @{
             @"Content-Type" : @"application/json; charset=utf-8",
             };
}

- (nullable NSSet *)apiResponseAcceptableContentTypes {
    return [NSSet setWithObjects:
            @"text/json",
            @"text/html",
            @"application/json",
            @"text/javascript", nil];
}

/**
 *  为了方便，在Debug模式下使用None来保证用Charles之类可以抓到HTTPS报文
 *  Production下，则用Pinning Certification PublicKey 来防止中间人攻击
 */
- (nonnull DRDSecurityPolicy *)apiSecurityPolicy {
    DRDSecurityPolicy *securityPolicy;
#ifdef DEBUG
    securityPolicy = [DRDSecurityPolicy policyWithPinningMode:DRDSSLPinningModeNone];
#else
    securityPolicy = [DRDSecurityPolicy policyWithPinningMode:DRDSSLPinningModePublicKey];
#endif
    return securityPolicy;
}

- (void)apiRequestWillBeSent {
    return;
}

- (void)apiRequestDidSent {
    return;
}

- (void)start {
    if ([self conformsToProtocol:@protocol(DRDAPI)]) {
        [[DRDAPIManager sharedDRDAPIManager] sendAPIRequest:((DRDBaseAPI<DRDAPI>*)self)];
    }
}

- (void)cancel {
    if ([self conformsToProtocol:@protocol(DRDAPI)]) {
        [[DRDAPIManager sharedDRDAPIManager] cancelAPIRequest:((DRDBaseAPI<DRDAPI>*)self)];
    }
}

@end

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

@implementation DRDBaseAPI

- (instancetype)init {
    self = [super init];
    if (self) {
        
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

- (nullable NSString *)requestMethod {
    return nil;
}

- (nullable id)requestParameters {
    return nil;
}

- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error {
    return responseObject;
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
    [[DRDAPIManager sharedDRDAPIManager] sendAPIRequest:((DRDBaseAPI *)self)];
}

- (void)cancel {
    [[DRDAPIManager sharedDRDAPIManager] cancelAPIRequest:((DRDBaseAPI *)self)];
}

- (NSUInteger)hash {
    NSMutableString *hashStr = [NSMutableString stringWithFormat:@"%@ %@ %@ %@",
                                [self requestMethod], [self requestParameters], [self baseUrl], [self customRequestUrl]];
    return [hashStr hash];
}

-(BOOL)isEqualToAPI:(DRDBaseAPI *)api {
    return [self hash] == [api hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[DRDBaseAPI class]]) return NO;
    return [self isEqualToAPI:(DRDBaseAPI *) object];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BaseUrl:%@\nCustomUrl:%@", [self baseUrl], [self customRequestUrl]];
}

@end

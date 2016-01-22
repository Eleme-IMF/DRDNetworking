//
//  DRDAPIManager.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDAPIManager.h"
#import "AFNetworking.h"
#import "DRDBaseAPI.h"
#import "DRDConfig.h"
#import "DRDRPCProtocol.h"
#import "DRDAPIBatchAPIRequests.h"
#import <libkern/OSAtomic.h>
#import <pthread.h>
#import "DRDSecurityPolicy.h"


static DRDAPIManager *sharedDRDAPIManager       = nil;
static NSInteger const sessionManagerCountLimit = 50;
static pthread_mutex_t sessionManagerLock = PTHREAD_MUTEX_INITIALIZER;

@interface DRDAPIManager ()

@property (nonatomic, strong) NSCache *sessionManagerCache;

@end

@implementation DRDAPIManager

#pragma mark - Init
+ (DRDAPIManager *)sharedDRDAPIManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDRDAPIManager = [[self alloc] init];
    });
    return sharedDRDAPIManager;
}

- (instancetype)init {
    if (!sharedDRDAPIManager) {
        sharedDRDAPIManager                    = [super init];
        sharedDRDAPIManager.configuration      = [[DRDConfig alloc]init];
    }
    return sharedDRDAPIManager;
}

- (NSCache *)sessionManagerCache {
    if (!_sessionManagerCache) {
        _sessionManagerCache = [[NSCache alloc] init];
        _sessionManagerCache.countLimit = sessionManagerCountLimit;
    }
    return _sessionManagerCache;
}

#pragma mark - Serializer
- (AFHTTPRequestSerializer *)requestSerializerForAPI:(DRDBaseAPI<DRDAPI> *)api withRequestUrlStr:(NSString *)requestUrlStr {
    NSParameterAssert(api);
    __weak typeof(self) weakSelf = self;
    
    AFHTTPRequestSerializer *requestSerializer;
    if ([api apiRequestSerializerType] == DRDRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    requestSerializer.cachePolicy          = [api apiRequestCachePolicy];
    requestSerializer.timeoutInterval      = [api apiRequestTimeoutInterval];
    NSDictionary *requestHeaderFieldParams = [api apiRequestHTTPHeaderField];
    if (![[requestHeaderFieldParams allKeys] containsObject:@"User-Agent"] &&
        self.configuration.userAgent) {
        [requestSerializer setValue:self.configuration.userAgent forHTTPHeaderField:@"User-Agent"];
    }
    if (requestHeaderFieldParams) {
        [requestHeaderFieldParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    NSError *serializationError = nil;
    if (serializationError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleFailureWithError:serializationError andAPI:api];
        });
        return nil;
    }
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerForAPI:(DRDBaseAPI<DRDAPI> *)api {
    NSParameterAssert(api);
    AFHTTPResponseSerializer *responseSerializer;
    if ([api apiResponseSerializerType] == DRDResponseSerializerTypeHTTP) {
        responseSerializer = [AFHTTPResponseSerializer serializer];
    } else {
        responseSerializer = [AFJSONResponseSerializer serializer];
    }
    responseSerializer.acceptableContentTypes = [api apiResponseAcceptableContentTypes];
    return responseSerializer;
}

#pragma mark - Request Invoke Organize
// Request Url
- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI<DRDAPI> *)api {
    NSParameterAssert(api);
    
    // 如果定义了自定义的RequestUrl, 则直接定义RequestUrl
    if ([api customRequestUrl]) {
        return [api customRequestUrl];
    }
    NSAssert(api.baseUrl != nil || self.configuration.baseUrlStr != nil,
             @"api baseURL or self.configuration.baseurl can't be nil together");
    if (!api.baseUrl && self.configuration.baseUrlStr) {
        api.baseUrl = self.configuration.baseUrlStr;
    }
    if (api.rpcDelegate) {
        return [api.rpcDelegate rpcRequestUrlWithAPI:api];
    }
    // 如果啥都没定义，则使用BaseUrl + requestMethod 组成 UrlString
    return [api.baseUrl stringByAppendingPathComponent:[api requestMethod]];
}

// Request Protocol
- (id)requestParamsWithAPI:(DRDBaseAPI<DRDAPI>*)api {
    NSParameterAssert(api);
    
    if (api.rpcDelegate) {
        return [api.rpcDelegate rpcRequestParamsWithAPI:api];
    } else {
        return [api requestParameters];
    }
}

#pragma mark - AFSessionManager
- (AFHTTPSessionManager *)sessionManagerWithAPI:(DRDBaseAPI<DRDAPI>*)api {
    NSParameterAssert(api);
    NSString *requestUrlStr = [self requestUrlStringWithAPI:api];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForAPI:api
                                                             withRequestUrlStr:requestUrlStr];
    if (!requestSerializer) {
        // Serializer Error, just return;
        return nil;
    }
    
    // Response Part
    AFHTTPResponseSerializer *responseSerializer = [self responseSerializerForAPI:api];
    
    // AFHTTPSession
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer     = requestSerializer;
    sessionManager.responseSerializer    = responseSerializer;
    sessionManager.securityPolicy        = [self securityPolicyWithAPI:api];
    
    pthread_mutex_lock(&sessionManagerLock);
    [self.sessionManagerCache setObject:sessionManager forKey:api];
    pthread_mutex_unlock(&sessionManagerLock);
    
    return sessionManager;
}

- (AFSecurityPolicy *)securityPolicyWithAPI:(DRDBaseAPI<DRDAPI>*)api {
    NSUInteger pinningMode                  = api.apiSecurityPolicy.SSLPinningMode;
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates = api.apiSecurityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName      = api.apiSecurityPolicy.validatesDomainName;
    return securityPolicy;
}

#pragma mark - Response Handle
- (void)handleSuccWithResponse:(id)responseObject andAPI:(DRDBaseAPI<DRDAPI>*)api {
    if (api.rpcDelegate) {
        id formattedResponseObj = [api.rpcDelegate rpcResponseObjReformer:responseObject];
        NSError *rpcError = [api.rpcDelegate rpcErrorWithFormattedResponse:formattedResponseObj];
        if (rpcError) {
            [self callAPICompletion:api obj:nil error:rpcError];
            return;
        }
        id rpcResult = [api.rpcDelegate rpcResultWithFormattedResponse:formattedResponseObj];
        [self callAPICompletion:api obj:rpcResult error:nil];
    } else {
        [self callAPICompletion:api obj:responseObject error:nil];
    }
}

- (void)handleFailureWithError:(NSError *)error andAPI:(DRDBaseAPI<DRDAPI>*)api {
    // Error -999, representing API Cancelled
    if ([error.domain isEqualToString: NSURLErrorDomain] &&
        error.code == NSURLErrorCancelled) {
        [self callAPICompletion:api obj:nil error:error];
        return;
    }
    
    // Handle Networking Error
    NSString *errorTypeStr = self.configuration.generalErrorTypeStr;
    NSMutableDictionary *tmpUserInfo = [[NSMutableDictionary alloc]initWithDictionary:error.userInfo copyItems:YES];
    if (![[tmpUserInfo allKeys] containsObject:NSLocalizedFailureReasonErrorKey]) {
        [tmpUserInfo setValue: NSLocalizedString(errorTypeStr, nil) forKey:NSLocalizedFailureReasonErrorKey];
    }
    if (![[tmpUserInfo allKeys] containsObject:NSLocalizedRecoverySuggestionErrorKey]) {
        [tmpUserInfo setValue: NSLocalizedString(errorTypeStr, nil)  forKey:NSLocalizedRecoverySuggestionErrorKey];
    }
    // 加上 networking error code
    NSString *newErrorDescription = errorTypeStr;
    if (self.configuration.isErrorCodeDisplayEnabled) {
        newErrorDescription = [NSString stringWithFormat:@"%@ (%ld)", errorTypeStr, (long)error.code];
    }
    [tmpUserInfo setValue:NSLocalizedString(newErrorDescription, nil) forKey:NSLocalizedDescriptionKey];
    
    NSDictionary *userInfo = [tmpUserInfo copy];
    NSError *err = [NSError errorWithDomain:error.domain
                                       code:error.code
                                   userInfo:userInfo];
    
    [self callAPICompletion:api obj:nil error:err];
}

- (void)callAPICompletion:(DRDBaseAPI<DRDAPI>*)api
                      obj:(id)obj
                    error:(NSError *)error {
    do {
        if ([api respondsToSelector:@selector(apiResponseObjReformer:andError:)]) {
            obj = [api apiResponseObjReformer:obj andError:error];
            break;
        }
        if (api.apiResponseObjReformerBlock) {
            obj = api.apiResponseObjReformerBlock(obj, error);
            break;
        }
    }while (0);
    
    if ([api apiCompletionHandler]) {
        api.apiCompletionHandler(obj, error);
    }
}

#pragma mark - Send Batch Requests
- (void)sendBatchAPIRequests:(nonnull DRDAPIBatchAPIRequests *)apis {
    NSParameterAssert(apis);
    
    dispatch_group_t batch_api_group = dispatch_group_create();
    __weak typeof(self) weakSelf = self;
    [apis.apiRequestsSet enumerateObjectsUsingBlock:^(id api, BOOL * stop) {
        dispatch_group_enter(batch_api_group);
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        AFHTTPSessionManager *sessionManager = [strongSelf sessionManagerWithAPI:api];
        if (!sessionManager) {
            *stop = YES;
        }
        sessionManager.completionGroup = batch_api_group;
        
        [strongSelf _sendSingleAPIRequest:api
                       withSessioNanager:sessionManager
                      andCompletionGroup:batch_api_group];
    }];
    dispatch_group_notify(batch_api_group, dispatch_get_main_queue(), ^{
        if (apis.delegate) {
            [apis.delegate batchAPIRequestsDidFinished:apis];
        }
    });
}

#pragma mark - Send Request
- (void)sendAPIRequest:(nonnull DRDBaseAPI<DRDAPI> *)api {
    NSParameterAssert(api);
    NSAssert(self.configuration, @"Configuration Can not be nil");
    
    AFHTTPSessionManager *sessionManager = [self sessionManagerWithAPI:api];
    if (!sessionManager) {
        return;
    }
    [self _sendSingleAPIRequest:api withSessioNanager:sessionManager];
}

- (void)_sendSingleAPIRequest:(DRDBaseAPI<DRDAPI>*)api withSessioNanager:(AFHTTPSessionManager *)sessionManager {
    [self _sendSingleAPIRequest:api withSessioNanager:sessionManager andCompletionGroup:nil];
}

- (void)_sendSingleAPIRequest:(DRDBaseAPI<DRDAPI>*)api
            withSessioNanager:(AFHTTPSessionManager *)sessionManager
           andCompletionGroup:(dispatch_group_t)completionGroup {
    NSParameterAssert(api);
    NSParameterAssert(sessionManager);
    
    __weak typeof(self) weakSelf = self;
    NSString *requestUrlStr = [self requestUrlStringWithAPI:api];
    id requestParams        = [self requestParamsWithAPI:api];
    
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject)
    = ^(NSURLSessionDataTask * task, id responseObject) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        [strongSelf handleSuccWithResponse:responseObject andAPI:api];
        pthread_mutex_lock(&sessionManagerLock);
        if ([strongSelf.sessionManagerCache objectForKey:api]) {
            [strongSelf.sessionManagerCache removeObjectForKey:api];
        }
        pthread_mutex_unlock(&sessionManagerLock);
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
    };
    
    void (^failureBlock)(NSURLSessionDataTask * task, NSError * error)
    = ^(NSURLSessionDataTask * task, NSError * error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        [strongSelf handleFailureWithError:error andAPI:api];
        pthread_mutex_lock(&sessionManagerLock);
        if ([strongSelf.sessionManagerCache objectForKey:api]) {
            [strongSelf.sessionManagerCache removeObjectForKey:api];
        }
        pthread_mutex_unlock(&sessionManagerLock);
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
    };
    
    void (^apiProgressBlock)(NSProgress *progress)
    = api.apiProgressBlock ?
    ^(NSProgress *progress) {
        if (progress.totalUnitCount <= 0) {
            return;
        }
        api.apiProgressBlock(progress);
    } : nil;
    
    [api apiRequestWillBeSent];
    if (self.configuration.isNetworkingActivityIndicatorEnabled) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    switch ([api apiRequestMethodType]) {
        case DRDRequestMethodTypeGET:
        {
            [sessionManager GET:requestUrlStr
                     parameters:requestParams
                       progress:apiProgressBlock
                        success:successBlock
                        failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypeDELETE:
        {
            [sessionManager DELETE:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypePATCH:
        {
            [sessionManager PATCH:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypePUT:
        {
            [sessionManager PUT:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypeHEAD:
        {
            [sessionManager HEAD:requestUrlStr
                      parameters:requestParams
                         success:^(NSURLSessionDataTask * _Nonnull task) {
                             if (successBlock) {
                                 successBlock(task, nil);
                             }
                         }
                         failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypePOST:
        {
            if (![api apiRequestConstructingBodyBlock]) {
                [sessionManager POST:requestUrlStr
                          parameters:requestParams
                            progress:apiProgressBlock
                             success:successBlock
                             failure:failureBlock];
            } else {
                void (^block)(id <AFMultipartFormData> formData)
                = ^(id <AFMultipartFormData> formData) {
                    api.apiRequestConstructingBodyBlock((id<DRDMultipartFormData>)formData);
                };
                
                [sessionManager POST:requestUrlStr
                          parameters:requestParams
           constructingBodyWithBlock:block
                            progress:apiProgressBlock
                             success:successBlock
                             failure:failureBlock];
            }
        }
            break;
        default:
            [sessionManager GET:requestUrlStr
                     parameters:requestParams
                       progress:apiProgressBlock
                        success:successBlock
                        failure:failureBlock];
            break;
    }
    [api apiRequestDidSent];
    [sessionManager.session finishTasksAndInvalidate];
}

- (void)cancelAPIRequest:(nonnull DRDBaseAPI<DRDAPI> *)api {
    pthread_mutex_lock(&sessionManagerLock);
    AFURLSessionManager *sessionManager = [self.sessionManagerCache objectForKey:api];
    if (sessionManager) {
        NSURLSessionTask *dataTask = [[sessionManager dataTasks] firstObject];
        [dataTask cancel];
        [self.sessionManagerCache removeObjectForKey:api];
    }
    pthread_mutex_unlock(&sessionManagerLock);
}

@end

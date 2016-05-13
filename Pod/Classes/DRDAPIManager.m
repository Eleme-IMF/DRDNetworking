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
#import <pthread.h>
#import "DRDSecurityPolicy.h"
#import "DRDNetworkErrorObserverProtocol.h"

static dispatch_queue_t drd_api_task_creation_queue() {
    static dispatch_queue_t drd_api_task_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        drd_api_task_creation_queue =
        dispatch_queue_create("me.ele.imf.networking.durandal.api.creation", DISPATCH_QUEUE_SERIAL);
    });
    return drd_api_task_creation_queue;
}

static DRDAPIManager *sharedDRDAPIManager       = nil;

@interface DRDAPIManager ()

@property (nonatomic, strong) NSCache *sessionManagerCache;
@property (nonatomic, strong) NSCache *sessionTasksCache;
@property (nonatomic, strong) NSMutableSet<id<DRDNetworkErrorObserverProtocol>> *errorObservers;

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
        sharedDRDAPIManager.errorObservers     = [[NSMutableSet alloc]init];
    }
    return sharedDRDAPIManager;
}

- (NSCache *)sessionManagerCache {
    if (!_sessionManagerCache) {
        _sessionManagerCache = [[NSCache alloc] init];
    }
    return _sessionManagerCache;
}

- (NSCache *)sessionTasksCache {
    if (!_sessionTasksCache) {
        _sessionTasksCache = [[NSCache alloc] init];
    }
    return _sessionTasksCache;
}

#pragma mark - Serializer
- (AFHTTPRequestSerializer *)requestSerializerForAPI:(DRDBaseAPI *)api {
    NSParameterAssert(api);
    
    AFHTTPRequestSerializer *requestSerializer;
    if ([api apiRequestSerializerType] == DRDRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    requestSerializer.cachePolicy          = [api apiRequestCachePolicy];
    requestSerializer.timeoutInterval      = [api apiRequestTimeoutInterval];
    NSDictionary *requestHeaderFieldParams = api.apiHttpHeaderDelegate
                                            ? [api.apiHttpHeaderDelegate apiRequestHTTPHeaderField]
                                            : [api apiRequestHTTPHeaderField];
    if (![[requestHeaderFieldParams allKeys] containsObject:@"User-Agent"] &&
        self.configuration.userAgent) {
        [requestSerializer setValue:self.configuration.userAgent forHTTPHeaderField:@"User-Agent"];
    }
    if (requestHeaderFieldParams) {
        [requestHeaderFieldParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerForAPI:(DRDBaseAPI *)api {
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
- (NSString *)requestBaseUrlStringWithAPI:(DRDBaseAPI *)api {
    NSParameterAssert(api);
    
    // 如果定义了自定义的RequestUrl, 则直接定义RequestUrl
    if ([api customRequestUrl]) {
        NSURL *url  = [NSURL URLWithString:[api customRequestUrl]];
        NSURL *root = [NSURL URLWithString:@"/" relativeToURL:url];
        return [NSString stringWithFormat:@"%@", root.absoluteString];
    }
    
    NSAssert(api.baseUrl != nil || self.configuration.baseUrlStr != nil,
             @"api baseURL or self.configuration.baseurl can't be nil together");
    
    NSString *baseUrl = api.baseUrl ? : self.configuration.baseUrlStr;
    
    // 在某些情况下，一些用户会直接把整个url地址写进 baseUrl
    // 因此，还需要对baseUrl 进行一次切割
    NSURL *theUrl = [NSURL URLWithString:baseUrl];
    NSURL *root   = [NSURL URLWithString:@"/" relativeToURL:theUrl];
    return [NSString stringWithFormat:@"%@", root.absoluteString];
}

// Request Url
- (NSString *)requestUrlStringWithAPI:(DRDBaseAPI *)api {
    NSParameterAssert(api);
    
    NSString *baseUrlStr = [self requestBaseUrlStringWithAPI:api];
    // 如果定义了自定义的RequestUrl, 则直接定义RequestUrl
    if ([api customRequestUrl]) {
        return [[api customRequestUrl] stringByReplacingOccurrencesOfString:baseUrlStr
                                                                 withString:@""];
    }
    NSAssert(api.baseUrl != nil || self.configuration.baseUrlStr != nil,
             @"api baseURL or self.configuration.baseurl can't be nil together");

    if (api.rpcDelegate) {
        NSString *rpcRequestUrlStr = [api.rpcDelegate rpcRequestUrlWithAPI:api];
        return [rpcRequestUrlStr stringByReplacingOccurrencesOfString:baseUrlStr
                                                           withString:@""];
    }
    // 如果啥都没定义，则使用BaseUrl + requestMethod 组成 UrlString
    // 即，直接返回requestMethod
    NSURL *url = [NSURL URLWithString:[api requestMethod] ? : @""
                        relativeToURL:[NSURL URLWithString:[api baseUrl]? : self.configuration.baseUrlStr]];
    return [url.absoluteString stringByReplacingOccurrencesOfString:baseUrlStr
                                                         withString:@""];
}

// Request Protocol
- (id)requestParamsWithAPI:(DRDBaseAPI *)api {
    NSParameterAssert(api);
    
    if (api.rpcDelegate) {
        return [api.rpcDelegate rpcRequestParamsWithAPI:api];
    } else {
        return [api requestParameters];
    }
}

#pragma mark - AFSessionManager
- (AFHTTPSessionManager *)sessionManagerWithAPI:(DRDBaseAPI *)api {
    NSParameterAssert(api);
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForAPI:api];
    if (!requestSerializer) {
        // Serializer Error, just return;
        return nil;
    }
    
    // Response Part
    AFHTTPResponseSerializer *responseSerializer = [self responseSerializerForAPI:api];

    NSString *baseUrlStr = [self requestBaseUrlStringWithAPI:api];
    // AFHTTPSession
    AFHTTPSessionManager *sessionManager;
    sessionManager = [self.sessionManagerCache objectForKey:baseUrlStr];
    if (!sessionManager) {
        sessionManager = [self newSessionManagerWithBaseUrlStr:baseUrlStr];
        [self.sessionManagerCache setObject:sessionManager forKey:baseUrlStr];
    }
    
    sessionManager.requestSerializer     = requestSerializer;
    sessionManager.responseSerializer    = responseSerializer;
    sessionManager.securityPolicy        = [self securityPolicyWithAPI:api];
    
    return sessionManager;
}

- (AFHTTPSessionManager *)newSessionManagerWithBaseUrlStr:(NSString *)baseUrlStr {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if (self.configuration) {
        sessionConfig.HTTPMaximumConnectionsPerHost = self.configuration.maxHttpConnectionPerHost;
    } else {
        sessionConfig.HTTPMaximumConnectionsPerHost = MAX_HTTP_CONNECTION_PER_HOST;
    }
    return [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]
                                    sessionConfiguration:sessionConfig];
}

- (AFSecurityPolicy *)securityPolicyWithAPI:(DRDBaseAPI *)api {
    NSUInteger pinningMode                  = api.apiSecurityPolicy.SSLPinningMode;
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates = api.apiSecurityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName      = api.apiSecurityPolicy.validatesDomainName;
    return securityPolicy;
}

#pragma mark - Response Handle
- (void)handleSuccWithResponse:(id)responseObject andAPI:(DRDBaseAPI *)api {
    if (api.rpcDelegate) {
        id formattedResponseObj = [api.rpcDelegate rpcResponseObjReformer:responseObject withAPI:api];
        NSError *rpcError = [api.rpcDelegate rpcErrorWithFormattedResponse:formattedResponseObj withAPI:api];
        if (rpcError) {
            [self callAPICompletion:api obj:nil error:rpcError];
            return;
        }
        id rpcResult = [api.rpcDelegate rpcResultWithFormattedResponse:formattedResponseObj withAPI:api];
        [self callAPICompletion:api obj:rpcResult error:nil];
    } else {
        [self callAPICompletion:api obj:responseObject error:nil];
    }
}

- (void)handleFailureWithError:(NSError *)error andAPI:(DRDBaseAPI *)api {
    if (error) {
        [self.errorObservers enumerateObjectsUsingBlock:^(id<DRDNetworkErrorObserverProtocol> observer, BOOL * _Nonnull stop) {
            [observer networkErrorWithErrorInfo:error];
        }];
    }
    
    // Error -999, representing API Cancelled
    if ([error.domain isEqualToString: NSURLErrorDomain] &&
        error.code == NSURLErrorCancelled) {
        [self callAPICompletion:api obj:nil error:error];
        return;
    }
    
    // Handle Networking Error
    NSString *errorTypeStr = self.configuration.generalErrorTypeStr;
    NSMutableDictionary *tmpUserInfo = [[NSMutableDictionary alloc]initWithDictionary:error.userInfo copyItems:NO];
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

- (void)callAPICompletion:(DRDBaseAPI *)api
                      obj:(id)obj
                    error:(NSError *)error {
    obj = [api apiResponseObjReformer:obj andError:error];
    if ([api apiCompletionHandler]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            api.apiCompletionHandler(obj, error);
        });
    }
}

#pragma mark - Send Batch Requests
- (void)sendBatchAPIRequests:(nonnull DRDAPIBatchAPIRequests *)apis {
    NSParameterAssert(apis);
    
    NSAssert([[apis.apiRequestsSet valueForKeyPath:@"hash"] count] == [apis.apiRequestsSet count],
             @"Should not have same API");
    
    dispatch_group_t batch_api_group = dispatch_group_create();
    __weak typeof(self) weakSelf = self;
    [apis.apiRequestsSet enumerateObjectsUsingBlock:^(id api, BOOL * stop) {
        dispatch_group_enter(batch_api_group);
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        AFHTTPSessionManager *sessionManager = [strongSelf sessionManagerWithAPI:api];
        if (!sessionManager) {
            *stop = YES;
            dispatch_group_leave(batch_api_group);
        }
        sessionManager.completionGroup = batch_api_group;
        
        [strongSelf _sendSingleAPIRequest:api
                       withSessionManager:sessionManager
                       andCompletionGroup:batch_api_group];
    }];
    dispatch_group_notify(batch_api_group, dispatch_get_main_queue(), ^{
        if (apis.delegate) {
            [apis.delegate batchAPIRequestsDidFinished:apis];
        }
    });
}

#pragma mark - Send Request
- (void)sendAPIRequest:(nonnull DRDBaseAPI *)api {
    NSParameterAssert(api);
    NSAssert(self.configuration, @"Configuration Can not be nil");
    
    dispatch_async(drd_api_task_creation_queue(), ^{
        AFHTTPSessionManager *sessionManager = [self sessionManagerWithAPI:api];
        if (!sessionManager) {
            return;
        }
        [self _sendSingleAPIRequest:api withSessionManager:sessionManager];
    });
}

- (void)_sendSingleAPIRequest:(DRDBaseAPI *)api withSessionManager:(AFHTTPSessionManager *)sessionManager {
    [self _sendSingleAPIRequest:api withSessionManager:sessionManager andCompletionGroup:nil];
}

- (void)_sendSingleAPIRequest:(DRDBaseAPI *)api
           withSessionManager:(AFHTTPSessionManager *)sessionManager
           andCompletionGroup:(dispatch_group_t)completionGroup {
    NSParameterAssert(api);
    NSParameterAssert(sessionManager);
    
    __weak typeof(self) weakSelf = self;
    NSString *requestUrlStr = [self requestUrlStringWithAPI:api];
    id requestParams        = [self requestParamsWithAPI:api];
    NSString *hashKey       = [NSString stringWithFormat:@"%lu", (unsigned long)[api hash]];
    
    if ([self.sessionTasksCache objectForKey:hashKey]) {
        NSString *errorStr     = self.configuration.frequentRequestErrorStr;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : errorStr
                                   };
        NSError *cancelError = [NSError errorWithDomain:NSURLErrorDomain
                                                   code:NSURLErrorCancelled
                                               userInfo:userInfo];
        [self callAPICompletion:api obj:nil error:cancelError];
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
        return;
    }
    
    SCNetworkReachabilityRef hostReachable = SCNetworkReachabilityCreateWithName(NULL, [sessionManager.baseURL.host UTF8String]);
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(hostReachable, &flags);
    bool isReachable = success &&
    (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    if (hostReachable) {
        CFRelease(hostReachable);
    }
    if (!isReachable) {
        // Not Reachable
        NSString *errorStr     = self.configuration.networkNotReachableErrorStr;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : errorStr,
                                   NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"%@ unreachable", sessionManager.baseURL.host]
                                   };
        NSError *networkUnreachableError = [NSError errorWithDomain:NSURLErrorDomain
                                                               code:NSURLErrorCannotConnectToHost
                                                           userInfo:userInfo];
        [self callAPICompletion:api obj:nil error:networkUnreachableError];
        if (completionGroup) {
            dispatch_group_leave(completionGroup);
        }
        return;
    }
    
    void (^successBlock)(NSURLSessionDataTask *task, id responseObject)
    = ^(NSURLSessionDataTask * task, id responseObject) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf.configuration.isNetworkingActivityIndicatorEnabled) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        [strongSelf handleSuccWithResponse:responseObject andAPI:api];
        [strongSelf.sessionTasksCache removeObjectForKey:hashKey];
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
        [strongSelf.sessionTasksCache removeObjectForKey:hashKey];
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
    
    if ([[NSThread currentThread] isMainThread]) {
        [api apiRequestWillBeSent];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [api apiRequestWillBeSent];
        });
    }
    
    if (self.configuration.isNetworkingActivityIndicatorEnabled) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    NSURLSessionDataTask *dataTask;
    switch ([api apiRequestMethodType]) {
        case DRDRequestMethodTypeGET:
        {
            dataTask =
            [sessionManager GET:requestUrlStr
                     parameters:requestParams
                       progress:apiProgressBlock
                        success:successBlock
                        failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypeDELETE:
        {
            dataTask =
            [sessionManager DELETE:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypePATCH:
        {
            dataTask =
            [sessionManager PATCH:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypePUT:
        {
            dataTask =
            [sessionManager PUT:requestUrlStr parameters:requestParams success:successBlock failure:failureBlock];
        }
            break;
        case DRDRequestMethodTypeHEAD:
        {
            dataTask =
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
                dataTask =
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
                dataTask =
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
            dataTask =
            [sessionManager GET:requestUrlStr
                     parameters:requestParams
                       progress:apiProgressBlock
                        success:successBlock
                        failure:failureBlock];
            break;
    }
    if (dataTask) {
        [self.sessionTasksCache setObject:dataTask forKey:hashKey];
    }
    
    if ([[NSThread currentThread] isMainThread]) {
        [api apiRequestDidSent];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [api apiRequestDidSent];
        });
    }
}

- (void)cancelAPIRequest:(nonnull DRDBaseAPI *)api {
    dispatch_async(drd_api_task_creation_queue(), ^{
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (unsigned long)[api hash]];
        NSURLSessionDataTask *dataTask = [self.sessionTasksCache objectForKey:hashKey];
        [self.sessionTasksCache removeObjectForKey:hashKey];
        if (dataTask) {
            [dataTask cancel];
        }
    });
}

#pragma Network Error Observer -
- (void)registerNetworkErrorObserver:(nonnull id<DRDNetworkErrorObserverProtocol>)observer {
    [self.errorObservers addObject:observer];
}


- (void)removeNetworkErrorObserver:(nonnull id<DRDNetworkErrorObserverProtocol>)observer {
    if ([self.errorObservers containsObject:observer]) {
        [self.errorObservers removeObject:observer];
    }
}

@end

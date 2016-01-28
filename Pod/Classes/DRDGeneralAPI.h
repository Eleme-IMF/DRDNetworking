//
//  DRDGeneralAPI.h
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDBaseAPI.h"
#import "DRDAPIDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface DRDGeneralAPI : DRDBaseAPI 

/**
 *  DRDAPI Protocol中的 requestMethod字段
 */
@property (nonatomic,   copy) NSString         *requestMethod;
/**
 *  安全协议设置
 */
@property (nonatomic, strong) DRDSecurityPolicy *apiSecurityPolicy;

/**
 *  同BaseAPI apiRequestMethodType
 */
@property (nonatomic, assign) DRDRequestMethodType      apiRequestMethodType;

/**
 *  同BaseAPI apiRequestSerializerType
 */
@property (nonatomic, assign) DRDRequestSerializerType  apiRequestSerializerType;

/**
 *  同BaseAPI apiResponseSerializerType
 */
@property (nonatomic, assign) DRDResponseSerializerType apiResponseSerializerType;

/**
 *  同BaseAPI apiRequestCachePolicy
 */
@property (nonatomic, assign) NSURLRequestCachePolicy   apiRequestCachePolicy;

/**
 *  同BaseAPI apiRequestTimeoutInterval
 */
@property (nonatomic, assign) NSTimeInterval            apiRequestTimeoutInterval;

/**
 *  DRDAPI Protocol中的 RequestParameters字段
 */
@property (nonatomic, strong, nullable) id           requestParameters;

/**
 *  同BaseAPI apiRequestHTTPHeaderField
 */
@property (nonatomic, strong, nullable) NSDictionary *apiRequestHTTPHeaderField;

/**
 *  同BaseAPI apiResponseAcceptableContentTypes
 */
@property (nonatomic, strong, nullable) NSSet        *apiResponseAcceptableContentTypes;

/**
 *  同BaseAPI apiAddtionalRPCParams
 */
@property (nonatomic, strong, nullable) NSDictionary *apiAddtionalRPCParams;

/**
 *  同BaseAPI customRequestUrl
 */
@property (nonatomic, copy,   nullable) NSString     *customRequestUrl;

/**
 *  同BaseAPI rpcDelegate
 */
@property (nonatomic, weak,   nullable) id<DRDRPCProtocol> rpcDelegate;

/**
 *  同BaseAPI apiHttpHeaderDelegate
 */
@property (nonatomic, weak,   nullable) id<DRDHttpHeaderDelegate> apiHttpHeaderDelegate;

/**
 *  同BaseAPI apiAddtionalRequestFunction
 */
@property (nonatomic, copy,   nullable) NSString     *apiAddtionalRequestFunction;

/**
 *  同BaseAPI apiRequestWillBeSent
 */
@property (nonatomic, copy, nullable) void (^apiRequestWillBeSentBlock)();

/**
 *  同BaseAPI apiRequestDidSent
 */
@property (nonatomic, copy, nullable) void (^apiRequestDidSentBlock)();

/**
 *  一般用来进行JSON -> Model 数据的转换工作
 *   返回的id，如果没有error，则为转换成功后的Model数据；
 *    如果有error， 则直接返回传参中的responseObject
 *
 *  注意：
 *   这里与DRDAPI Protocol中的apiResponseObjReformer 有重合。
 *   这里的block 主要给 DRDGeneralAPI 使用
 *
 *  @param responseObject 请求的返回
 *  @param error          请求的错误
 *
 *  @return 整理过后的请求数据
 */
@property (nonatomic, copy, nullable) id _Nullable (^apiResponseObjReformerBlock)(id responseObject, NSError * _Nullable error);

- (nullable instancetype)init;
- (nullable instancetype)initWithRequestMethod:(NSString *)requestMethod;

@end
NS_ASSUME_NONNULL_END
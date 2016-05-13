//
//  DRDBaseAPI.h
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import <Foundation/Foundation.h>
#import "DRDAPIDefines.h"

@class DRDSecurityPolicy;
@class DRDBaseAPI;
@protocol DRDRPCProtocol;

NS_ASSUME_NONNULL_BEGIN

#pragma mark -
@protocol DRDMultipartFormData

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __nullable __autoreleasing *)error;

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __nullable __autoreleasing *)error;
- (void)appendPartWithInputStream:(nullable NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType;
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;

- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name;
- (void)appendPartWithHeaders:(nullable NSDictionary *)headers
                         body:(NSData *)body;
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay;

@end

#pragma mark -
@protocol DRDHttpHeaderDelegate <NSObject>

- (nullable NSDictionary *)apiRequestHTTPHeaderField;

@end

#pragma mark -

@interface DRDBaseAPI : NSObject

/**
 *  baseURL
 *  注意：如果API子类有设定baseURL, 则 Configuration 里的baseURL不起作用
 *  即： API里的baseURL 优先级更高
 */
@property (nonatomic, copy, nullable) NSString *baseUrl;

/**
 *  用于组织POST体的block
 */
@property (nonatomic, copy, nullable) void (^apiRequestConstructingBodyBlock)(id<DRDMultipartFormData> _Nonnull formData);

/**
 *  api完成后的执行体
 *  responseObject: api 返回的数据结构
 *  error:  api 返回的错误信息
 */
@property (nonatomic, copy, nullable) void (^apiCompletionHandler)(_Nonnull id responseObject,  NSError * _Nullable error);

/**
 *  api 上传、下载等长时间执行的Progress进度
 *  NSProgress: 进度
 */
@property (nonatomic, copy, nullable) void (^apiProgressBlock)(NSProgress * _Nullable progress);

/**
 *  rpcDelegate
 *  用于实现上层JSON-RPC的delegate
 */
@property (nonatomic, weak, nullable) id<DRDRPCProtocol> rpcDelegate;

/**
 *  HTTPHeader Field Delegate
 */
@property (nonatomic, weak, nullable) id<DRDHttpHeaderDelegate> apiHttpHeaderDelegate;

/**
 *  主要用于JSON-RPC协议中的Method字段
 *
 *  @return NSString
 */
- (nullable NSString *)requestMethod;

/**
 *  用户api请求中的参数列表
 *   如果JSON-RPC协议，则Parameters 放入JSON-RPC协议中
 *   如果非JSON-RPC协议，则requestParameters 会作为url的一部分发送给服务器
 *
 *  @return 一般来说是NSDictionary
 */
- (nullable id)requestParameters;

/**
 *  自定义的RequestUrl 请求
 *  @descriptions:
 *    DRDAPIManager 对于RequestUrl 处理为：
 *     当customeRequestUrl 不为空时，将直接返回customRequestUrl 作为请求数据
 *     而不去使用JSON-RPCProtocol 方式组装RequestUrl
 *
 *  @return url String
 */
- (nullable NSString *)customRequestUrl;

/**
 *  一般用来进行JSON -> Model 数据的转换工作
 *   返回的id，如果没有error，则为转换成功后的Model数据；
 *    如果有error， 则直接返回传参中的responseObject
 *
 *  @param responseObject 请求的返回
 *  @param error          请求的错误
 *
 *  @return 默认直接返回responseObject
 */
- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error;

/**
 *  @descriptions
 *    在我们大多数情况下，并不使用
 *    但在一些特殊情况下，比如RPC协议中，虽然遵循RPC协议来call method,
 *     但是仍然需要在url中来指定需要调用的函数名，如 invoke, upload等。
 *    因此增加 addtionalRequestFunction 来进行补充.
 *
 *    仅仅在 rpcDelegate不为空时才会使用。
 *
 *  @default nil
 *
 *  @return 需要调用的远程url method
 */
- (nullable NSString *)apiAddtionalRequestFunction;

/**
 *  @descriptions
 *    在我们大多数情况下，并不使用
 *    但在一些特殊情况下，比如 RPC协议中，在协议中，还需要对type进行定义类型
 *     因此，在这里增加一个字典，来增加RPC协议中额外的数据
 *
 *     仅仅在 rpcDelegate不为空时才会使用
 *
 *  @default nil
 *
 *  @return RPC协议中额外需要传输的数据
 */
- (nullable NSDictionary *)apiAddtionalRPCParams;

/**
 *  请求的类型:GET, POST
 *  @default
 *   DRDRequestMethodTypePost
 *
 *  @return DRDRequestMethodType
 */
- (DRDRequestMethodType)apiRequestMethodType;

/**
 *  Request 序列化类型：JSON, HTTP, 见DRDRequestSerializerType
 *  @default
 *   DRDResponseSerializerTypeJSON
 *
 *  @return DRDRequestSerializerTYPE
 */
- (DRDRequestSerializerType)apiRequestSerializerType;

/**
 *  Response 序列化类型： JSON, HTTP
 *
 *  @return DRDResponseSerializerType
 */
- (DRDResponseSerializerType)apiResponseSerializerType;

/**
 *  HTTP 请求的Cache策略
 *  @default
 *   NSURLRequestUseProtocolCachePolicy
 *
 *  @return NSURLRequestCachePolicy
 */
- (NSURLRequestCachePolicy)apiRequestCachePolicy;

/**
 *  HTTP 请求超时的时间
 *  @default
 *    API_REQUEST_TIME_OUT
 *
 *  @return 超时时间
 */
- (NSTimeInterval)apiRequestTimeoutInterval;

/**
 *  HTTP 请求的头部区域自定义
 *  @default
 *   默认为：@{
 *               @"Content-Type" : @"application/json; charset=utf-8"
 *           }
 *
 *  @return NSDictionary
 */
- (nullable NSDictionary *)apiRequestHTTPHeaderField;

/**
 *  HTTP 请求的返回可接受的内容类型
 *  @default
 *   默认为：[NSSet setWithObjects:
 *            @"text/json",
 *            @"text/html",
 *            @"application/json",
 *            @"text/javascript", nil];
 *
 *  @return NSSet
 */
- (nullable NSSet *)apiResponseAcceptableContentTypes;

/**
 *  HTTPS 请求的Security策略
 *
 *  @return HTTPS证书验证策略
 */
- (nonnull DRDSecurityPolicy *)apiSecurityPolicy;

#pragma mark - Process

/**
 *  API 即将被Sent
 */
- (void)apiRequestWillBeSent;

/**
 *  API 已经被Sent
 */
- (void)apiRequestDidSent;

/**
 *  开启API 请求
 */
- (void)start;

/**
 *  取消API 请求
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
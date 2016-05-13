//
//  DRDRPCProtocol.h
//  Pods
//
//  Created by 圣迪 on 15/12/11.
//
//

#import <Foundation/Foundation.h>

@class DRDBaseAPI;

NS_ASSUME_NONNULL_BEGIN
@protocol DRDRPCProtocol <NSObject>

/**
 *  遵循RPC协议的RequestUrl
 *
 *  @param api 用来组装RPC协议的api
 *
 *  @return 组装完成后的rpc url
 */
- (nullable NSString *)rpcRequestUrlWithAPI:(DRDBaseAPI *)api;

/**
 *  遵循RPC协议的参数列表
 *
 *  @param api 用于组装RPC协议的api
 *
 *  @return 组装完成后的rpc parameters
 */
- (nullable id)rpcRequestParamsWithAPI:(DRDBaseAPI *)api;

/**
 *  遵循RPC协议的解包函数
 *
 *  @param responseObject 一般为网络返回的Raw json数据
 *
 *  @return 解包后的json数据
 */
- (nullable id)rpcResponseObjReformer:(id)responseObject withAPI:(DRDBaseAPI *)api;

/**
 *  rpc拆包后的格式化后的result
 *
 *  @param formattedResponseObj 使用rpcResponseObjReformer 解包后的数据
 *
 *  @return 格式化后的responseObj
 */
- (nullable id)rpcResultWithFormattedResponse:(id)formattedResponseObj withAPI:(DRDBaseAPI *)api;

/**
 *  rpc 拆包后，服务器返回的错误信息
 *
 *  @param formattedResponseObj 使用rpcResponseObjReformer 解包后的数据
 *
 *  @return 格式化后的responseObj
 */
- (NSError *)rpcErrorWithFormattedResponse:(id)formattedResponseObj withAPI:(DRDBaseAPI *)api;

@end
NS_ASSUME_NONNULL_END
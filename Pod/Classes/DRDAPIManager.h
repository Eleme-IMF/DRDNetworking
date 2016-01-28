//
//  DRDAPIManager.h
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import <Foundation/Foundation.h>

@class DRDBaseAPI;
@class DRDConfig;
@class DRDAPIBatchAPIRequests;
@protocol DRDAPI;

@interface DRDAPIManager : NSObject

@property (nonatomic, strong, nonnull) DRDConfig *configuration;

// 单例
+ (nullable DRDAPIManager *)sharedDRDAPIManager;

/**
 *  发送API请求
 *
 *  @param api 要发送的api
 */
- (void)sendAPIRequest:(nonnull DRDBaseAPI  *)api;

/**
 *  取消API请求
 *
 *  @description
 *      如果该请求已经发送或者正在发送，则无法取消
 *
 *  @param api 要取消的api
 */
- (void)cancelAPIRequest:(nonnull DRDBaseAPI  *)api;

/**
 *  发送一系列API请求
 *
 *  @param apis 待发送的API请求集合
 */
- (void)sendBatchAPIRequests:(nonnull DRDAPIBatchAPIRequests *)apis;

@end

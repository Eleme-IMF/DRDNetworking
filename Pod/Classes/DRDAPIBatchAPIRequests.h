//
//  DRDAPIBatchAPIRequests.h
//  Pods
//
//  Created by 圣迪 on 16/1/4.
//
//

#import <Foundation/Foundation.h>

@class DRDBaseAPI;
@class DRDAPIBatchAPIRequests;

@protocol DRDAPIBatchAPIRequestsProtocol <NSObject>

/**
 *  Batch Requests 全部调用完成之后调用
 *
 *  @param batchApis batchApis
 */
- (void)batchAPIRequestsDidFinished:(nonnull DRDAPIBatchAPIRequests *)batchApis;

@end

@interface DRDAPIBatchAPIRequests : NSObject

/**
 *  Batch 执行的API Requests 集合
 */
@property (nonatomic, strong, readonly, nullable) NSMutableSet *apiRequestsSet;

/**
 *  Batch Requests 执行完成之后调用的delegate
 */
@property (nonatomic, weak, nullable) id<DRDAPIBatchAPIRequestsProtocol> delegate;

/**
 *  将API 加入到BatchRequest Set 集合中
 *
 *  @param api
 */
- (void)addAPIRequest:(nonnull DRDBaseAPI *)api;

/**
 *  将带有API集合的Sets 赋值
 *
 *  @param apis
 */
- (void)addBatchAPIRequests:(nonnull NSSet *)apis;

/**
 *  开启API 请求
 */
- (void)start;

@end

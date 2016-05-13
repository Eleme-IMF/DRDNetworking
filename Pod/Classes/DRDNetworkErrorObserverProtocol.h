//
//  DRDNetworkErrorObserverProtocol.h
//  Pods
//
//  Created by 圣迪 on 16/4/13.
//
//

#import <Foundation/Foundation.h>

@protocol DRDNetworkErrorObserverProtocol <NSObject>

/**
 *  DRD发生HTTP层网络错误时，通过该函数进行监控回调
 *
 *  @param error 网络错误的Error
 */
- (void)networkErrorWithErrorInfo:(nonnull NSError *)error;

@end

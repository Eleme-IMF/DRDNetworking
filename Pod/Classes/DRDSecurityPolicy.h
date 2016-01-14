//
//  DRDSecurityPolicy.h
//  Pods
//
//  Created by 圣迪 on 16/1/8.
//
//

#import <Foundation/Foundation.h>
#import "DRDAPIDefines.h"

@interface DRDSecurityPolicy : NSObject

/**
 *  SSL Pinning证书的校验模式
 *  默认为 DRDSSLPinningModeNone
 */
@property (readonly, nonatomic, assign) DRDSSLPinningMode SSLPinningMode;

/**
 *  是否允许使用Invalid 证书
 *  默认为 NO
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 *  是否校验在证书 CN 字段中的 domain name
 *  默认为 YES
 */
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 *  创建新的SecurityPolicy
 *
 *  @param pinningMode 证书校验模式
 *
 *  @return 新的SecurityPolicy
 */
+ (instancetype)policyWithPinningMode:(DRDSSLPinningMode)pinningMode;

@end

//
//  DRDAPIDefines.h
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#ifndef DRDAPIDefines_h
#define DRDAPIDefines_h

// 网络请求类型
typedef NS_ENUM(NSUInteger, DRDRequestMethodType) {
    DRDRequestMethodTypeGET     = 0,
    DRDRequestMethodTypePOST    = 1,
    DRDRequestMethodTypeHEAD    = 2,
    DRDRequestMethodTypePUT     = 3,
    DRDRequestMethodTypePATCH   = 4,
    DRDRequestMethodTypeDELETE  = 5
};

// 请求的序列化格式
typedef NS_ENUM(NSUInteger, DRDRequestSerializerType) {
    DRDRequestSerializerTypeHTTP    = 0,
    DRDRequestSerializerTypeJSON    = 1
};

// 请求返回的序列化格式
typedef NS_ENUM(NSUInteger, DRDResponseSerializerType) {
    DRDResponseSerializerTypeHTTP    = 0,
    DRDResponseSerializerTypeJSON    = 1
};

/**
 *  SSL Pinning
 */
typedef NS_ENUM(NSUInteger, DRDSSLPinningMode) {
    /**
     *  不校验Pinning证书
     */
    DRDSSLPinningModeNone,
    /**
     *  校验Pinning证书中的PublicKey.
     *  知识点可以参考
     *  https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
     */
    DRDSSLPinningModePublicKey,
    /**
     *  校验整个Pinning证书
     */
    DRDSSLPinningModeCertificate,
};

// DRD 默认的请求超时时间
#define DRD_API_REQUEST_TIME_OUT     15
#define MAX_HTTP_CONNECTION_PER_HOST 5

#endif /* DRDAPIDefines_h */

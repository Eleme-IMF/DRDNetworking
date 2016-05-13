//
//  DRDConfig.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDConfig.h"
#import "DRDAPIDefines.h"

NSString * DRDDefaultGeneralErrorString            = @"服务器连接错误，请稍候重试";
NSString * DRDDefaultFrequentRequestErrorString    = @"Request send too fast, please try again later";
NSString * DRDDefaultNetworkNotReachableString     = @"网络不可用，请稍后重试";

@implementation DRDConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.generalErrorTypeStr                  = DRDDefaultGeneralErrorString;
        self.frequentRequestErrorStr              = DRDDefaultFrequentRequestErrorString;
        self.networkNotReachableErrorStr          = DRDDefaultNetworkNotReachableString;
        self.isNetworkingActivityIndicatorEnabled = YES;
        self.isErrorCodeDisplayEnabled            = YES;
        self.maxHttpConnectionPerHost             = MAX_HTTP_CONNECTION_PER_HOST;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    DRDConfig *config                  = [[DRDConfig allocWithZone:zone] init];
    config.generalErrorTypeStr         = self.generalErrorTypeStr;
    config.frequentRequestErrorStr     = self.frequentRequestErrorStr;
    config.networkNotReachableErrorStr = self.networkNotReachableErrorStr;
    config.isErrorCodeDisplayEnabled   = self.isErrorCodeDisplayEnabled;
    config.baseUrlStr                  = self.baseUrlStr;
    config.userAgent                   = self.userAgent;
    config.maxHttpConnectionPerHost    = self.maxHttpConnectionPerHost;
    return config;
}

@end

//
//  DRDConfig.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDConfig.h"
#import "DRDAPIDefines.h"

NSString * DRDDefaultGeneralErrorString        = @"服务器连接错误，请稍候重试";

@implementation DRDConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.generalErrorTypeStr                  = DRDDefaultGeneralErrorString;
        self.isNetworkingActivityIndicatorEnabled = YES;
        self.isErrorCodeDisplayEnabled            = YES;
        self.maxHttpConnectionPerHost             = MAX_HTTP_CONNECTION_PER_HOST;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    DRDConfig *config                = [[DRDConfig allocWithZone:zone] init];
    config.generalErrorTypeStr       = self.generalErrorTypeStr;
    config.isErrorCodeDisplayEnabled = self.isErrorCodeDisplayEnabled;
    config.baseUrlStr                = self.baseUrlStr;
    config.userAgent                 = self.userAgent;
    config.maxHttpConnectionPerHost  = self.maxHttpConnectionPerHost;
    return config;
}

@end

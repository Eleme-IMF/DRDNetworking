//
//  DRDConfig.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDConfig.h"

NSString * DRDDefaultGeneralErrorString = @"服务器连接错误，请稍候重试";

@implementation DRDConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.generalErrorTypeStr                  = DRDDefaultGeneralErrorString;
        self.isNetworkingActivityIndicatorEnabled = YES;
        self.isErrorCodeDisplayEnabled            = YES;
    }
    return self;
}

@end

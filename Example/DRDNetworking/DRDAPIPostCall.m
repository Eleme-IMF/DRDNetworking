//
//  DRDAPIPostCall.m
//  Durandal
//
//  Created by dev-aozhimin on 15/12/22.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDAPIPostCall.h"

@implementation DRDAPIPostCall

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - DRD
- (NSString *)customRequestUrl {
    return @"http://upload.qiniu.com";
}

- (NSString *)requestMethod {
    return nil;
}

- (id)requestParameters {
    return nil;
}

- (DRDRequestMethodType)apiRequestMethodType {
    return DRDRequestMethodTypePOST;
}

@end

//
//  DRDAPIGetCall.m
//  Durandal
//
//  Created by 圣迪 on 15/12/11.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDAPIGetCall.h"

@implementation DRDAPIGetCall

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - DRD
- (NSString *)requestMethod {
    return @"get";
}

- (id)requestParameters {
    return nil;
}

- (DRDRequestMethodType)apiRequestMethodType {
    return DRDRequestMethodTypeGET;
}

- (DRDRequestSerializerType)apiRequestSerializerType {
    return DRDRequestSerializerTypeHTTP;
}

- (DRDResponseSerializerType)apiResponseSerializerType {
    return DRDResponseSerializerTypeHTTP;
}

@end

//
//  DRDAPIPutCall.m
//  Durandal
//
//  Created by dev-aozhimin on 15/12/11.
//  Copyright © 2015年 cendywang. All rights reserved.
//

#import "DRDAPIPutCall.h"

@implementation DRDAPIPutCall

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - DRD
- (NSString *)requestMethod {
    return @"user-agent";
}

- (id)requestParameters {
    return nil;
}

- (DRDRequestMethodType)apiRequestMethodType {
    return DRDRequestMethodTypeGET;
}

@end

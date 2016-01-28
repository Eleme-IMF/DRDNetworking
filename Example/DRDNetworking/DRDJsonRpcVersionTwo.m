//
//  DRDJsonRpcVersionTwo.m
//  Pods
//
//  Created by 圣迪 on 16/1/13.
//
//

#import "DRDJsonRpcVersionTwo.h"
#import "DRDBaseAPI.h"

static DRDJsonRpcVersionTwo *sharedInstance = nil;

@implementation DRDJsonRpcVersionTwo

+ (instancetype)sharedJsonRpcVersionTwo {
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[DRDJsonRpcVersionTwo alloc] init];
        });
    }
    return sharedInstance;
}

#pragma mark - Protocol RPC
- (NSString *)rpcRequestUrlWithAPI:(DRDBaseAPI *)api {
    if (api.customRequestUrl) {
        return api.customRequestUrl;
    } else {
        return api.baseUrl;
    }
}

- (id)rpcRequestParamsWithAPI:(DRDBaseAPI *)api {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"jsonrpc"]          = @"2.0";
    dic[@"id"]   = [[[NSUUID UUID] UUIDString] lowercaseString];
    if ([api requestMethod]) {
        dic[@"method"] = [api requestMethod];
    }
    if ([api requestParameters]) {
        dic[@"params"] = [api requestParameters];
    }
    
    NSDictionary *apiAdditionalParams = [api apiAddtionalRPCParams];
    [apiAdditionalParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        [dic setObject:obj forKey:key];
    }];
    return [dic copy];
}

- (id)rpcResponseObjReformer:(id)responseObject {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [((NSDictionary *)responseObject) enumerateKeysAndObjectsWithOptions:NSEnumerationReverse
                                                              usingBlock:^(id key, id obj, BOOL * stop) {
                                                                  if ([key isEqualToString:@"result"] ||
                                                                      [key isEqualToString:@"error"]) {
                                                                      if (obj && ![obj isEqual:[NSNull null]]) {
                                                                          dic[key] = obj;
                                                                      } else {
                                                                          dic[key] = [NSNull null];
                                                                      }
                                                                  }
                                                              }];
    return [dic copy];

}

- (id)rpcResultWithFormattedResponse:(id)formattedResponseObj {
    return [((NSDictionary *)formattedResponseObj) objectForKey:@"result"];
}

// 如果需要对某些错误进行统一处理，可以在本方法中进行处理
- (NSError *)rpcErrorWithFormattedResponse:(id)formattedResponseObj {
    id errorInfo = [((NSDictionary *)formattedResponseObj) objectForKey:@"error"];
    if (errorInfo && ![errorInfo isEqual:[NSNull null]]) {
        return errorInfo;
    } else {
        return nil;
    }
}

@end

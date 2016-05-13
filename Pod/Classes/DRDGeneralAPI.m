//
//  DRDGeneralAPI.m
//  Pods
//
//  Created by 圣迪 on 15/12/10.
//
//

#import "DRDGeneralAPI.h"

@implementation DRDGeneralAPI

#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        // 继承DRDBaseAPI 默认值
        self.apiRequestMethodType              = [super apiRequestMethodType];
        self.apiRequestSerializerType          = [super apiRequestSerializerType];
        self.apiResponseSerializerType         = [super apiResponseSerializerType];
        self.apiRequestCachePolicy             = [super apiRequestCachePolicy];
        self.apiRequestTimeoutInterval         = [super apiRequestTimeoutInterval];
        self.apiRequestHTTPHeaderField         = [super apiRequestHTTPHeaderField];
        self.apiResponseAcceptableContentTypes = [super apiResponseAcceptableContentTypes];
        self.apiSecurityPolicy                 = [super apiSecurityPolicy];
        self.apiAddtionalRPCParams             = [super apiAddtionalRPCParams];
        self.apiAddtionalRequestFunction       = [super apiAddtionalRequestFunction];
        self.customRequestUrl                  = [super customRequestUrl];
    }
    return self;
}

- (instancetype)initWithRequestMethod:(NSString *)requestMethod {
    if (self = [self init]) {
        self.requestMethod = requestMethod;
    }
    return self;
}

- (void)apiRequestWillBeSent {
    if (self.apiRequestWillBeSentBlock) {
        self.apiRequestWillBeSentBlock();
    }
}

- (void)apiRequestDidSent {
    if (self.apiRequestDidSentBlock) {
        self.apiRequestDidSentBlock();
    }
}

- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error {
    if (self.objReformerDelegate) {
        return [self.objReformerDelegate apiResponseObjReformerWithGeneralAPI:self
                                                            andResponseObject:responseObject
                                                                     andError:error];
    }
    
    if (self.apiResponseObjReformerBlock) {
        return self.apiResponseObjReformerBlock(responseObject, error);
    }
    
    return responseObject;
}

@end

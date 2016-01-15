# DurandalNetworking
[![CI Status](http://img.shields.io/travis/Eleme-IMF/DurandalNetworking.svg?style=flat)](https://travis-ci.org/Eleme-IMF/DurandalNetworking)
[![Version](https://img.shields.io/cocoapods/v/DurandalNetworking.svg?style=flat)](http://cocoapods.org/pods/DurandalNetworking)
[![License](https://img.shields.io/cocoapods/l/DurandalNetworking.svg?style=flat)](http://cocoapods.org/pods/DurandalNetworking)
[![Platform](https://img.shields.io/cocoapods/p/DurandalNetworking.svg?style=flat)](http://cocoapods.org/pods/DurandalNetworking)

DurandalNetworking is a delightful networking library which provide you a convenient way to handle API request, it has no invasion to your project, you won't get into trouble when you remove it one day, even though that's not what I want to see. Currently, we are using AFNetworking Session Manager. However, we have decoupled with AFNetworking, so you never mind have a dependence on AFNetworking.

In DurandalNetworking, documentation and example is complete. You won't have any obstacles in use. 
Last, but not least, a man's power is always limited. Join us, enpower DurandalNetworking!

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### DRDAPIManager

`DRDAPIManager` manages `DRDBaseAPI` object,  which conforms to `<DRDAPI>`protocol. You can send an API request or a batch of API requests. Furthermore, you can cancel an API request which you sent before.

#### config
```objective-c

    DRDConfig *networkConfig   = [[DRDConfig alloc] init];
    networkConfig.baseUrlStr   = @"https://httpbin.org";
    networkConfig.userAgent    = @"For example User-Agent";

    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:networkConfig];
```
#### send a batch of API requests
```objective-c

    DRDGeneralAPI *generalAPIGet = [[DRDGeneralAPI alloc] init];
    generalAPIGet.apiRequestMethodType = DRDRequestMethodTypeGET;
    generalAPIGet.baseUrl = self.baseURLStr;
    
    DRDGeneralAPI *generalAPIPost = [[DRDGeneralAPI alloc] init];
    generalAPIPost.apiRequestMethodType = DRDRequestMethodTypePOST;
    generalAPIPost.baseUrl = self.baseURLStr;
    
    DRDAPIBatchAPIRequests *batchRequests = [[DRDAPIBatchAPIRequests alloc] init];
    [batchRequests addAPIRequest:generalAPIGet];
    [batchRequests addAPIRequest:generalAPIPost];
    
    [[DRDAPIManager sharedDRDAPIManager] sendBatchAPIRequests:batchRequests];
```
### DRDBaseAPI

`DRDBaseAPI` is base class of all API request object. You will customize your API request by subclass of it.

```objective-c

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
    return @"http://httpbin.org";
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

- (id)apiResponseObjReformer:(id)responseObject andError:(NSError *)error {
    // refrom JSON response to your model object
    return responseObject;
}
```
### DRDGeneralAPI

`DRDGeneralAPI` avoid subclass of `DRDBaseAPI` which will lead to class explosion. It provide you a convenient way to send API request. 

```objective-c
    DRDGeneralAPI *apiGeGet            = [[DRDGeneralAPI alloc] initWithRequestMethod:@"get"];
    apiGeGet.apiRequestMethodType      = DRDRequestMethodTypeGET;
    apiGeGet.apiRequestSerializerType  = DRDRequestSerializerTypeHTTP;
    apiGeGet.apiResponseSerializerType = DRDResponseSerializerTypeHTTP;
    [apiGeGet setApiCompletionHandler:^(id responseObject, NSError * error) {
        NSLog(@"responseObject is %@", responseObject);
        if (error) {
            NSLog(@"Error is %@", error.localizedDescription);
        }
    }];
    [apiGeGet start];
```

### DRDRPCProtocol

`DRDRPCProtocol` defines JSON-RPC protocol, if remote service confrom JSON-RPC protocol, you can implement it.

```objective-c
    DRDGeneralAPI *plusAPI = [[DRDGeneralAPI alloc]init];
    plusAPI.baseUrl        = @"http://www.raboof.com/projects/jayrock/demo.ashx?test";
    plusAPI.requestMethod  = @"add";
    plusAPI.requestParameters = @{
                                  @"a" : @(a),
                                  @"b" : @(b)
                                  };
    plusAPI.rpcDelegate    = [DRDJsonRpcVersionTwo sharedJsonRpcVersionTwo];
    __weak typeof(self) weakSelf = self;
    [plusAPI setApiCompletionHandler:^(NSNumber * responseObject, NSError * error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:[NSString stringWithFormat:@"%@", error.localizedDescription]
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil]show];
        } else {
            weakSelf.labelResult.text = [NSString stringWithFormat:@"%@", responseObject];
        }
    }];
    [plusAPI start];
```

## Requirements
* ios 7.0+  
* AFNetworking 3.0.1+  
  
## ChangeLog
### v0.4.0
* Project Init

## Installation

DurandalNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DurandalNetworking"
```

## Author

cendywang, cendymails@gmail.com

## License

DurandalNetworking is available under the MIT license. See the LICENSE file for more info.

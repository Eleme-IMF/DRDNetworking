# DRDNetworking
[![CI Status](http://img.shields.io/travis/Eleme-IMF/DRDNetworking.svg?style=flat)](https://travis-ci.org/Eleme-IMF/DRDNetworking)
[![codecov.io](https://codecov.io/github/Eleme-IMF/DRDNetworking/coverage.svg?branch=master)](https://codecov.io/github/Eleme-IMF/DRDNetworking?branch=master)
[![Version](https://img.shields.io/cocoapods/v/DRDNetworking.svg?style=flat)](http://cocoapods.org/pods/DRDNetworking)
[![License](https://img.shields.io/cocoapods/l/DRDNetworking.svg?style=flat)](http://cocoapods.org/pods/DRDNetworking)
[![Platform](https://img.shields.io/cocoapods/p/DRDNetworking.svg?style=flat)](http://cocoapods.org/pods/DRDNetworking)

DRDNetworking is a delightful networking library which provide you a convenient way to handle API request, it has no invasion to your project, you won't get into trouble when you remove it one day, even though that's not what I want to see. Currently, we are using AFNetworking 3.0.0+ with Session Manager.  
DRDNetworking compatible with `RESTFUL API` and `JSON-RPC API`. If you needs to support with your own `JSON Based RPC Call`, just a few lines of code needed!  
More detail, please run the Example project in the repo.

## Usage
---------
## Installation

DRDNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DRDNetworking"
```
### Run Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Quick Start
* In your podfile, just add `pod 'DRDNetworking`, then `pod update`.
* In your project file where you want to use DRDNetworking, add `#import "DRDNetworking.h"`
* Write api code to run a networking call:

```
DRDGeneralAPI *apiGet = [[DRDGeneralAPI alloc] init];
apiGet.baseUrl        = @"http://ele.me";
[apiGet setApiCompletionHandler:^(id responseObject, NSError * error) {
    // Your handle code
}];
[apiGet start];
 ```  
  
### CodeDetail
--------------

###### DRDAPIManager

`DRDAPIManager` manages `DRDBaseAPI` object,  which conforms to `<DRDAPI>`protocol. You can send an API request or a batch of API requests. Furthermore, you can cancel an API request which you sent before.

###### DRDConfig  
`DRDConfig` is a global class that help us to maintain the whole behaviors.  

```
    DRDConfig *networkConfig   = [[DRDConfig alloc] init];
    networkConfig.baseUrlStr   = @"https://httpbin.org";
    networkConfig.userAgent    = @"For example User-Agent";

    [[DRDAPIManager sharedDRDAPIManager] setConfiguration:networkConfig];
```    
###### DRDAPIBatchAPIRequests      

If you need to send a batch of api simultaneously, use `DRDAPIBatchAPIRequests`

```
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

###### DRDBaseAPI

`DRDBaseAPI` is base class of all API request object. You will customize your API request by subclass of it.

```
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
######  DRDGeneralAPI

`DRDGeneralAPI` avoid subclass of `DRDBaseAPI` which will lead to class explosion. It provide you a convenient way to send API request. 

```
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

###### DRDRPCProtocol
`DRDRPCProtocol` is the way that where you could implements your custome `JSON Based RPC Protocol`. We already implemented `JSON-RPC protocol` in the Example.   
Review it, and write your own protocol.

```
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
* iOS 7.0+  
* Objective-C 2.0
* AFNetworking 3.0.0+  
  
## ChangeLog
### v0.5.0  
* Reuse one session for same base url requests to reuse TCP/IP connection
* More convenience API design
* More unit testing for code coverage

### v0.4.0
* Project Init

## Author

cendywang, cendymails@gmail.com

## License

DRDNetworking is available under the MIT license. See the LICENSE file for more info.

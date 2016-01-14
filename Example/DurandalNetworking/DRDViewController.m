//
//  DRDViewController.m
//  Durandal
//
//  Created by cendywang on 12/10/2015.
//  Copyright (c) 2015 cendywang. All rights reserved.
//

#import "DRDViewController.h"
#import "DRDAPIGetCall.h"
#import "DRDAPIPutCall.h"
#import "DRDGeneralAPI.h"
#import "DRDAPIPostCall.h"
#import "DurandalNetworking.h"

@interface DRDViewController ()<DRDAPIBatchAPIRequestsProtocol>
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *rpcCallLabel;

@property (nonatomic, strong) DRDAPIPutCall *apiPut;
@end

@implementation DRDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClicked:(UIButton *)sender {
    sender.enabled = NO;
    __weak typeof(self) weakSelf       = self;
    self.label.text = @"正在发送";

    // Use GeneralAPI
    DRDGeneralAPI *apiGeGet            = [[DRDGeneralAPI alloc] initWithRequestMethod:@"get"];
    apiGeGet.apiRequestMethodType      = DRDRequestMethodTypeGET;
    apiGeGet.apiRequestSerializerType  = DRDRequestSerializerTypeHTTP;
    apiGeGet.apiResponseSerializerType = DRDResponseSerializerTypeHTTP;
    [apiGeGet setApiCompletionHandler:^(id responseObject, NSError * error) {
        NSLog(@"responseObject is %@", responseObject);
        if (error) {
            NSLog(@"Error is %@", error.localizedDescription);
        }
        sender.enabled = YES;
        weakSelf.label.text = @"发送成功";
    }];
    [apiGeGet start];
    
    DRDAPIGetCall *apiGet = [[DRDAPIGetCall alloc] init];
    [apiGet setApiCompletionHandler:^(id responseObject, NSError * error) {
        NSLog(@"responseObject is %@", responseObject);
        if (error) {
            NSLog(@"Error is %@", error.localizedDescription);
        }
        sender.enabled = YES;
        weakSelf.label.text = @"发送成功";
    }];
    [apiGet start];

    self.apiPut = [[DRDAPIPutCall alloc] init];
    [self.apiPut setApiCompletionHandler:^(id responseObject, NSError * error) {
        NSLog(@"responseObject is %@", responseObject);
        if (error) {
            NSLog(@"Error is %@", error.localizedDescription);
        }
    }];
    [self.apiPut start];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.apiPut cancel];
}

- (IBAction)postImageButtonClicked:(id)sender {
    DRDAPIPostCall *apiPost = [[DRDAPIPostCall alloc] init];
    [apiPost setApiCompletionHandler:^(id responseObject, NSError * error) {
    }];
    [apiPost setApiRequestConstructingBodyBlock:^(id <DRDMultipartFormData>formData) {
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"test"]);
        [formData appendPartWithFileData:imageData
                                    name:@"pictures"
                                fileName:@"test"
                                mimeType:@"image/jpeg"];
        
    }];
    [apiPost setApiProgressBlock:^(NSProgress * progress) {
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }];
    [apiPost start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = object;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{    
            weakSelf.label.text = [NSString stringWithFormat:@"上传进度: %f", progress.fractionCompleted];
        });
    }
}

- (IBAction)batchSendBtnClicked:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    
    DRDGeneralAPI *apiGet1       = [[DRDGeneralAPI alloc] initWithRequestMethod:@""];
    apiGet1.baseUrl              = @"http://httpbin.org/get";
    apiGet1.apiRequestMethodType = DRDRequestMethodTypeGET;
    [apiGet1 setApiCompletionHandler:^(id responseObject, NSError * error) {
        weakSelf.label.text = @"Batch call ONE finished!";
    }];
    
    DRDGeneralAPI *apiPost2      = [[DRDGeneralAPI alloc] initWithRequestMethod:@""];
    apiPost2.baseUrl             = @"http://httpbin.org/post";
    apiPost2.apiRequestMethodType = DRDRequestMethodTypePOST;
    [apiPost2 setApiCompletionHandler:^(id responseObject, NSError * error) {
        weakSelf.label.text = @"Batch call TWO finished!";
    }];
    
    DRDAPIBatchAPIRequests *apiBatchApis = [[DRDAPIBatchAPIRequests alloc]init];
    [apiBatchApis addAPIRequest:apiGet1];
    [apiBatchApis addAPIRequest:apiPost2];
    apiBatchApis.delegate = self;
    [apiBatchApis start];
}

- (void)batchAPIRequestsDidFinished:(DRDAPIBatchAPIRequests *)batchApis {
    self.label.text = @"Batch Send Completed";
}

@end

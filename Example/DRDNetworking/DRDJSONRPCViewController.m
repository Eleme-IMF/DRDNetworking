//
//  DRDJSONRPCViewController.m
//  DurandalNetworking
//
//  Created by 圣迪 on 16/1/14.
//  Copyright © 2016年 cendywang. All rights reserved.
//

#import "DRDJSONRPCViewController.h"
#import "DRDGeneralAPI.h"
#import "DRDJsonRpcVersionTwo.h"

@interface DRDJSONRPCViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textA;
@property (weak, nonatomic) IBOutlet UITextField *textB;
@property (weak, nonatomic) IBOutlet UILabel *labelResult;

@end

@implementation DRDJSONRPCViewController
#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= 6)
        return NO; // return NO to not change text
    return YES;
}

#pragma mark -
- (IBAction)computeBtnClicked:(UIButton *)sender {
    if ([self.textA.text isEqualToString:@""] ||
        [self.textB.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Enter A or B"
                                    message:@"To Compute A + B, please enter the numbers"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil]show];
    } else {
        NSUInteger a = [self.textA.text integerValue];
        NSUInteger b = [self.textB.text integerValue];
        [self computePlusWithA:a andB:b];
    }
}

- (void)computePlusWithA:(NSUInteger)a andB:(NSUInteger)b {
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
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapGestr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap)];
    [self.view addGestureRecognizer:tapGestr];
}

- (void)viewTap {
    [self.textA resignFirstResponder];
    [self.textB resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

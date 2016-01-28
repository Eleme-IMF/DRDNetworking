//
//  DRDJsonRpcVersionTwo.h
//  Pods
//
//  Created by 圣迪 on 16/1/13.
//
//

#import <Foundation/Foundation.h>
#import "DRDRPCProtocol.h"

@interface DRDJsonRpcVersionTwo : NSObject<DRDRPCProtocol>

+ (nullable instancetype)sharedJsonRpcVersionTwo;

@end

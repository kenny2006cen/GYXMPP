//
//  VhAPConfigEnDecoder.h
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/6.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMAPConfigMsg.h"
@interface HMAPConfigEnDecoder : NSObject

@property (nonatomic, strong) NSMutableData * leftData;


+ (instancetype)defaultEnDecoder;

- (NSData *)encoderWithMsg:(HMAPConfigMsg *)msg;
- (NSMutableArray *)decoderWithData:(NSData *)data;
@end

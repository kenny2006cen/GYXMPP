//
//  HMChannel.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMChannel : HMBaseModel

@property (copy,nonatomic) NSString * channelName;
@property (copy,nonatomic) NSString * channelNamePinYin;
@property (assign,nonatomic) int type;
@property (assign,nonatomic)  int sequence;

+ (NSMutableArray *)allChannel;
+ (BOOL)deleteAllChannel;
@end

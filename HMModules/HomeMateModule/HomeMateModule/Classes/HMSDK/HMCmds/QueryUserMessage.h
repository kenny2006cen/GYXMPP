//
//  HMQueryUserMessage.h
//  HomeMateSDK
//
//  Created by user on 16/10/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryUserMessage : BaseCmd

@property (nonatomic, copy)NSString * familyId;


@property (nonatomic, copy)NSString * userId;

@property (nonatomic, copy)NSString * tableName;

// 当获取歌曲列表时，这里填同一个歌曲列表中已获取到歌曲的任意歌曲id。用于给设备区分判断是否获取同一个歌曲列表。
@property (nonatomic, copy)NSString * dataFlag;


@property (nonatomic, assign)int minSequence;

@property (nonatomic, assign)int maxSequence;

@property (nonatomic, assign)int readCount;

@property (nonatomic, assign)int type;

@end

//
//  HMQueryDeviceDataCmd.h
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/10/25.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMQueryDeviceDataCmd : BaseCmd

@property (nonatomic, copy)NSString * familyId;


@property (nonatomic, copy)NSString * userId;

// 当tableName为song时， 0 表示获取本地歌曲 1 收藏歌曲列表 2 当前播放歌曲列表
@property (nonatomic, assign)int type;

//// 当获取歌曲列表时，这里填同一个歌曲列表中已获取到歌曲的任意歌曲id。用于给设备区分判断是否获取同一个歌曲列表。
@property (nonatomic, copy)NSString * dataFlag;

@property (nonatomic, copy)NSString * tableName;

@property (nonatomic, assign)int pageIndex; // 页数，从1开始

@property (nonatomic, assign)int readCount; // 读取的数据条数，默认20条，最多50条


@end

NS_ASSUME_NONNULL_END

//
//  HMAMapTip.h
//  HomeMateSDK
//
//  Created by peanut on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAMapTip : HMBaseModel

///名称
@property (nonatomic, copy) NSString *name;
///区域编码
@property (nonatomic, copy) NSString *adcode;
///所属区域
@property (nonatomic, copy) NSString *district;
///地址
@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *typecode;
///纬度（垂直方向）
@property (nonatomic, assign) CGFloat latitude;
///经度（水平方向）
@property (nonatomic, assign) CGFloat longitude;


+ (NSMutableArray *)allTips;

@end

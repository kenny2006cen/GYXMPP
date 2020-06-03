//
//  HMStorageClass.h
//  HomeMateSDK
//
//  Created by Air on 16/3/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//


#import "SingletonClass.h"


@class SingletonClass;
@protocol HMBusinessProtocol;


@interface HMStorage : SingletonClass

@property (nonatomic,assign)BOOL enableLog;
@property (nonatomic,strong)NSString * appName;
@property (nonatomic,strong)NSString * deviceToken;
@property (nonatomic,strong)NSString * descSource;
@property (nonatomic,strong)NSString * ssid;    // 上次配置设备时发送的ssid
@property (nonatomic,strong)NSNumber * specifiedIdc; // 指定idc，在指定了idc情况下，不再动态从账号表查找，直接使用指定值

@property (nonatomic,strong)NSMutableDictionary * hmCacheDic; // 通用的缓存结果字典，用于缓存频繁调用的函数的返回结果。注意key值要带前缀

@property (nonatomic, weak) id <HMBusinessProtocol> delegate;


//自动登录的情况下，用户上一次的家庭数量，如果 > 0，先显示首页，如果等于0则应显示无家庭的页面
@property (nonatomic,assign)NSUInteger lastFamilyCount;

// 点击通知栏启动【或者点击通知栏从后台回前台】时，如果通知属于另外一个家庭，则在自动登录完成后执行此数组中的task
// 目前设计的业务为，自动登录完成后切换到通知消息对应的家庭中去
@property (nonatomic, strong) NSMutableArray * taskArray;

@end

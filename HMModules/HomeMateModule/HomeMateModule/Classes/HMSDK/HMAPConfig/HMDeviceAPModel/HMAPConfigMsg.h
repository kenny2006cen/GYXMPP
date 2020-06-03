//
//  VhAPConfigMsg.h
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/6.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMAPConfigCallback.h"
#import "HMTypes.h"

typedef NS_ENUM(int , VhAPConfigCmd){
    VhAPConfigCmd_DeviceInfo = 79,
    VhAPConfigCmd_WIFIList = 80,
    VhAPConfigCmd_SetWifi = 81,
    
    /**
     *  3.4.64本地测量模式接口,
     */
    VhAPConfigCmd_LocalMeasurement = VIHOME_CMD_LOCAL_MEASUREMENT,
    /**
     *  3.6.23传感器数据上报接口
     */
    VhAPConfigCmd_SENSOR_DATA_REPORT = VIHOME_SENSOR_DATA_REPORT,
    
    /**
     *  3.5.14	AP配置剩余时间上报接口
     */
    VhAPConfigCmd_REMAIN_TIME = VIHOME_CMD_REMAIN_TIME,
    
    

    VhAPConfigCmd_Quit_AP = VIHOME_CMD_Quit_AP,// 退出AP模式
    VhAPConfigCmd_LOCK_GETUSERINFO = VIHOME_CMD_AP_LOCK_GETUSERINFO, // 获取成员信息
    VhAPConfigCmd_LOCK_ADDUSER = VIHOME_CMD_AP_LOCK_ADDUSER, // 增加成员
    VhAPConfigCmd_LOCK_DELETEUSER = VIHOME_CMD_AP_LOCK_DELETEUSER,// 删除成员
    VhAPConfigCmd_LOCK_ADDUSERKEY = VIHOME_CMD_AP_LOCK_ADDUSERKEY,// 添加用户验证信息
    VhAPConfigCmd_LOCK_DELETEUSERKEY = VIHOME_CMD_AP_LOCK_DELETEUSERKEY,// 删除用户验证信息
    VhAPConfigCmd_LOCK_CANCELADDFP = VIHOME_CMD_AP_LOCK_CANCELADDFP,// 取消指纹录入
    VhAPConfigCmd_CANCELADDRF = VIHOME_CMD_AP_LOCK_CANCELADDRF,// 取消RF卡录入
    VhAPConfigCmd_LOCK_GETOPENRECORD = VIHOME_CMD_AP_LOCK_GETOPENRECORD,// 读取开锁记录
    VhAPConfigCmd_LOCK_STOPGETOPENRECORD = VIHOME_CMD_AP_LOCK_STOPGETOPENRECORD,// 停止读取开锁记录
    VhAPConfigCmd_LOCK_SETVOLUME = VIHOME_CMD_AP_LOCK_SETVOLUME,// 设置音量大小
    VhAPConfigCmd_LOCK_ADDFPREPORT = VIHOME_CMD_AP_LOCK_ADDFPREPORT,// 录入新指纹主动上报
    VhAPConfigCmd_LOCK_ADDRFREPORT = VIHOME_CMD_AP_LOCK_ADDRFREPORT,// 录入新RF卡主动上报
    VhAPConfigCmd_LOCK_DELETEFPREPORT = VIHOME_CMD_AP_LOCK_DELETEFPREPORT,// 删除指纹主动上报
    VhAPConfigCmd_LOCK_ASYNUSERINFO = VIHOME_CMD_AP_LOCK_ASYNUSERINFO,// 同步用户信息


} ;


/**
 一条消息从 发送 到 响应/超时 的生命周期结构体
 */
@interface HMAPConfigMsg : NSObject
@property (nonatomic, assign) VhAPConfigCmd cmd;
@property (nonatomic, strong) NSDictionary * msgBody;
@property (nonatomic, assign) id <HMAPConfigCallback> callback;

/**
 发出请求的开始时间戳，用于超时；由超时管理器操作它；
 */
@property (nonatomic, strong) NSDate* startTimestamp;

/**
 请求超时秒数
 */
@property (nonatomic, assign) NSInteger timeoutSeconds;

/**
 *	@brief	设置超时起始时间
 */
-(void)startTimeout;

/**
 *	@brief	获得超时起始时间
 *
 *	@return 起始时间
 */
-(NSDate*)getStartTime;

/**
 *	@brief	获得设定的超时时间
 *
 *	@return	超时时间（s）
 */
-(NSInteger)getTimeoutTime;

/**
 超时时执行
 */
- (void)doTimeout;
@end

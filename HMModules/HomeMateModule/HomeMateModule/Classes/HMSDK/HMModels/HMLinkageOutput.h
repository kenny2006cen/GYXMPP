//
//  VihomeLinkageOutput.h
//  HomeMate
//
//  Created by Air on 15/8/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMScene.h"

@class HMDevice;
@class HMLinkage;

@interface HMLinkageOutput : HMBaseModel <SceneEditProtocol>

/**
 *  主键 UUID
 */
@property (nonatomic, retain)NSString *          linkageOutputId;

/**
 *  外键
 */
@property (nonatomic, retain)NSString *          linkageId;

/**
 *  联动的设备编号
 */
@property (nonatomic, retain)NSString *        deviceId;

/**
 *  布防联动设备的控制指令
 */
@property (nonatomic, retain)NSString *         bindOrder;
/**
 *  布防联动设备的控制值
 */
@property (nonatomic, assign)int                value1;
@property (nonatomic, assign)int                value2;
@property (nonatomic, assign)int                value3;
@property (nonatomic, assign)int                value4;
@property (nonatomic, assign)int                delayTime;
@property (nonatomic, assign)int                outputType;

@property (nonatomic, strong) NSString *       actionName;
@property (nonatomic, assign) int freq;
@property (nonatomic, assign) int pluseNum;
@property (nonatomic, copy) NSString * pluseData;

// 幻彩灯带用到
@property (nonatomic, copy) NSString * themeId;
@property (nonatomic, copy) NSString * outPutTagId;
@property (nonatomic, assign) int outPutTag;

/**
 *  非协议字段
 */
@property (nonatomic, retain)NSString *         deviceName;
@property (nonatomic, assign)KDeviceType        deviceType;
@property (nonatomic, assign)int                subDeviceType; //设备子类型(传感器接入模块)
@property (nonatomic, assign)KDeviceID          appDeviceId;
@property (nonatomic, retain)NSString *         model;
@property (nonatomic, retain)NSString *         company;// 厂商
@property (nonatomic, retain)NSString *         extAddr;
@property (nonatomic, assign)int                endPoint;
@property (nonatomic, retain)NSString *         floorRoom;
@property (nonatomic, retain)NSString *         roomId;
@property (nonatomic, assign) BOOL              selected;
@property (nonatomic, assign,readonly) BOOL              isLearnedIR;
@property (nonatomic, assign,readonly) BOOL     changed;

// 新增需求：自定义通知 有权限的用户
@property (nonatomic, strong,readonly)NSString * authMember; // 根据authList拼接出来的结果，只读
@property (nonatomic, strong)NSArray *           authList;   // 有权限的家庭成员，存储[HMFamilyUsers]对象

+ (instancetype)deviceObject:(FMResultSet *)rs;

// 情景编辑设备时使用
+ (instancetype)bindObject:(FMResultSet *)rs;

// 组
+ (instancetype)bindGroupObject:(FMResultSet *)rs;

/**
 根据 device 初始化对象
 */
+ (instancetype)objectWithDevice:(HMDevice *)device;

/**
 根据 scene 初始化对象
 */
+ (instancetype)objectWithScene:(HMScene *)scene;

/**
 根据 linkage 初始化对象
 */
+ (instancetype)objectWithLinkage:(HMLinkage *)linkage;


+ (void)deleteObjectWithLinkageOutputId:(NSString *)linkageOutputId;

/**
 设备删除后，删除对应deviceId
 */
+ (void)deleteOutputWithDeviceId:(NSString *)deviceId;


-(void)copyInitialValue;

/** 此数据初始从本地数据库查询，每次进入编辑页时重新在服务器查询，查询正确数据后更新 authList 与 initialAuthList */
-(void)updateAuthList:(NSArray *)list;

/** 移除已不在此家庭的成员，更新 authList 与 initialAuthList*/
-(NSArray *)removeExitMemberList:(NSArray *)list;

@end

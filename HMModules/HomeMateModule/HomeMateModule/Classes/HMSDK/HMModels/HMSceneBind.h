//
//  VihomeSceneBind.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMConstant.h"

@interface HMSceneBind : HMBaseModel <SceneEditProtocol>

@property (nonatomic, strong)NSString *        sceneBindId;

@property (nonatomic, strong)NSString *        sceneNo;

@property (nonatomic, strong)NSString *        deviceId;

@property (nonatomic, strong)NSString *         bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;

@property (nonatomic, assign)int                delayTime;

@property (nonatomic, assign)int                sceneBindTag;//绑定输出标识 1 为组
@property (nonatomic, strong)NSString *         sceneBindTagId;//绑定输出标识Id

// 小方以及Allone Pro 创建的虚拟红外设备才有的字段
@property (nonatomic, assign) int freq;
@property (nonatomic, assign) int pluseNum;
@property (nonatomic, copy) NSString * pluseData;
@property (nonatomic, strong) NSString * actionName;
@property (nonatomic, copy) NSString * irDeviceId;
// 幻彩灯带用到
@property (nonatomic, copy) NSString * themeId;

// 非数据库存储字段，根据编程需要，在查询数据时联合查询出设备楼层和名字

@property (nonatomic, strong)NSString *         deviceName;
@property (nonatomic, strong)NSString *         floorRoom;
@property (nonatomic, strong)NSString *         extAddr;
@property (nonatomic, assign)int                endPoint;
@property (nonatomic, assign)KDeviceType        deviceType;
@property (nonatomic, assign)int                subDeviceType; //设备子类型(传感器接入模块)
@property (nonatomic, assign)KDeviceID          appDeviceId;
@property (nonatomic, strong)NSString *         model;
@property (nonatomic, strong)NSString *         roomId;
@property (nonatomic, strong)NSString *         company;

@property (nonatomic, assign)int                ItemId;

@property (nonatomic, assign) BOOL                selected;

@property (nonatomic, assign,readonly) BOOL       isLearnedIR;

@property (nonatomic, assign,readonly) BOOL       changed;

// 新增需求：自定义通知 有权限的用户
@property (nonatomic, strong,readonly)NSString * authMember; // 根据authList拼接出来的结果，只读
@property (nonatomic, strong)NSArray *           authList;   // 有权限的家庭成员，存储[HMFamilyUsers]对象

/** 此数据初始从本地数据库查询，每次进入编辑页时重新在服务器查询，查询正确数据后更新 authList 与 initialAuthList */
-(void)updateAuthList:(NSArray *)list;

/** 移除已不在此家庭的成员，更新 authList 与 initialAuthList*/
-(NSArray *)removeExitMemberList:(NSArray *)list;

-(void)copyObj:(HMSceneBind *)obj;

- (NSMutableDictionary *)dictionWithSceneBindObject;

// 选择绑定设备时使用
+ (instancetype)deviceObject:(FMResultSet *)rs;

/**
 根据 device 初始化对象
 */
+ (instancetype)objectWithDevice:(HMDevice *)device;

// 情景编辑设备时使用
+ (instancetype)bindObject:(FMResultSet *)rs;

+ (instancetype)bindGroupObject:(FMResultSet *)rs;

+ (instancetype)objectWithUID:(NSString *)uid deviceID:(NSString *)deviceId;

- (void)setBindWithDevice:(HMDevice *)device;

+ (instancetype)objectWithLinkageOutput:(HMLinkageOutput *)output;
@end

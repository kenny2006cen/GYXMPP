//
//  DBModel.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMTypes.h"
#import "FMDatabase.h"


@protocol HMDeviceProtocol

@optional

@property (nonatomic, strong) NSString *       actionName;
@property (nonatomic, copy) NSString *       themeId;

@property (nonatomic, strong)NSString *          uid;
@property (nonatomic, strong)NSString *          deviceId;
@property (nonatomic, strong)NSString *          deviceName;
@property (nonatomic, strong)NSString *          roomId;
@property (nonatomic, strong)NSString *          model;         // 设备的model
@property (nonatomic, retain)NSString *          company;       // 厂商
@property (nonatomic, assign)KDeviceType         deviceType;
@property (nonatomic, assign)int                 subDeviceType; //设备子类型(传感器接入模块)
@property (nonatomic, assign)KDeviceID           appDeviceId;   // 设备的appDeviceId
@property (nonatomic, assign)int                 endPoint;
@property (nonatomic, strong)NSString *          extAddr;

@end

@protocol OrderProtocol<HMDeviceProtocol>

@optional

// 小方等使用红外码库的设备需要的字段
@property (nonatomic, assign) int               freq;
@property (nonatomic, assign) int               pluseNum;
@property (nonatomic, copy) NSString *          pluseData;
@property (nonatomic, strong) NSString *        actionName;
@property (nonatomic, assign)int                delayTime;

@required

@property (nonatomic, strong)NSString *         bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;

@end


@protocol SceneEditProtocol <OrderProtocol>

@optional

@property (nonatomic, strong)NSString *          sceneBindId;       // 情景绑定
@property (nonatomic, strong)NSString *          linkageOutputId;   // 联动output

@property (nonatomic, copy) NSString * outPutTagId;
@property (nonatomic, assign) int outPutTag;

@property (nonatomic, assign)int                sceneBindTag;//绑定输出标识 1 为组
@property (nonatomic, strong)NSString *         sceneBindTagId;//绑定输出标识Id

+ (instancetype)deviceObject:(FMResultSet *)rs;

// 情景编辑设备时使用
+ (instancetype)bindObject:(FMResultSet *)rs;

- (id)copy;

@required

@property (nonatomic, strong)NSString *         floorRoom;
@property (nonatomic, assign)int                delayTime;
@property (nonatomic, assign)BOOL               selected;
@property (nonatomic, assign,readonly) BOOL     isLearnedIR;
@property (nonatomic, assign,readonly) BOOL     changed;

@end


@protocol DBProtocol

@required

/**
 *  从数据库查询出记录结果后生成对象
 *  @return 实例对象
 */
+ (instancetype)object:(FMResultSet *)rs;

/**
 *  从网络获取json数据后生成对象
 *
 *  @param dic 字典
 *
 *  @return 实例对象
 */
+ (instancetype)objectFromDictionary:(NSDictionary *)dic;

/**  建表 */
+ (BOOL)createTable;
- (BOOL)insertObject;

- (BOOL)updateObject;

- (BOOL)deleteObject;

+ (NSString *)tableName;

/** 更新/插入数据库数据的sql语句 - 支持事务 */
- (NSString *)updateStatement;

/**更新数据库 - 主线程*/
- (BOOL)executeUpdate:(NSString*)sql, ...;
+ (BOOL)executeUpdate:(NSString*)sql, ...;
- (BOOL)executeUpdateWithPlaceHolder:(NSString *)sql, ...;

/**查询数据库 - 主线程*/
- (FMResultSet *)executeQuery:(NSString*)sql, ...;
+ (FMResultSet *)executeQuery:(NSString*)sql, ...;

+ (BOOL)columnExists:(NSString*)columnName;

@optional
/**
 *  根据网关 uid 和 表记录的主键来查找对应的记录，返回个实例对象
 *
 *  @param UID      zigbee 网关uid 或 wifi设备自己的uid
 */
+ (instancetype)objectFromUID:(NSString *)UID recordID:(NSString *)recordID;

/** 创建内建有关联的触发器 */
+ (BOOL)createTrigger;

- (NSDictionary *)dictionaryFromObject;

/** 插入数据 - 支持事务 */
- (void)setInsertWithDb:(FMDatabase *)db;

@end

@interface HMBaseModel : NSObject<DBProtocol>

@property (nonatomic, strong) NSString *             uid;
@property (nonatomic, strong) NSString *             familyId;
@property (nonatomic, strong) NSString *             updateTime;
@property (nonatomic, strong) NSString *             createTime;

@property (nonatomic, assign) int              updateTimeSec;
@property (nonatomic, assign) int              createTimeSec;

/** 删除标志 */
@property (nonatomic, assign)int                     delFlag;

/** 事务操作时的更新/插入语句 */
@property (nonatomic, strong)NSString *              sql;

@end

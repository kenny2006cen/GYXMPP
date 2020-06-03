//
//  RemoteGateway+RT.h
//  HomeMate
//
//  Created by Air on 16/3/2.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RemoteGateway.h"

@interface RemoteGateway (RT)

// 读取安防打电话表信息
-(void)readSecurityTableWithCompletion:(commonBlock)completion;

// 读取 频道收藏表
- (void)readChannelCollectTableWithUid:(NSString *)uid completion:(commonBlock)completion;

// 读取S31，美标计量插座，配电箱的电量统计表，按deviceId 和 uid 读取统计数据
- (void)readTableOfDevice:(HMDevice *)device completion:(commonBlock)completion;

// 读单张表
- (void)readTableOfDevice:(HMDevice *)device tableName:(NSString *)tableName completion:(commonBlock)completion;


// 新配电箱按extAddr统计电量，按extAddr 和 uid 读取统计数据
- (void)readVoltameter:(NSString *)uid extAddr:(NSString *)extAddr completion:(commonBlock)completion;


/// 读取甲醛、CO探测仪日、周、月浓度统计表
- (void)readAvgConcentrationWithUid:(NSString *)uid completion:(commonBlock)completion;

// 读取 CO／HCHO 探测仪 事件表
- (void)readTableOfSensorWithUid:(NSString *)uid completion:(commonBlock)completion;


// 读取指定表数据
-(void)readTableWithUid:(NSString *)uid tableName:(NSString *)name completion:(commonBlock)completion;

// 按uid和表名来同步数据
- (void)readTableWithUid:(NSString *)uid tableArray:(NSArray *)array completion:(commonBlock)completion;


// 读取常用模式表数据
- (void)readFrequentlyModeWithDevice:(HMDevice *)device completion:(commonBlock)completion;

// 读取指定家庭的楼层房间数据
- (void)readFloorAndRoomWithFamilyId:(NSString *)familyId completion:(commonBlock)completion;

// 读取遥控器绑定表数据
- (void)readRemoteBindWithCompletion:(commonBlock)completion;

// 读取消息类型表（此表返回当前家庭有哪些种类的消息）
- (void)readMessageTypeWithCompletion:(commonBlock)completion;

@end

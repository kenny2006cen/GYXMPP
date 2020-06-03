//
//  VihomeScene.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMScene : HMBaseModel

@property (nonatomic, retain)NSString *             sceneNo;

@property (nonatomic, retain)NSString *             sceneName;

@property (nonatomic, retain)NSString *             roomId;

@property (nonatomic, assign)int                    onOffFlag; // 0表示全关、1表示全开

@property (nonatomic, assign)int                    sceneId;

@property (nonatomic, assign)int                    groupId;

@property (nonatomic ,assign)int                    pic;

@property (nonatomic, strong) NSString *             userId;    ///< wifi情景 新增字段

@property (nonatomic, assign,readonly)BOOL      changed;        ///< 判断当前情景的名称和图标是否发生变化
@property (nonatomic, retain)NSString *         initialName;
@property (nonatomic, assign)int                initialPic;
@property (nonatomic, assign)BOOL               createSuccess;  ///< 只在创建情景时使用，标记添加情景时，情景是否添加成功

@property (nonatomic, copy) NSString *             imgUrl;    ///< 自定义情景图片的URL

/**
 获取当前帐号所有情景数组
 */
+ (NSArray *)allScenesArr;

/**
 根据 sceneNo 获取情景
 */
+ (HMScene *)readSceneWithSceneNo:(NSString *)sceneNo;

/**
 情景对应的图片名称
 */
- (NSString *)picName;

/**
 根据 sceneNo 获取该情景下的情景绑定中的主机 uid 列表

 @return 返回 uid 数组，会过滤掉 wifi 设备的 uid
 */
+ (NSArray *)getSceneBindHostUIDsWithSceneNo:(NSString *)sceneNo;

/**
 当前情景下面的设备所在的主机数组（可能同一个情景绑定了多台主机下面的设备,此时就有多个uid）。
 */
-(NSArray<NSString *> *)zigbeeHostUidArray;

@end

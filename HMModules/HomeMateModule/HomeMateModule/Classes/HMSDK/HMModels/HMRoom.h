//
//  VihomeRoom.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMRoom : HMBaseModel

@property (nonatomic, retain)NSString *         roomId;

@property (nonatomic, retain)NSString *         roomName;

@property (nonatomic, retain)NSString *         floorId;

@property (nonatomic, assign)int                roomType;

@property (nonatomic, assign,readonly)          BOOL hasDevice;


/**
 *  如果房间存在并且房间里面有设备，则认为这个房间有效
 */
@property (nonatomic, assign,readonly)          BOOL isValidRoom;

@property (nonatomic, assign)NSInteger          index;

@property (nonatomic, copy)NSString *           imgUrl;

@property (nonatomic, assign)BOOL               beSelected;

@property (nonatomic, assign)BOOL               fromHomePagePullDown; // 首页下拉

+ (NSArray *)selectAllRoom;
+ (NSMutableArray *)selectAllRoomWithFloorId:(NSString *)floorId;
+ (NSInteger )selectRoomCountWithFloorId:(NSString *)floorId;
+ (NSString *)selectFloorIdByRoomId:(NSString *)roomId;

/** 查不到当前roomId对应的房间，则返回默认房间 */
+ (HMRoom *)objectWithRoomId:(NSString *)roomId;

/** 查不到当前roomId对应的房间，则返回nil */
+ (instancetype)objectWithRecordId:(NSString *)recordID;

/** 该roomId对应的房间是否是默认房间（只判断该房间的roomtype=-1，空roomId不算默认房间） */
+ (BOOL)isDefaultRoom:(NSString *)roomId;
/** 当前家庭的默认房间id */
+ (NSString *)defaultRoomId;

/**
 是否应该显示默认房间
 
 @return 默认房间不是唯一房间且为空时，需要隐藏
 */
+ (BOOL)shouldShowDefaultRoom;

@end

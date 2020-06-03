//
//  HMCommonScene.h
//  HomeMateSDK
//
//  Created by liuzhicai on 16/9/29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMCommonScene : HMBaseModel

@property (nonatomic, retain)NSString *   userId;

@property (nonatomic, retain)NSString *   roomId;

@property (nonatomic, retain)NSString *   sceneNo;

@property (nonatomic, assign)int   sortNum;


+ (NSArray *)commonSceneWithRoomId:(NSString *)roomId;

+ (BOOL)deleteCommonSceneWithRoomId:(NSString *)roomId;

@end

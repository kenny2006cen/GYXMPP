//
//  AddLinkageServiceCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2017/2/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"
#import "HMLinkage.h"

//typedef NS_ENUM(NSInteger,HMLinakgeType) {
//    HMLinakgeTypeCommon = 0,//普通联动
//    HMLinakgeTypeVoice = 1,//个性化说法联动
//};
//
////语音自动化模式
//typedef NS_ENUM(NSInteger,HMLinakgeVoiceMode) {
//    HMLinakgeVoiceModeCustom = 0,//自定义
//    HMLinakgeVoiceModeBackHome = 1,//回家模式
//    HMLinakgeVoiceModeLeaveHome = 2,//离家模式
//    HMLinakgeVoiceModeGetUp = 3,//起床模式
//    HMLinakgeVoiceModeSleep = 4,//睡觉模式
//    HMLinakgeVoiceModeMoving = 5,//观影模式
//    HMLinakgeVoiceModeMeeting = 6,//会客模式
//};

@interface AddLinkageServiceCmd : BaseCmd

@property (nonatomic, strong) NSString *familyId;

@property (nonatomic,strong)NSString *linkageName;

@property (nonatomic,strong)NSArray * linkageConditionList;
@property (nonatomic,strong)NSArray * linkageOutputList;

// and：表示条件进行“与”运算 or：表示条件进行“或”运算
@property (nonatomic,strong)NSString *conditionRelation;

@property (nonatomic, assign) HMLinakgeType  type;

@property (nonatomic, assign) HMLinakgeVoiceMode  mode;


@end

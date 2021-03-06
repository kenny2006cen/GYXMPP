//
//  FrequentlyModeModel.h
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMBaseModel+Extension.h"
#import "HMConstant.h"


@interface HMFrequentlyModeModel : HMBaseModel

@property (nonatomic, retain)NSString *        frequentlyModeId;

@property (nonatomic, assign)int                modeId;

@property (nonatomic, assign)int                pic;

@property (nonatomic, retain)NSString *        name;

@property (nonatomic, retain)NSString *        deviceId;

@property (nonatomic, retain)NSString *         bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;

+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid;

+ (NSMutableArray <HMFrequentlyModeModel *>*)allFrequentlyModeForDevice:(HMDevice *)device;

+ (HMFrequentlyModeModel *)frequentlyModeWithFrequentlyModeId:(NSString *)frequentlyModeId;

+ (BOOL)deleteAllCurtainModeWithDevice:(HMDevice *)device;

+ (HMFrequentlyModeModel *)frequentlyModeModelForDevice:(HMDevice*)device andValue:(CGFloat)value;

/**
 根据value1的百分比匹配模式
 */
+ (instancetype)curtainModelWithDevice:(HMDevice *)device action:(HMAction *)action;
@end

//
//  BLUtility.h
//  Vihome
//
//  Created by Ned on 1/19/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "RGB_FLOAT_HSL.h"
#import "HMBaseModel.h"


@class HMDeviceStatus;


@interface BLUtility : NSObject

+ (int)getTimestamp;

+ (double)getUnixTimestamp;

+ (NSString *)getIPAddressByData:(NSData *)data;

+ (NSMutableData *)stringToNSData:(NSString*)str len:(int)len;

+ (NSString *)dataToHexString:(NSData *)data;

+ (NSData *)CRCDataWithEncryptedString:(NSString *)encryptedString;

+ (NSData *)CRCDataWithEncryptedDataToHexData:(NSData *)encryptedPayLoadData;

+ (int)getRandomNumber:(int)from to:(int)to;

+ (NSString *)getBinaryByhex:(NSString *)hex;

+ (NSData *)dataFromHexString:(NSString *)hexString;

+ (NSString *)getIPAddress;

+ (NSString*)DataTOjsonString:(id)object;

+ (NSDictionary *)periodIntValueToDic:(int)value;

+ (int)periodDicToIntValue:(NSDictionary *)valueDic;


+ (int)stringByteLength:(NSString*)strtemp;

+(BOOL)isIncludeSpecialCharact: (NSString *)str;

/**
 *  是否是开关型设备，仅支持开关
 *
 *  @param type 设备类型
 */
+ (BOOL)isSwitchType:(KDeviceType)type;

/**
 *  是否是虚拟红外设备
 */
+ (BOOL)isInfraredDevice:(KDeviceType)type;

/**
 *  是否是旧的窗帘控制盒 (仅支持开关停)
 *
 *  @param type 设备类型
*/
+ (BOOL)isOldControlboxDevice:(KDeviceType)type;

/**
 *  是否是新的设窗帘控制盒（支持百分比）
 *
 *  @param type 设备类型
 *
 *  @return YES：是新的窗帘控制盒 NO：不是新的窗帘控制盒
 */
+ (BOOL)isNewControlboxDevice:(KDeviceType)type;


+ (BOOL)isC1LockOnline:(HMDeviceStatus *)status;

+ (NSString *)getStringByLimitByte:(int)byteLen string:(NSString *)string;


/**
 判断是否为 红外设备
 */
+ (BOOL)isRFDevice:(id <SceneEditProtocol>)sbind;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (NSString *)cutMusicsArrayString:(NSString *)musicString plusData:(NSString *)pluseData withWidth:(CGFloat)width;

/**
 十进制转换为  16位组成的二进制
 @param decimal 十进制数
 @return 二进制数  16位组成,不足补0
 */
+ (NSString *)getSixteenBitBinaryByDecimal:(NSInteger)decimal;

/// 十进制转为任意位的二进制
/// @param numberBit 二进制的位数
/// @param decimal 十进制的数
+ (NSString *)getBinaryOfAnyBit:(NSUInteger)numberBit byDecimal:(NSInteger)decimal;

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary;

/**
 秒转时间 225 ---> 02:30
 */
+  (NSString *)timeformatFromSeconds:(NSInteger)seconds;

// 对象转字典
+ (NSDictionary*)getDicObjectData:(id)obj;

// json 转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

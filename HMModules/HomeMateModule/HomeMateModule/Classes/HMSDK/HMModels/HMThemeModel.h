//
//  HMThemeModel.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMThemeModel : HMBaseModel

@property (nonatomic, strong) NSString *themeId;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) int themeType;
@property (nonatomic, assign) int nameType;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) int angle;
@property (nonatomic, assign) int variation;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) int sequence;

// 返回动态主题和静态主题组成的二维数组，动态主题为第一组，静态主题第二组
+ (NSMutableArray *)themesOfDeviceId:(NSString *)deviceId;
+ (HMThemeModel *)themeOfThemeId:(NSString *)themeId;

+ (HMThemeModel *)themeOfDeviceId:(NSString *)deviceId themeType:(int)themeType;
+ (HMThemeModel *)themeOfDeviceId:(NSString *)deviceId nameType:(int)nameType;

@end

//
//  GYGenUUID.h
//  HSConsumer
//
//  Created by shiang on 15/10/9.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GYGenUUID : NSObject


+(NSString *)gen_uuid;

+(NSString *)unique_uuid;

+ (NSString *)createUUID;
@end
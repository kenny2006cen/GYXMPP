//
//  SetAuthorityUnlockCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SetAuthorityUnlockCmd : BaseCmd
@property(nonatomic,copy)NSString * deviceId;
@property(nonatomic,copy)NSString * authorityUserName;
@property(nonatomic,copy)NSString * phone;
@property(nonatomic,assign)int startTime;//帐号生效开始UTC时间，单位秒
@property(nonatomic,assign)int effectTime;//分钟授权有效时长
@property(nonatomic,assign)int type;//用来区分用那种方式来找到startTime跟effectTime
@property(nonatomic,assign)int endTime;//结束时间
@property(nonatomic,assign)int number;//在有效期内允许开锁的次数。填写0的时候表示不限制次数。
@property(nonatomic,strong)NSNumber * isPush;//是否每次临时授权开锁时推送消息，未设置时默认打开
//下面为H1门锁新增的字段
@property(nonatomic,copy)NSString * unencryptedPassword; //未加密密码，服务器根据此字段发送短信

/**
 pwdUseType为3时，该字段有效，天数以逗号分隔，比如一个月的1,10,20号有效则传入 1,10,20
 */
@property(nonatomic,copy)NSString * day;
@property(nonatomic,assign)int pwdGenerateType; //0：随机密码 1：自定义密码
@property(nonatomic,copy)NSString * password; // pwdGenerateType为1时，此处填写所对应的自定义密码

/**
 0:多次有效
 1:1次有效
 2：每周有效（周期性密码授权）
 3：一个月的某些天有效（周期性密码授权）
 4：每天有效（周期性密码授权）
 配合开锁次数number使用
 */
@property(nonatomic,assign)int pwdUseType;

/**
 用以区分是哪个平台的授权，如果是公寓平台的不需要服务器端来发短信，公寓平台来发送
 0:默认智家365平台
 1:公寓平台
 */
@property(nonatomic,assign)int system;

/**
 type为null 或0时(旧版本app无此参数，为null), app传startTime和effectTime 服务器下发给给主机的startTime=startTime effectTime =effectTime
 type=1 app传startTime和endTime 服务器下发给给主机的startTime=startTime effectTime=endTime-startTime
 type=2 app传effectTime 服务器下发给给主机的startTime=服务器当前时间 effectTime=effectTime
 type=3 app传endTime 服务器下发给给主机的startTime=服务器当前时间 effectTime=endTime-服务器当前时间
 */



@end

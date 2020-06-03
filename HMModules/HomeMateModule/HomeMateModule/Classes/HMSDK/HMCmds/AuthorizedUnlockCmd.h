//
//  AuthorizedUnlockCmd.h
//  
//
//  Created by Air on 15/12/4.
//
//

#import "BaseCmd.h"

@interface AuthorizedUnlockCmd : BaseCmd

/**
 *  门锁编号
 */
@property (nonatomic, strong)NSString * deviceId;

/**
 *  授权手机号
 */
@property (nonatomic, strong)NSString * phone;

/**
 *  授权时间 单位，分钟 UTC
 */
@property (nonatomic, assign)int  time;

/**
 *  授权次数 在有效期内允许开锁的次数。
    填写0的时候表示不限制次数。
 */
@property (nonatomic, assign)int  number;

/**
 type为null 或0时(旧版本app无此参数，为null), app传startTime和effectTime 服务器下发给给主机的startTime=startTime effectTime =effectTime
 type=1 app传startTime和endTime 服务器下发给给主机的startTime=startTime effectTime=endTime-startTime
 type=2 app传effectTime 服务器下发给给主机的startTime=服务器当前时间 effectTime=effectTime
 type=3 app传endTime 服务器下发给给主机的startTime=服务器当前时间 effectTime=endTime-服务器当前时间
 */
@property(nonatomic,assign)int type;//用来区分用那种方式来找到startTime跟effectTime
@property(nonatomic,assign)int endTime;//结束时间
@property(nonatomic,strong)NSNumber * isPush;//是否每次临时授权开锁时推送消息，未设置时默认打开

@end

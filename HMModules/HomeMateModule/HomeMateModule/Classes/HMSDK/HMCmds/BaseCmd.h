//
//  CmdBase.h
//  Vihome
//
//  Created by Air on 15-1-24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalSocket.h"
#import "HMTypes.h"

@protocol BaseCmdProtocol <NSObject>

@required

-(NSDictionary *)payload;
@end

@interface BaseCmd : NSObject <BaseCmdProtocol>
{
    @protected
    // data send
    NSMutableDictionary *sendDic;
}

/**
 *  命令编号
 */
@property (nonatomic,assign) VIHOME_CMD cmd;
@property (nonatomic,strong) NSString *key;
/**
 *  流水号
 */
@property (nonatomic,assign)int serialNo;

/**
 *  uid 用于区分 cmd 要发给哪个网关
 */
@property (nonatomic,strong) NSString *uid;

/**
 *  当前登录用户的userName（手机号或邮箱）
 */
@property (nonatomic,strong)NSString *userName;

/**
 *  是否指定发送命令到服务器,默认为NO。当值为NO时，远程socket链接正常时，优先发送到服务器，异常时发送到局域网主机
 */
@property (nonatomic,assign) BOOL sendToServer;

/**
 *  是否指定发送命令到网关，默认为NO。当值为YES时，只发送指令到局域网内的主机
 */
@property (nonatomic,assign) BOOL sendToGateway;

/**
 *  命令被重发的次数
 */
@property (nonatomic,assign)int resendTimes;

/**
 *  时间戳， 主机判断客户端的数据不是最新的话，就返回错误，不允许做修改操作
    41：主机数据已修改，请重新同步最新数据
    42：主机繁忙，请等待30秒之后再重试
 */
@property (nonatomic,strong)NSNumber *lastUpdateTime;

/**
 *  此命令的回调
 */
@property (nonatomic,copy) SocketCompletionBlock finishBlock;

/******************************分页加载******************************/
/**
 *  起始页，默认0
 */
@property (nonatomic,strong)NSNumber *start;
/**
 *  每页数据条数
 */
@property (nonatomic,strong)NSNumber *limit;

/**
 *  分页数据数组
 */
@property (nonatomic,strong)NSMutableArray *pagingArray;

/******************************数据同步******************************/

/**
 *  当需要数据同步的时候，数据同步（读取表数据）是否成功，只有数据更新成功才能更新系统的lastUpdateTime
 */
@property (nonatomic,assign) BOOL syncDataSuccess;

@property (nonatomic,assign) BOOL needSyncData;

/** 红外控制不重发 */
@property (nonatomic,assign) BOOL onlySendOnce;// 红外控制不重发

/** SDK层不处理服务器的返回值(returnValue)，直接返回到上层处理 */
@property (nonatomic,assign) BOOL isTransparent;


+(instancetype)object;
-(instancetype)taskWithCompletion:(SocketCompletionBlock)completion;
-(NSData *)data; // 适用于UDP广播包，没有session信息
-(NSData *)data:(GlobalSocket *)socket;
-(NSDictionary *)jsonDic;
-(NSMutableData *)headData:(NSData *)payloadData;

/**
 *  发送指令后，返回 41错误码 主机数据已修改，请重新同步最新数据 或 70错误码 服务器数据已修改，请重新同步最新数据
 *  时先同步数据，数据同步完成之后，再次发送命令时更新一下流水号，避免服务器返回一分钟内流水号重复
 */
-(void)updateSerialNo;

@end

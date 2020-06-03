
//
//  Gateway+Send.m
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+Send.h"
#import "Gateway+Receive.h"
#import "Gateway+Foreground.h"
#import "HMNetworkMonitor.h"
#import "HMTaskManager.h"
#import "HMConstant.h"

@implementation Gateway (Send)

#pragma mark - -----------------------发送数据 --- begin -----------------------

#pragma mark - 设置延时
- (void)preSendCmd:(BaseCmd *)cmd socket:(GlobalSocket *)socket completion:(SocketCompletionBlock)completion
{
    //LogFuncName();
    NSTimeInterval timeout = self.cmdTimeout;

    if (cmd.cmd == VIHOME_CMD_CD) {
        
        BaseCmd *task = [self getTask:@(cmd.serialNo)];
        if (!task) {
            // 找到队列中已经存在的同一个设备相同的控制指令
            ControlDeviceCmd *ctrlCmd = (ControlDeviceCmd *)cmd;
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"cmd = %d",VIHOME_CMD_CD];
            NSArray *ctrlCmdArray = [self.taskQueue.allValues filteredArrayUsingPredicate:pred];
            if (ctrlCmdArray.count > 0) {
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"deviceId = %@ and order = %@",ctrlCmd.deviceId,ctrlCmd.order];
                NSArray *sameDevCmdArray = [ctrlCmdArray filteredArrayUsingPredicate:pred];
                
                if (sameDevCmdArray.count > 0) {
                    
                    for (BaseCmd *task in sameDevCmdArray) {
                        
                        [self ignoreTask:task.jsonDic];
                    }
                    DLog(@"移除重复的控制指令，不再回调：%@",ctrlCmdArray);
                }
            }else{
                DLog(@"任务队列中不存在同一个设备相同的控制指令，直接发送: %@",cmd);
            }
        }else{
            DLog(@"任务已经存在，所以是指令重发: %@",cmd);
        }
        
        // VtiOem 的一款RF电机需要增加超时
        ControlDeviceCmd *ctrlCmd = (ControlDeviceCmd *)cmd;
        if ([ctrlCmd.order isEqualToString:@"rf control"]) {
            timeout = 8;
        }
    }
    
    
    //DLog(@"添加任务: %@",cmd);
    
    [self addTask:[cmd taskWithCompletion:completion]];
    
    if (cmd.cmd == VIHOME_CMD_AFR) { // 同时添加楼层与房间时超时时间修改
        
        timeout *= 2;
        NSArray *floors = cmd.jsonDic[@"floorList"];
        timeout += floors.count;
        
    }else if (cmd.cmd == VIHOME_CMD_AF){ // 只添加楼层时超时时间修改
        timeout += 3;
    }else if (cmd.cmd == VIHOME_CMD_AR){ // 只添加房间时超时时间修改
        timeout += 3;
    }else if (cmd.cmd == VIHOME_CMD_AL) { // 添加联动
        
        timeout *= 2;
        NSArray *outputs = cmd.jsonDic[@"linkageOutputList"];
        timeout += outputs.count / 5;
        
    }else if (cmd.cmd == VIHOME_CMD_SLK){ // 修改联动
        
        timeout *= 2;
        NSArray *addOutputs = cmd.jsonDic[@"linkageOutputAddList"];
        NSArray *modifyOutputs = cmd.jsonDic[@"linkageOutputModifyList"];
        NSArray *deleteOutputs = cmd.jsonDic[@"linkageOutputDeleteList"];
        
        timeout += (addOutputs.count + modifyOutputs.count + deleteOutputs.count) / 5;
    }
    else if (cmd.cmd == VIHOME_CMD_GETEMAILCODE || cmd.cmd == VIHOME_CMD_GSC){
        timeout = 8;
    }else if (cmd.cmd == VIHOME_CMD_AUU){ // 授权开锁
        timeout = 12;
    }else if (cmd.cmd == VIHOME_CMD_DD){  // 删除设备，超时时长改为6s
        timeout = 6;
    }
    else if (cmd.cmd == VIHOME_CMD_CD){
        // 控制命令，如果设备不在线，不重发
        ControlDeviceCmd *ctrlCmd = (ControlDeviceCmd *)cmd;
        NSString *deviceId =  ctrlCmd.deviceId;
        NSString *uid = cmd.uid;
        HMDeviceStatus *status = [HMDeviceStatus objectWithDeviceId:deviceId uid:uid];
        if (!status.online) { // 设备不在线，则只发一次即给结果
            cmd.resendTimes = kMaxTryTimes;
        }
    }
    else if (cmd.cmd == VIHOME_CMD_GB){  // 绑定主机命令，超时设置的长一点
        timeout = 6;
    }
    else if ((cmd.cmd == VIHOME_CMD_RK) && cmd.uid){  // 本地申请通信密钥时，超时时间设置长一点
        timeout = 5;
    }else if (cmd.cmd == VIHOME_CMD_LO){  // 退出登录
        timeout = 3;    // 退出登录命令，尝试两次，最多 6s 钟返回结果
    }else if (cmd.cmd == VIHOME_CMD_SCENE_SERVICE_ADD_BIND
              ||cmd.cmd == VIHOME_CMD_SCENE_SERVICE_MODIFY_BIND
              ||cmd.cmd == VIHOME_CMD_SCENE_SERVICE_DELETE_BIND
              ||cmd.cmd == VIHOME_CMD_SCENE_SERVICE_DELETE
              ||cmd.cmd == VIHOME_CMD_CREAT_GROUP
              ||cmd.cmd == VIHOME_CMD_SET_GROUP){//情景,组绑定重发超时时间设成25秒

        timeout = 25;// bug 11745 23s才返回 这里在加长一点

    } else if (cmd.cmd == VIHOME_CMD_LINKAGE_SERVICE_CREATE
               || cmd.cmd == VIHOME_CMD_LINKAGE_SERVICE_SET
               || cmd.cmd == VIHOME_CMD_LINKAGE_SERVICE_DELETE
               || cmd.cmd == VIHOME_CMD_LINKAGE_SERVICE_ACTIVE) {   // 新联动接口的超时为 15S
        timeout = 20;
    }else if (cmd.cmd == VIHOME_CMD_HB){  // 心跳包命令，超时设置的短一点
        timeout = 2;
    }else if (cmd.cmd == VIHOME_CMD_VOICE_CONTROL) { //语音控制命令 超时设置的短一点
        timeout = 3;
    }
    
    // 3g 网络下，延时设置长一点
    if ([HMNetworkMonitor shareInstance].networkStatus == ReachableViaWWAN) {
        timeout += 3;
    }
    
    [self didSendCmd:cmd socket:socket withTimeout:timeout];
    
}

- (void)didSendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    //LogFuncName();
    
    __weak Gateway *weakSelf = self;
    
    __weak GlobalSocket *socket = [self socket]; // 根据当前情况，确认使用远程socket还是本地socket
    
    // 无通信密钥则先申请通信密钥
    
    if (!socket.encryptionKey && (cmd.cmd != VIHOME_CMD_RK)) {
        
        DLog(@"未申请通信密钥，先申请通信密钥：%@",cmd);
        
        RequestKeyCmd *reqCmd = [RequestKeyCmd object];
        reqCmd.uid = socket.uid; // 远程时UID为空，本地时为真实UID
        
        [weakSelf preSendCmd:reqCmd socket:socket completion:^(KReturnValue returnValue, NSDictionary *dic) {
            
            if (returnValue == KReturnValueSuccess) { // 申请通信密钥成功
                
                // 需要重新登录的指令，在申请密钥之后自动登录，其它指令直接重发
                if (cmd.cmd != VIHOME_CMD_CL && [HMTaskManager isNeedLogin:cmd]){
                    
                    DLog(@"申请通信密钥成功：%@，原命令：%@",reqCmd,cmd);
                    
                    // type = 3 family登录
                    LoginCmd *lgCmd = [HMLoginAPI cmdWithUserName:userAccout().userName password:userAccout().password uid:socket.uid];
                    [weakSelf preSendCmd:lgCmd socket:socket completion:^(KReturnValue returnValue, NSDictionary *returnDic) {

                        // 重新登录成功，则发送最开始要发送的命令
                        if (returnValue == KReturnValueSuccess) {
                            
                            DLog(@"登录成功：%@，继续发送命令：%@",lgCmd,cmd);
                            
                            [weakSelf preSendCmd:cmd socket:socket completion:completion];
                            
                        }else{
                            
                            // 主机返回的用户名密码错误不再处理
                            DLog(@"重新登录失败，错误码：%d 命令：%@",returnValue,cmd);
                            if (completion) {
                                completion(returnValue,returnDic);
                            }
                        }
                    }];
                    
                }else  if (returnValue == KReturnValueUidNotMatching) {
                    
                    DLog(@"登录主机携带的uid信息和主机真实的uid信息不匹配，则将命令转到服务器发送");
                    // 将命令转发到服务器
                    [self repeaterTransmit:cmd completion:completion];
                }
                else {
                    
                    DLog(@"申请通信密钥成功：%@，继续发送命令：%@",reqCmd,cmd);
                    [weakSelf preSendCmd:cmd socket:socket completion:completion];
                }
            }else{
                // 将命令转发到服务器
                [self repeaterTransmit:cmd completion:completion];
            }
        }];
        
    }else{
        
        //DLog(@"socket状态正常，直接发送命令：%@",cmd);
        [self preSendCmd:cmd socket:socket completion:completion];
    }
}

-(void)didSendCmd:(BaseCmd *)cmd socket:(GlobalSocket *)socket withTimeout:(NSTimeInterval)timeout
{
//    LogFuncName();
    
#pragma mark - 添加超时
    [self addTimeout:cmd afterDelay:timeout];
    
    [self didSendCmd:cmd socket:socket];
}

#pragma mark - 创建socket 发送数据

-(void)didSendCmd:(BaseCmd *)cmd socket:(GlobalSocket *)socket_
{
//    LogFuncName();
    
    __weak GlobalSocket * weakSocket = socket_;
    
    VoidBlock didSendCmd = ^{
        
        NSData *sendData = [cmd data:weakSocket];
        
        DLog(@"socket连接正常 数据长度:%d "
             "%@:%d \n\n发送%@\n%@\n",sendData.length,weakSocket.connectedHost,weakSocket.connectedPort,cmd,[cmd jsonDic]);
        
        [weakSocket readDataWithTimeout:-1 tag:cmd.serialNo];//启动接收线程
        [weakSocket writeData:sendData withTimeout:-1 tag:cmd.serialNo];
    };
    
    
    if ([weakSocket isConnected]) {
        
        //DLog(@"[socket isConnected]");
        
        didSendCmd();
        
    }else {
        
        // 异步等待
        DLog(@"[socket isDisconnected]");
        
        __weak Gateway *weakSelf = self;
        DLog(@"tcp %@:%d 未连接", weakSocket.connectedHost, weakSocket.connectedPort);
        [weakSelf cancelALTimeout:@(cmd.serialNo)]; // 先取消超时，等待8秒socket正式建立之后再重新设置超时
        
        __block NSInteger tryTimes = 0;
        NSInteger maxTryTimes = 8;
        NSTimeInterval interval = 1.0; // 间隔1.0s执行一次
        gcdRepeatTimer(interval, ^BOOL{
            
            tryTimes++;
            
            if (userAccout().isEnterBackground){
                
                DLog(@"进入后台，不再等待，也不返回结果");
                
            }else if ([weakSocket isConnected]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    DLog(@"socket 连接成功，已等待 %d 秒",tryTimes);
                    // 添加超时，发送指令
                    [weakSelf addTimeout:cmd afterDelay:weakSelf.cmdTimeout];
                    didSendCmd();
                });
                
            }else if ([weakSocket isDisconnected]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    DLog(@"确认连接断开，走超时重发路径");
                    
                    weakSocket.connectFailed = YES;
                    [weakSelf resendCmd:cmd reason:KReturnValueConnectError];
                });
                
            }else if(tryTimes >= maxTryTimes) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    DLog(@"socket 连接 %d次失败，走超时重发路径",tryTimes);
                    weakSocket.connectFailed = YES;
                    [weakSelf resendCmd:cmd reason:KReturnValueConnectError];
                });
                
            }else{
                
                NSString *theHost = weakSelf.host;
                uint16_t thePort = weakSelf.port;
                
                DLog(@"尝试重新连接 %d次 Host:%@ Port:%d",tryTimes,theHost,thePort);
                
                NSError *err = nil;
                if (![weakSocket connectToHost:theHost onPort:thePort error:&err]) {
                    DLog(@"tcp 仍然未连接成功");
                    
                    // 4s还未连接成功，则断开重连
                    if (tryTimes % 4 == 0) {
                        [weakSocket disconnect];
                    }
                }
                
                
                return NO; // 继续循环尝试连接 server
            }
            return YES; // 执行到此处就停止timer
        }, nil);
    }
}
#pragma mark - -----------------------发送数据 --- end -----------------------


#pragma mark - 重发指令
-(void)resendCmd:(BaseCmd *)cmd reason:(KReturnValue) returnValue
{
    LogFuncName();
    
    // 重发时有可能是超时时间到了，也可能是网络连接无法建立，如果是网络无法建立则要先取消超时函数
    [self cancelALTimeout:@(cmd.serialNo)];
    
    cmd.resendTimes += 1; // 默认重试3次，失败一次加一，加为3时返回失败
    
    int tryTimes = cmd.resendTimes;
    if (tryTimes < kMaxTryTimes) { // 如果还可以重试则重发
        
        // 情景绑定 增删改的时候不能重发，否则主机会认为是又添加了新的设备去绑定
        if (cmd.cmd == VIHOME_CMD_AB
            || cmd.cmd == VIHOME_CMD_MB
            || cmd.cmd == VIHOME_CMD_DB
            || cmd.cmd == VIHOME_CMD_AF  // 添加楼层时不重发
            || cmd.cmd == VIHOME_CMD_AR  // 添加房间时不重发
            || cmd.cmd == VIHOME_CMD_AFR // 同时添加楼层与房间时不重发
            || cmd.cmd == VIHOME_CMD_AD  // 添加遥控器不重发
            || cmd.onlySendOnce  // 红外控制时，此值为Yes不重发
            ) {
            
            // 如果第一次命令是同步数据了，则允许再重发一次
            if (cmd.needSyncData && cmd.syncDataSuccess) {
                DLog(@"如果第一次命令是同步数据了，则允许再重发一次，命令：%@",cmd);
                
                cmd.resendTimes = kMaxTryTimes;
                // 不能走finish路径，直接再发一次，队列中的任务不移除
                [self didSendCmd:cmd completion:cmd.finishBlock];
                
            }else{
                DLog(@"超时不重发，命令：%@",cmd);
                // 不重发的命令要走finish路径移除队列中的任务
                [self finishTaskWithStatus:returnValue dictionary:cmd.jsonDic];
            }
            
        }else {
            
            if (returnValue == KReturnValueConnectError) {
                DLog(@"客户端连接服务器失败重发，命令：%@ 尝试次数：%d",cmd,tryTimes);
            }else if (returnValue == KReturnValueTimeout){
                DLog(@"超时重发，命令：%@ 尝试次数：%d",cmd,tryTimes);
            }else{
                DLog(@"错误码：%d 导致重发，命令：%@ 尝试次数：%d",returnValue,cmd,tryTimes);
            }
            
            // 不能走finish路径，直接重发，队列中的任务不移除
            [self timeout:cmd completion:cmd.finishBlock];
        }
        
    }else {
        
        // 重发次数到的命令要走finish路径移除队列中的任务
        DLog(@"%@ 指令已经超时 总共尝试 %d次",cmd,cmd.resendTimes);
        [self finishTaskWithStatus:returnValue dictionary:cmd.jsonDic];
    }
}

#pragma mark - 命令超时
- (void)timeout:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    __weak typeof(self) weakSelf = self;
    
    int tryTimes = cmd.resendTimes;
    DLog(@"命令：%@ tryTimes == %d",cmd,tryTimes);
    {
        
        GlobalSocket *theSocket = weakSelf.socket;
        if (theSocket.isConnected) {
            
            // 时间戳过期的情况下才断开连接
            if (theSocket.timeStampExpired) {
                
                if (cmd.cmd == VIHOME_CMD_RK) {
                    DLog(@"socket时间戳过期，申请通信密钥超时不发送测试心跳包，再尝试一次 %@",cmd);
                    [weakSelf didSendCmd:cmd completion:completion];
                    
                }else if (cmd.cmd == VIHOME_CMD_LO){
                    
                    DLog(@"socket时间戳过期，退出登录指令再尝试一次 %@",cmd);
                    [weakSelf didSendCmd:cmd completion:completion];
                    
                }else{
                    
                    DLog(@"socket时间戳过期，则发送一个心跳包，测试链路是否连通");
                    HeartbeatCmd * hbReq = [HeartbeatCmd object];
                    hbReq.userName = userAccout().userName;
                    hbReq.uid = self.uid;
                    hbReq.resendTimes = kMaxTryTimes; // 只发一次，测试链路
                    [self didSendCmd:hbReq completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                        
                        if (returnValue == KReturnValueSuccess) {
                            
                            DLog(@"测试心跳包成功，链路通畅，第%d次发送命令 %@",tryTimes + 1,cmd);
                            
                            [weakSelf didSendCmd:cmd completion:completion];
                            
                        }else{
                            
                            DLog(@"测试心跳包超时无回应，则主动断开socket，重新建立链接");
 
                            [weakSelf disconnect];
                            
                            // 如果控制指令超时，则尝试本地控制
                            if (cmd.cmd == VIHOME_CMD_CD){
                                
                                DLog(@"远程控制指令超时，则再尝试本地控制一次 %@",cmd);
                                cmd.resendTimes = kMaxTryTimes;
                                
                                // 远程控制超时之后，设备所在的主机是本地状态
                                if (getGateway(cmd.uid).isLocalNetwork) {
                                    
                                    [getGateway(cmd.uid) didSendCmd:cmd completion:completion];
                                    
                                }else{
                                    
                                    // 远程控制超时主机是非本地状态，则再做一次mdns搜索
                                    searchGatewaysWtihCompletion(^(BOOL success, NSArray *gateways) {
                                        
                                        if (success && [[gateways valueForKey:@"uid"] containsObject:cmd.uid]) {
                                            
                                            [getGateway(cmd.uid) didSendCmd:cmd completion:completion];
                                            
                                        }else{
                                            DLog(@"MDNS搜索到的uid没有包含当前设备的uid，直接返回失败");
                                            if (completion) {
                                                completion(returnValue,nil);
                                            }
                                        }
                                    });
                                }
                            }else{
                                DLog(@"测试心跳包发送失败，则不再尝试，直接返回错误码:%d %@",returnValue,cmd);
                                if (completion) {
                                    completion(returnValue,nil);
                                }
                            }
                        }
                        
                    }];
                }
                
            }else{
                
                DLog(@"socket时间戳未过期，第%d次发送命令 %@",tryTimes + 1,cmd);
                [weakSelf didSendCmd:cmd completion:completion];
            }
            
        }else{
            
            DLog(@"socket链接断开，需要重新申请通信密钥，第%d次发送命令 %@",tryTimes + 1,cmd);
            theSocket.encryptionKey = nil;
            [weakSelf didSendCmd:cmd completion:completion];
        }
    }
}

#pragma mark -  转发指令给服务器
-(BOOL)repeaterTransmit:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    // 没有外网则不再转发命令给服务器，直接返回失败
    if (!isNetworkAvailable()) {
        DLog(@"没有外网，命令：%ld %@ 不再转发给服务器",cmd.cmd,NSStringFromClass([cmd class]));
        
        if (completion) {
            completion(KReturnValueConnectError,nil);
        }
        return NO;
    }
    //下面的命令如果本地发送超时则转给远程发送
    
    DLog(@"本地发送命令失败，转给远程发送");
    
    [getGateway(nil) didSendCmd:cmd completion:completion];
    return YES;

}


#pragma mark - 超时函数执行
-(void)ALSocketTimeout:(NSNumber *)serialNo
{
    if (![[NSThread currentThread]isMainThread]) {
        DLog(@"当前线程%@",[NSThread currentThread]);
    }
    
    LogFuncName();
    
    DLog(@"serialNo：%@ 超时函数执行",serialNo);
    
    BaseCmd *task = [self getTask:serialNo];
    
    if (task) {
        [self resendCmd:task reason:KReturnValueTimeout];
    }else{
        DLog(@"serialNo：%@ 任务被异常移除",serialNo);
    }
}

#pragma mark - 添加超时
-(void)addTimeout:(BaseCmd *)cmd afterDelay:(NSTimeInterval)delay
{
//    LogFuncName();
    
    int serialNo = cmd.serialNo;
    
    
    __weak typeof(self) weakSelf = self;
    
    if ([[NSThread currentThread]isMainThread]) {
        
        DLog(@"添加超时时间：%0.0fs %@",delay,cmd);
        [weakSelf performSelector:@selector(ALSocketTimeout:) withObject:@(serialNo) afterDelay:delay];
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"添加超时时间：%0.0fs %@",delay,cmd);
            [weakSelf performSelector:@selector(ALSocketTimeout:) withObject:@(serialNo) afterDelay:delay];
        });
    }
}

#pragma mark - 取消超时
-(void)cancelALTimeout:(NSNumber *)serialNo
{
    __weak typeof(self) weakSelf = self;
    
    if ([[NSThread currentThread]isMainThread]) {

        DLog(@"serialNo：%@ 移除超时",serialNo);
        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf
                                                 selector:@selector(ALSocketTimeout:)
                                                   object:serialNo];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"serialNo：%@ 取消超时",serialNo);
            // 取消超时函数
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf
                                                     selector:@selector(ALSocketTimeout:)
                                                       object:serialNo];
        });
    }
}
#pragma mark - 只发数据，不接收返回信息
- (void)onlySendData:(BaseCmd *)cmd
{
    GlobalSocket *socket = [self socket];
    if (socket.encryptionKey) {
        cmd.resendTimes = kMaxTryTimes;
        [self didSendCmd:cmd socket:socket];
    }
}

-(BaseCmd *)getTask:(NSNumber *)serialNo
{
    return self.taskQueue[serialNo];
}

-(void)addTask:(BaseCmd *)task
{
    [self.taskQueue setObject:task forKey:@(task.serialNo)];
}

-(void)removeTask:(BaseCmd *)task
{
    [self.taskQueue removeObjectForKey:@(task.serialNo)];
}
#pragma mark - 忽略掉当前task

-(void)ignoreTask:(NSDictionary *)taskInfo{
    
    NSNumber *serialNo = [taskInfo objectForKey:@"serial"];
    [self cancelALTimeout:serialNo];
    
    BaseCmd *task = [self getTask:serialNo];
    if (task) {
        
        if (task.finishBlock) {
            
            NSNumber *status = [taskInfo objectForKey:@"status"];
            
            task.finishBlock( status ? [status intValue] : KReturnControlCmdCancel,nil);
        }
        
        DLog(@"移除任务: %@",task);
        [self removeTask:task];
    }
}
@end

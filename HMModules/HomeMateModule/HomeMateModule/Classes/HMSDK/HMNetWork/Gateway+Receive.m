//
//  Gateway+Receive.m
//  HomeMate
//
//  Copyright © 2017年 Air. All rights reserved.
//

#import "Gateway+Receive.h"
#import "Gateway+RT.h"
#import "Gateway+HeartBeat.h"
#import "RemoteGateway+RT.h"
#import "Gateway+Send.h"
#import "NSData+AES.h"
#import "NSData+CRC32.h"
#import "SocketSend.h"
#import "HMTaskDistribution.h"
#import "HMConstant.h"

@interface GroupData :NSObject

@property (nonatomic,assign) NSUInteger length;
@property (nonatomic,assign) NSUInteger expectLen;
@property (nonatomic,strong) NSMutableData *data;

- (void)appendData:(NSData *)other;
- (NSData *)subdataWithRange:(NSRange)range;
@end


@implementation GroupData
-(id)init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableData data];
    }
    return self;
}
-(NSUInteger)length
{
    return self.data.length;
}
- (void)appendData:(NSData *)other
{
    [self.data appendData:other];
}
- (NSData *)subdataWithRange:(NSRange)range
{
    if (self.length >= (range.location + range.length)) {
        return [self.data subdataWithRange:range];
    }
    return nil;
}
@end


@implementation Gateway (Receive)
#pragma mark - -----------------------接收数据 --- begin -----------------------

-(void)handDataGroup:(NSData *)data expectLen:(int)lenNum socket:(GlobalSocket *)socket
{
    //LogFuncName();
    
    if (!self.groupData) {
        self.groupData = [[GroupData alloc]init];
        self.groupData.expectLen = lenNum;
        self.isGrouping = YES;
    }
    
    [self.groupData appendData:data];
    
    int groupDataLength = (int)self.groupData.length;
    int expectLen =  (int)self.groupData.expectLen;
    DLog(@"当前包长度：%d，期望长度：%d，组包后的长度：%d",data.length,expectLen,groupDataLength);
    
    if (groupDataLength >= expectLen) {
        
        NSRange range = NSMakeRange(0, expectLen);
        [self socket:socket didReceiveData:[self.groupData subdataWithRange:range]];
        
        // 上一次的组包逻辑已经处理完，
        NSUInteger remainLength = groupDataLength - expectLen;
        if (remainLength >= 4) {
            
            NSData *remainData = [self.groupData subdataWithRange:NSMakeRange(expectLen, remainLength)];
            
            self.isGrouping = NO;
            self.groupData = nil;
            
            [self handleUdpTcpData:remainData socket:socket];
            
        }else {
            // 结束组包
            self.isGrouping = NO;
            self.groupData = nil;
        }
        
    }else{
        //DLog(@"组包后的长度不够，继续等待新的数据包上来");
    }
}

-(BOOL)isValidDataHeader:(NSData *)data{
    if (data.length > 6) {
        //合法数据头定义：[0,1]=hd [2,3]=长度 [4,5]=协议类型（pk,dk,sl）
        NSString *head = asiiStringWithData([data subdataWithRange:NSMakeRange(0, 2)]);
        NSString *protocolType = asiiStringWithData([data subdataWithRange:NSMakeRange(4, 2)]);
        if ([head isEqualToString:@"hd"]
            && ([protocolType isEqualToString:@"pk"]
                || [protocolType isEqualToString:@"dk"]
                || [protocolType isEqualToString:@"sl"])) {
                return YES;
            }
    }
    //DLog(@"当前接收的数据header不合法，继续走组包流程");
    return NO;
}
-(void)handleUdpTcpData:(NSData *)data_ socket:(GlobalSocket *)socket
{
    //LogFuncName();
    
    NSData *data = data_;
    
    // 数据包实际长度
    int realLength = (int)data.length;
    
    if (realLength > 0) {
        
        // 如果当前是组包状态，但又接收到一个新的合法的数据头，则结束组包
        // 如果不结束组包可能导致组包状态一直无法取消，无法正确解析数据
        if (self.isGrouping && [self isValidDataHeader:data]) {
            self.isGrouping = NO;
            self.groupData = nil;
            DLog(@"当前是组包状态，又接收到一个新的合法的数据头，结束组包");
        }
        // 组包状态
        if (self.isGrouping) {
            
            [self handDataGroup:data expectLen:0 socket:socket];
            
        }else {
            
            // 协议中定义的数据长度
            int lenNum = [data hm_protocolLength];
            
            if (lenNum > 0) {
                
                // 正常情况下，实际长度要大于等于协议长度
                if (realLength >= lenNum){
                    
                    self.isGrouping = NO;
                    self.groupData = nil;
                    
                    NSRange range = NSMakeRange(0, lenNum);
                    [self socket:socket didReceiveData:[data subdataWithRange:range]];
                    
                    int remainLength = realLength  - lenNum;
                    if (remainLength >= 4) {
                        
                        DLog(@"接收到的数据包实际长度:%d大于协议长度:%d,剩余长度为:%d，所以需要将数据包拆包",realLength,lenNum,remainLength);
                        [self handleUdpTcpData:[data subdataWithRange:NSMakeRange(lenNum, remainLength)] socket:socket];
                        
                    }else if(remainLength == 0){
                        // 正常情况
                    }
                    else {
                        DLog(@"----------数据异常 实际长度:%d 协议长度:%d----------",remainLength,lenNum);
                    }
                    
                }else {
                    
                    DLog(@"需要组包，度实际长度:%d 协议长度:%d",realLength,lenNum);
                    // 需要组包，等待下一个包过来
                    [self handDataGroup:data expectLen:lenNum socket:socket];
                }
                
            }else {
                DLog(@"----------数据异常 实际长度:%d 协议长度:%d----------",realLength,lenNum);
            }
        }
        
    }else{
        DLog(@"----------数据异常 实际长度:%d 内容:%@----------",realLength,data);
    }
}

- (BOOL)socket:(GlobalSocket *)socket didReceiveData:(NSData *)data
{
    //LogFuncName();
    
    self.receivedData = data;
    NSUInteger length = self.receivedData.length;

    if (length > 42)
    {
        NSData *ptData = [data subdataWithRange:NSMakeRange(4, 2)];
        NSString *protocolType = [[NSString alloc]initWithData:ptData encoding:NSASCIIStringEncoding];
        
        NSData *crcData = [data subdataWithRange:NSMakeRange(6, 4)];
        NSUInteger receive_crc = getCrcValue(crcData);
        
        NSData * payLoadData = [data subdataWithRange:NSMakeRange(42, length - 42)];
        
        NSUInteger check_crc = [payLoadData hm_crc32];
        
        if (receive_crc == check_crc) {
            
            socket.updateTimeStamp = YES; // 接收到合法数据时，更新时间戳
            
            NSString *key = [protocolType isEqualToString:@"dk"] ? socket.encryptionKey : PUBLICAEC128KEY;
            //DLog(@"key:%@",key);
            
            NSData * decrytedpayLoadData = [payLoadData hm_AES128DecryptWithKey:key iv:nil];
            if (!decrytedpayLoadData) { // 尝试公钥解密
                decrytedpayLoadData = [payLoadData hm_AES128DecryptWithKey:PUBLICAEC128KEY iv:nil];
            }
            
            if (decrytedpayLoadData)
            {
                NSError * error = nil;
                NSDictionary *payloadDic = [NSJSONSerialization JSONObjectWithData:decrytedpayLoadData options:NSJSONReadingAllowFragments error:&error];
                if (error) {
                    NSString * decryptionString  = [[NSString alloc] initWithData:decrytedpayLoadData encoding:NSUTF8StringEncoding];
                    NSData *head = [data subdataWithRange:NSMakeRange(0, 2)];
                    NSString *headString = [[NSString alloc]initWithData:head encoding:NSASCIIStringEncoding];

                    DLog(@"接收数据解析失败，错误 error = %@，\n 失败的字符串 = %@ \n headString = %@ \n protocolType = %@ \n [data protocolLength] = %d \n check_crc = %d",[error description],decryptionString,headString,protocolType,[data hm_protocolLength],check_crc);

                    if (decryptionString) {
                        
                        DLog(@"接收数据内容:%@",decryptionString);
                        
                        decryptionString = [decryptionString stringByReplacingOccurrencesOfString : @"\r\n" withString : @"" ];
                        decryptionString = [decryptionString stringByReplacingOccurrencesOfString : @"\n" withString : @"" ];
                        decryptionString = [decryptionString stringByReplacingOccurrencesOfString : @"\t" withString : @"" ];
                        
                        DLog(@"修正后的字符串：%@",decryptionString);
                        
                        NSError * error = nil;
                        NSData *correctionData = [decryptionString dataUsingEncoding:NSUTF8StringEncoding];
                        payloadDic = [NSJSONSerialization JSONObjectWithData:correctionData options:NSJSONReadingAllowFragments error:&error];
                        if (error) {
                            DLog(@"字符串校正后仍然解析失败，错误 error = %@",[error description]);
                            
                            DLog(@"Head = %@ Len = %d ProtocolType = %@ CRC = %d SessionId = %@ 头部信息:%@",asiiStringWithData([data subdataWithRange:NSMakeRange(0, 2)]),[data hm_protocolLength],protocolType,receive_crc,asiiStringWithData([data subdataWithRange:NSMakeRange(10, 32)]),[data subdataWithRange:NSMakeRange(0, 42)]);
                        }
                    }else{
                        
                        DLog(@"----------数据异常 无法转换为UTF8字符串----------");
                        
                        DLog(@"Head = %@ Len = %d ProtocolType = %@ CRC = %d SessionId = %@ 头部信息:%@",asiiStringWithData([data subdataWithRange:NSMakeRange(0, 2)]),[data hm_protocolLength],protocolType,receive_crc,asiiStringWithData([data subdataWithRange:NSMakeRange(10, 32)]),[data subdataWithRange:NSMakeRange(0, 42)]);
                    }
                    
                }
                
                if (payloadDic) {
                    
                    DLog(@"接收数据总长度:%d 解密后数据长度:%d %@:%d \n接收%@\n%@",data.length,decrytedpayLoadData.length
                             ,socket.connectedHost,socket.connectedPort,[self getTask:payloadDic[@"serial"]]?:@"到数据",payloadDic);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 属性报告因需要处理大量数据，放到异步处理
                        // 其他接口，直接在主线程处理，避免属性报告过多的场景，阻塞其他接口的任务
                        VIHOME_CMD cmd = [[payloadDic objectForKey:@"cmd"] intValue];
                        if (VIHOME_CMD_PR == cmd) {
                            [[HMTaskDistribution sharedInstance]addTask:^BOOL{
                                return [self didProcessReceiveData:data payload:payloadDic socket:socket];
                            }];
                        }else{
                            [self didProcessReceiveData:data payload:payloadDic socket:socket];
                        }
                    });
                    
                }else {
                    
                    int lenNum = [data hm_protocolLength];
                    int length = (int)data.length;
                    
                    DLog(@"----------数据异常 实际长度:%d 协议长度:%d----------",length,lenNum);
                    DLog(@"----------数据异常 非标准JSON格式:\n%@----------,当前秘钥:%@",decrytedpayLoadData,[protocolType isEqualToString:@"dk"] ? socket.encryptionKey : PUBLICAEC128KEY);
                    
                    DLog(@"当前处于%@",self.isGrouping ? @"组包状态，取消组包":@"未组包状态");
                    self.isGrouping = NO;
                    self.groupData = nil;
                }
            }else {
                DLog(@"----------数据异常 解密失败:\n%@----------",decrytedpayLoadData);
                
                DLog(@"当前处于%@",self.isGrouping ? @"组包状态，取消组包":@"未组包状态");
                self.isGrouping = NO;
                self.groupData = nil;
            }
            
        }else {
            
            DLog(@"----------数据异常 crc 校验失败\n%@----------",self.receivedData);
            DLog(@"___当前秘钥:%@",[protocolType isEqualToString:@"dk"] ? socket.encryptionKey : PUBLICAEC128KEY);
            
            DLog(@"当前处于%@",self.isGrouping ? @"组包状态，取消组包":@"未组包状态");
            self.isGrouping = NO;
            self.groupData = nil;
        }
        
    }else {
        DLog(@"----------数据异常 长度小于42:\n%@----------",self.receivedData);
    }

    
    return YES;
}


#pragma mark - 处理接收到的数据

-(BOOL)didProcessReceiveData:(NSData *)data payload:(NSDictionary *)payloadDic socket:(GlobalSocket *)socket
{
    //LogFuncName();
    
    int cmd = [[payloadDic objectForKey:@"cmd"] intValue];
    int status = [[payloadDic objectForKey:@"status"] intValue];
    
    // session 过期，重新申请通信密钥
    if (status == KReturnValueSessionInvalid) {
        
        socket.encryptionKey = nil;
        [socket disconnect];
        DLog(@"socket 过期，走超时重发路径重新申请通信秘钥");
        
    }else if(status == KReturnValueNoAdminAuthority){ // 您不具备管理员权限
        
        NSNumber *serialNo = [payloadDic objectForKey:@"serial"];
        [self cancelALTimeout:serialNo];
        BaseCmd *task = [self getTask:serialNo];
        if (task) {
            
            // 如果是查询统计更新返回 60 状态，表示客户端未登录 或者子账号做修改操作
            // 则重新登录，重发送之前的指令
            LoginCmd *lgCmd = [HMLoginAPI cmdWithUserName:userAccout().userName password:userAccout().password uid:socket.uid];
            
            [self didSendCmd:lgCmd completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                
                if (returnValue == KReturnValueSuccess) {
                    [self resendCmd:task reason:status];
                }else{
                    [self finishTaskWithStatus:returnValue dictionary:payloadDic];
                }
            }];
            return YES;
            
        }else{
            DLog(@"任务异常，未查找到任务，流水号:%@",serialNo);
        }
    }else if(status == KReturnValueNotBindMainframe     // 该用户名未绑定到本主机
             || status == KReturnValueMainframeRest){   // 主机未绑定用户信息或者绑定信息已经被重置
        
        // 说明此账号与这个主机没有绑定关系
        NSString *uid = payloadDic[@"uid"];
        if (uid) {
            
            [self ignoreTask:payloadDic];
            
            return YES;
        }
    }
    // 网关上的数据已不存在，这里的数据指所有数据，设备、情景、定时等
    else if(status == KReturnValueDataNotExist
            || status == KReturnValueBindInvalid
            || status == KReturnValueCannotFindBindInfo){

#pragma mark 26错误码 网关上的数据已不存在
#pragma mark 30、48错误码 服务器上没有绑定关系

        NSNumber *serialNo = [payloadDic objectForKey:@"serial"];
        [self cancelALTimeout:serialNo];
        BaseCmd *task = [self getTask:serialNo];
        
        if (task) {
            
            NSString *cls = NSStringFromClass([task class]);
            if (cmd == VIHOME_CMD_AUC
                || stringContainString(cls.lowercaseString, @"delete")) {
                
                status = KReturnValueSuccess; // 删除类型的指令，当做成功来处理
                
            }else if (cmd == VIHOME_CMD_MODIFY_REMOTE_BIND_NEW){ // Ember主机修改情景面板按键绑定
                
                status = KReturnValueFail; // 按照错误码1来处理 提示"按键设置已被修改"，并返回上一级 Fix Bug HM-5402
                
            }else if (task.isTransparent){ // SDK层不处理服务器的返回值(returnValue)，直接返回到上层处理
                status = KReturnValueDeviceDataInvalid;
            }
            else{
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:task.payload];
                dic[@"status"] = payloadDic[@"status"];
                DLog(@" ========= 服务器返回绑定相关数据 ： %@",dic);
                [self handleDataNotExist:dic]; // 其他类型的指令，返回上层统一处理
                return YES;
            }
            
        }
    }else if (status == KReturnValueNeedSyncData            // 主机数据已修改，请重新同步最新数据
              || status == KReturnValueNeedSyncServerData){ // 服务器数据已修改，请重新同步最新数据
#pragma mark 41错误码 主机数据已修改，请重新同步最新数据
#pragma mark 70错误码 服务器数据已修改，请重新同步最新数据
        
        __weak Gateway *weakSelf = self;
        
        DLog(@"主机数据已修改，请重新同步最新数据");
        
        NSNumber *serialNo = [payloadDic objectForKey:@"serial"];
        
        DLog(@"先取消超时，表数据同步完成之后再走超时重发路径");
        [self cancelALTimeout:serialNo];
        
        NSString *uid = payloadDic[@"uid"]?:@"";
        
        commonBlockWithObject readDataFinishBlock = ^(KReturnValue value, id object){
            
            BOOL success = (value == KReturnValueSuccess);
            
            DLog(@"网关:%@ 同步数据%@",uid,success ? @"成功" : @"失败");
            
            BaseCmd *task = [weakSelf getTask:serialNo];
            
            if (task) {
                
                task.needSyncData = YES;
                // 标记数据同步是否成功,成功之后才允许更新系统的lastupdateTime
                task.syncDataSuccess = success;
                if(success){
                    // 数据同步成功，发出通知，刷新数据
                    [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:object];
                }else{
                    DLog(@"数据同步失败也走重发路径");
                }
                
                // 门锁授权时同步完数据不重发授权命令
                if (cmd == VIHOME_CMD_AUU || cmd == VIHOME_CMD_AFR || cmd == VIHOME_CMD_SET_SECURITY_WARNING) {
                    
                    [self finishTaskWithStatus:KReturnValueSyncDataFinish dictionary:payloadDic];
                    
                }else{
                    [weakSelf resendCmd:task reason:KReturnValueTimeout];
                }
                
                
            }else{
                DLog(@"serialNo：%@ 任务被异常移除",serialNo);
            }
        };
        
        if (status == KReturnValueNeedSyncServerData) {
            
            NSArray *array = [payloadDic[@"tableNameList"]valueForKey:@"tableName"];
            [[RemoteGateway shareInstance]readTableWithUid:uid tableArray:array completion:^(KReturnValue value) {
                readDataFinishBlock(value,[NSSet setWithArray:array]);
            }];
            
        }else{
 
            DLog(@"读取当前family下面的所有数据");
            NSString *familyId = userAccout().familyId;
            [HMLoginAPI readDataInFamily:familyId completion:readDataFinishBlock];
        }
        
        return YES;
        
        /** 507：网络错误（目前针对浙江电信使用） */
    }else if (status == KReturnValueDeviceNetworkError){
        
        [self.delegate popAlertForTelecomDeviceNetworkError];
    }
    else if (cmd == VIHOME_CMD_DUN) { // 数据更新上报
#pragma mark 113号命令  数据更新上报
        __weak Gateway *weakSelf = self;
        
        DLog(@"接收到数据更新上报指令");
        
        // 如果不是当前家庭的数据更新上报，则不处理
        NSString *familyId = payloadDic[@"familyId"];
        if (!familyId) {
            DLog(@"接收到旧主机的数据更新上报，没有familyId信息，则不同步该主机的数据");
            return YES;
        }
        
        if (![familyId isEqualToString:userAccout().familyId]) {
            
            DLog(@"不是当前家庭的数据更新上报信息：familyId:%@ 当前家庭:%@",familyId,userAccout().familyId);
            return YES;
        }
        
        NSNumber *dataSource = payloadDic[@"dataSource"];
        if (dataSource && (dataSource.integerValue == 1)) {
            DLog(@"dataSource == 1 数据更新上报来自服务器，需要处理");
        }else{
            DLog(@"来自主机[uid=%@]的数据更新上报，2.5版本后不再处理",payloadDic[@"uid"]);
            return YES;
        }
        
        //发送通知查询messageSecurity表
        id messageTypeObj = payloadDic[@"messageType"];
        if (messageTypeObj && [messageTypeObj respondsToSelector:@selector(integerValue)]) {
            NSInteger messageType = [messageTypeObj integerValue];
            if (messageType == 1) {
                [HMBaseAPI postNotification:KNOTIFICATION_QUERY_MESSAGE_SECURITY object:nil];
            }
        }
        
        // 门磁、红外和门锁最后消息的数据单独记录，如果这个字段存在且为true，则需要更新最后消息表
        id lastMsgObj = payloadDic[@"lastTimeChanged"];
        if (lastMsgObj && [lastMsgObj respondsToSelector:@selector(boolValue)]) {
            BOOL lastTimeChanged = [lastMsgObj boolValue];
            if (lastTimeChanged) {
                [weakSelf queryLastestMsg];
                return YES;
            }
        }

        //数据更新完成
        commonBlockWithObject readDataFinishBlock = ^(KReturnValue value, id object){
            
            BOOL success = (value == KReturnValueSuccess);
            DLog(@"同步数据%@",success ? @"成功" : @"失败");
            if(success){
                // 数据同步成功，发出通知，刷新数据
                [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:object];
            }
        };
        
        
        int lastUpdateTime = [payloadDic[@"lastUpdateTime"]intValue];
        NSArray *tableNameList = payloadDic[@"tableNameList"];
        
        if (tableNameList && [tableNameList isKindOfClass:[NSArray class]]) {
            
            NSString *uid = payloadDic[@"uid"];
            NSMutableArray *array = [[tableNameList valueForKey:@"tableName"]mutableCopy];
            NSString *tableName = @"family";
            // 家庭表用4号命令无法读取，需要单独用接口查询
            if ([array containsObject:tableName]) {
                [array removeObject:tableName];
                [HMFamilyAPI queryFamilyListWithCompletion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                    if (array.count) {
                        [[RemoteGateway shareInstance]readTableWithUid:uid tableArray:array completion:^(KReturnValue value) {
                            readDataFinishBlock(value,[NSSet setWithArray:array]);
                        }];
                    }else{
                        readDataFinishBlock(returnValue,[NSSet setWithArray:@[tableName]]);
                    }
                }];
            }else{
                // 没有family表，则继续用4号命令读取数据
                [[RemoteGateway shareInstance]readTableWithUid:uid tableArray:array completion:^(KReturnValue value) {
                    readDataFinishBlock(value,[NSSet setWithArray:array]);
                }];
            }
        }else{
            
            // family 信息的数据更新
            
            int oldUpdateTime = getLastUpdateTime(userAccout().familyId).intValue;
            
            DLog(@"当前家庭的lastUpdateTime：%d 服务器的lastUpdateTime：%d",oldUpdateTime,lastUpdateTime);
            
            if (oldUpdateTime < lastUpdateTime) {
                
                DLog(@"读取当前家庭的所有表数据");
                [HMLoginAPI readDataInFamily:familyId completion:readDataFinishBlock];
                
            }else{
                DLog(@"本地更新时间大于或等于服务器更新时间，不需要同步数据");
            }
        }
        
        return YES;
    }
    else if (cmd == VIHOME_CMD_RK) { // 申请通信密钥
        
        // 申请通信密钥指令返回成功
        if (status == KReturnValueSuccess) {
            
            NSNumber *serialNo = [payloadDic objectForKey:@"serial"];
            BaseCmd *task = [self getTask:serialNo];
            
            if (task) {
                
                [self cancelALTimeout:serialNo];
                
                NSString *encryptionKey = [payloadDic objectForKey:@"key"];
                
                // 通信密钥让 socket 自己携带，本地的socket携带本地密钥，远程socket携带远程密钥
                
                socket.encryptionKey = encryptionKey;
                
                // 密钥，如果session未过期，则使用申请密钥时分配的 动态密钥key
                // 如果 session 过期，则返回的数据变成公钥加密，使用固定公钥解密
                NSData *sessionData = [data subdataWithRange:NSMakeRange(10, 32)];
                NSString *session = [[NSString alloc]initWithData:sessionData encoding:NSASCIIStringEncoding];
                socket.session = session;
                
                DLog(@"申请通信密钥获得的key:%@ session:%@",encryptionKey,session);
                
            }else{
                DLog(@"申请通信密钥task已超时被移除，需要重新申请通信密钥");
                socket.session = nil;
                socket.encryptionKey = nil;
            }
            
        }
        
    }else if(cmd == VIHOME_CMD_CL){ // 登录命令
#pragma mark 2号命令  登录返回结果
        // 登录成功，开始发送心跳包
        if (status == KReturnValueSuccess) {
            
            [self beginSendHeartbeat];
            
            if (self.loginType == LOCAL_LOGIN) {
                
                // 主机返回的登录结果中有家庭信息
                NSArray *familyList = payloadDic[@"familyList"];
                if (familyList && ([familyList isKindOfClass:[NSArray class]])) {
                    
                    NSDictionary *familyDic = familyList.firstObject;
                    if (familyDic) {
                        
                        // 登录主机返回的家庭 familyId 和 当前用户选择的 familyId 不同，则不认为登录成功，也不读表
                        NSString *familyId = familyDic[@"familyId"];
                        if (![familyId isEqualToString:userAccout().familyId]) {
                            
                            // 主机已被你的其他家庭绑定
                            status = KReturnValueHostHasBindByYourAnotherFamily;
                        }
                    }
                }
            }
        }
    }else if (cmd == VIHOME_CMD_QS){
        
        // 3号查询统计更新命令 返回主机正在升级 则显示主机在升级的弹框
        if (status == KReturnValueHostIsUpgrade) {
            
            // 0 ： 开始升级   1：升级结束，如果账号已没有主机，发送升级完成的通知，移除正在升级的View
            [HMBaseAPI postNotification:KKNOTIFICATION_UPGRADESTATUS object:@(0)];
            
            // 认为查询失败
            status = KReturnValueFail;
        }
    }
    else if(cmd == VIHOME_CMD_QD  // 旧的读表命令
            || cmd == VIHOME_CMD_QUERY_WIFI_DEVICE_DATA){ // wifi设备读表命令
        
        if(status == KReturnValueSuccess){
            
            [self didReceiveTableData:payloadDic];
        }
    }else if(cmd == VIHOME_CMD_ND){ // 新设备上报接口
#pragma mark 37号命令 新设备上报接口
        if(status == KReturnValueSuccess){
            
            [self saveNewDevice:payloadDic];
        }
        // 给delegate返回数据
        [self receiveDataCallback:payloadDic];
        return YES;
        
    }else if(cmd == VIHOME_CMD_PR){ // 设备属性报告接口
#pragma mark 42号命令 处理设备状态报告
        if(status == KReturnValueSuccess){
            [self savePrData:payloadDic];
        }
        
        return YES;
    }else if (cmd == VIHOME_CMD_DEVICE_PROPERTY_STATUS_REPORT) {
        
#pragma mark 286号命令 设备属性状态上报新接口
        if (status == KReturnValueSuccess) {
            [self handleNewStatusPropertyData:payloadDic];
        }
        return YES;
    }
    else if(cmd == VIHOME_CMD_OO){ // 设备上线掉线接口
#pragma mark 53号命令  设备上线掉线接口
        if(status == KReturnValueSuccess){
            [self saveDeviceOnlineAndOffline:payloadDic];
        }
        
        return YES;
    }
    else if(cmd == VIHOME_CMD_RA       // 添加遥控器绑定的结果
            || cmd == VIHOME_CMD_RM    // 修改遥控器绑定的结果
            || cmd == VIHOME_CMD_RD){  // 删除遥控器绑定的结果 zigbee
        
        if(status == KReturnValueSuccess){
            [self saveRemoteBind:payloadDic cmd:cmd];
        }
        
        return YES;
    }else if (cmd == VIHOME_CMD_LR){
        
#pragma mark  红外学习结果 zigbee
        
        if(status == KReturnValueSuccess){
            [self saveIRLearnResult:payloadDic];
        }
        return YES;
        
    }else if (cmd == VIHOME_CMD_INP){
        
#pragma mark 82号命令  接收到推送消息
        
        [self handlePushInfo:payloadDic];
        
        return YES;
    }else if (cmd == CLOTHESHORSE_CMD_STATUS_REPORT) {

#pragma mark  晾衣架状态反馈

        [self updateClothesHorseStatus:payloadDic];
        
        return YES;
        
    }else if (cmd == CLOTHESHORSE_CMD_COUNTDOWN_REPORT) {

#pragma mark  晾衣架倒计时上报

        [self updateCutDownData:payloadDic];
        
        return YES;
    }else if (cmd == VIHOME_CMD_MP
              || cmd == VIHOME_CMD_RESETPASSWORD) {
        
#pragma mark  密码修改成功,移除旧门锁的本地限制
        
        NSString *sql = [NSString stringWithFormat:@"select * from device where delFlag = 0 and deviceType = 21 and length(model) < 32 "];
        
        queryDatabase(sql, ^(FMResultSet *rs) {
            
            HMDevice *lock = [HMDevice object:rs];
            
            [self removeObjectWithKey:kDateKey(lock.extAddr)];
            [self removeObjectWithKey:kCountKey(lock.extAddr)];
        });
        
    }else if (cmd == VIHOME_CMD_IR_UPLOAD){

#pragma mark  wifi设备红外码上报

        if (status == KReturnValueSuccess) {
            [self saveWifiLearnResult:payloadDic];
        }
        
        return YES;
    }else if(cmd == VIHOME_CMD_UPGRADE_REPORT) {
    
        DLog(@"主机上报升级状态接口 %@",payloadDic);
        NSString * uid = [payloadDic objectForKey:@"uid"];
        // 如果该主机在当前家庭下，则推送通知，否则不通知
        if ([HMUserGatewayBind isHasBindUid:uid]) {
            [HMBaseAPI postNotification:KKNOTIFICATION_UPGRADESTATUS object:payloadDic];
        }
        
        return YES;
        
    }else if (cmd == VIHOME_SENSOR_DATA_REPORT) {

#pragma mark  cmd = 143 传感器数据上报接口

        [self updateSensorData:payloadDic];
        
        return YES;
        
    }else if (cmd == VIHOME_SENSOR_EVENT_REPORT) {

#pragma mark  传感器事件上报接口

        [self updateSensorEvent:payloadDic];
        
        return YES;
        
    } else if (cmd == VIHOME_CMD_DATA_UPLOAD) {

#pragma mark  数据上报接口
        
        [HMBaseAPI postNotification:KKNOTIFICATION_DATAUPLOAD object:payloadDic];

        return YES;

    } else if (cmd == VIHOME_CMD_WIFI_DEVICE_DELETED) {

#pragma mark  删除wifi设备/主机上报接口

        [self handleDevcieDeletedReport:payloadDic];
        
        return YES;
        
    } else if (cmd == VIHOME_CMD_SET_GROUP_MEMBER_RESULT){

#pragma mark  设置组成员上报接口 zigbee
        [HMBaseAPI postNotification:KNOTIFICATION_SET_GROUP_MEMBER_RESULT object:payloadDic];
        
    }else if (cmd == VIHOME_CMD_DISTRIBUTE_LAN_COMMUNICATION_KEY) {
        
#pragma mark  局域网密钥推送接口
        DLog(@"局域网密钥推送信息：%@",payloadDic);
        NSString *cryptKey = [payloadDic objectForKey:@"cryptKey"];
        NSString *familyId = [payloadDic objectForKey:@"familyId"];
        HMLanCommunicationKeyModel *lanKeyModel = [[HMLanCommunicationKeyModel alloc] init];
        lanKeyModel.lanCommunicationKey = cryptKey;
        lanKeyModel.familyId = familyId;
        [lanKeyModel insertObject];
        
    } else if (cmd == VIHOME_CMD_FU || cmd == VIHOME_CMD_OTA_PROCESS) {// wifi设备固件升级状态
        
        [HMBaseAPI postNotification:KKNOTIFICATION_OTA_PROCESS object:payloadDic];
                
        [[HMFirmwareDownloadManager manager] handleDeviceUpdatingData:payloadDic];

        
    }
    else if (cmd == VIHOME_CMD_QUERY_FAMILY
             || cmd == VIHOME_CMD_QUERY_LAST_MESSAGE
             || cmd == VIHOME_CMD_NEW_QUERY_AUTHORITY) {
        
#pragma mark  查询用户家庭接口-当家庭数量过多的时候，需要分页
#pragma mark  查询lastMessage接口-当lastMessage数量过多的时候，需要分页
#pragma mark  查询MixPad下面的设备权限，设备数量过多时，需要分页
        [self savePagingData:payloadDic];
        
        return YES;
        
    } else if (cmd == VIHOME_CMD_ONEKEY_LOGIN) {// 一键登录接口
        // 出现此错误码表示，当前登录的账号服务器IP和设备记录使用的域名都需要修改
        if (status == KReturnValuePhoneNumberIDCDifferent) {
            // 消息记录页URL
            [HMSDK memoryDict][@"recordUrl"] = payloadDic[@"recordUrl"];
        }
    }
    
    
    [self finishTaskWithStatus:status dictionary:payloadDic];
    
    return YES;
}


#pragma mark -任务完成处理
-(void)finishTaskWithStatus:(KReturnValue)status dictionary:(NSDictionary *)dic
{
    //LogFuncName();
    
    NSNumber *serialNo = [dic objectForKey:@"serial"];
    
    [self cancelALTimeout:serialNo];
    
    BaseCmd *task = [self getTask:serialNo];
    
    if (task) {
        if (task.finishBlock) {
            task.finishBlock(status,dic);
        }
        [self removeTask:task];
        
        DLog(@"finishTask:%@",task);
        
    }else{
        // 读表的时候，第一个包收到之后就会移除任务
        DLog(@"未查找到任务: serial = %@",serialNo);
    }
    
    // 给delegate返回数据
    [self receiveDataCallback:dic];
}

#pragma mark - 处理新设备入网上报
- (void)saveNewDevice:(NSDictionary*)dic
{
    DLog(@"===========有新设备入网===========");
    
    NSString *uidKey = @"uid";
    NSString *uid = dic[uidKey];
    
    if (![HMUserGatewayBind bindWithUid:uid]) {
        DLog(@"本地数据库没有此uid的绑定关系，忽略上报的数据");
        return;
    }
    NSMutableDictionary *deviceDic = [NSMutableDictionary dictionary]; // 设备表
    [deviceDic setDictionary:[dic[@"device"]lastObject]];
    deviceDic[uidKey] = uid;
    
    HMDevice *device = [HMDevice objectFromDictionary:deviceDic];
    if (isBlankString(device.deviceId)) {
        DLog(@"入网的zigbee设备deviceId 为空！返回，不插数据库  deviceId:%@",device.deviceId);
        return;
    }
    
    // 每有一个新设备上报，则需要先检查本地数据库是否已经有
    // 残留的旧数据，如果有则先删除本地数据再插入新数据
    
    // 三路继电器可能会拨码成为窗帘
    if (device.deviceType == KDeviceTypeCurtain
        || device.deviceType == KDeviceTypeInfraredRelay) { // 红外转发器要把所有的虚拟设备都删除
        
        NSString *sql =[NSString stringWithFormat:@"delete from device where uid = '%@' and extAddr = '%@'",uid,device.extAddr];
        [[HMDatabaseManager shareDatabase] executeUpdate:sql];
        
    }else{
        if(device.deviceType != KDeviceTypeOrviboLock){//T1 门锁组网进来，主机上报的数据没有蓝牙地址，这里组网进来，以服务器的数据为准，这里不处理T1智能门锁
            // 对应同一个设备上报多次时需要先删除旧数据
            // 删除后触发器会删除关联内容
            [device deleteObjectOnSearchDevice];
        }
    }
    
    if(device.deviceType != KDeviceTypeOrviboLock){
        [device insertObject];
    }
    
    // 设备状态表
    NSMutableDictionary *deviceStatusDic = [NSMutableDictionary dictionary];
    [deviceStatusDic setDictionary:[dic[@"deviceStatus"]lastObject]];
    deviceStatusDic[uidKey] = uid;
    
    HMDeviceStatus *deviceStatus = [HMDeviceStatus objectFromDictionary:deviceStatusDic];
    [deviceStatus insertObject];
    
    
    // 设备入网信息表
    NSMutableDictionary *deviceJoinInDic = [NSMutableDictionary dictionary];
    [deviceJoinInDic setDictionary:[dic[@"deviceJoinIn"]lastObject]];
    deviceJoinInDic[uidKey] = uid;
    
    HMDeviceJoinIn *deviceJoinIn = [HMDeviceJoinIn objectFromDictionary:deviceJoinInDic];
    [deviceJoinIn insertObject];
    
    
    // 常用模式表
    
    NSArray *frequentlyModeArray = dic[@"frequentlyMode"];
    for (NSDictionary *dic in frequentlyModeArray) {
        
        NSMutableDictionary *frequentlyModeDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        frequentlyModeDic[uidKey] = uid;
        
        HMFrequentlyModeModel *frequentlyMode = [HMFrequentlyModeModel objectFromDictionary:frequentlyModeDic];
        [frequentlyMode insertObject];
    }
    
    // 传感器的联动条件表
    NSArray *linkageConditionArray = dic[@"linkageCondition"];
    for (NSDictionary *dic in linkageConditionArray){
        
        NSMutableDictionary *linkageConditionDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        linkageConditionDic[uidKey] = uid;
        HMLinkageCondition *linkageCondition = [HMLinkageCondition objectFromDictionary:linkageConditionDic];
        [linkageCondition insertObject];
    }

    DLog(@"有新设备入网 名称：%@ ,extAddr = %@",device.deviceName,device.extAddr);
    // 发出通知，有新设备入网
    [HMBaseAPI postNotification:kNOTIFICATION_NEW_DEVICE_REPORT object:device];

    // 发现新的中央空调面板设备，发出通知
    NSNumber *reportType = [dic objectForKey:@"reportType"];
    if (reportType && reportType.intValue == 1) {
        if ([HMUserGatewayBind bindWithUid:device.uid]) {
            [self.delegate showVRVReportView:device.deviceName];
        }else {
            DLog(@"不处于加中央空调的家庭，不弹");
        }
    }
}
#pragma mark 42号命令 处理设备状态报告
- (void)savePrData:(NSDictionary*)dic
{
    if (userAccout().isWidget) {
        HMDeviceStatus *status = [HMDeviceStatus objectFromDictionary:dic];
        status.online = YES;
        [self updateDeviceStatus:status];// 发出通知
        return;
    }

    
    int statusType = [dic[@"statusType"] intValue];
    // 配电箱非开关属性报告处理
    if (statusType == KDeviceTypeOldDistBox || statusType == KDeviceTypeNewDistBox) {
        [self handleDistBoxStatusReportWithDic:dic];
    }
    
    NSString * deviceId = dic[@"deviceId"];
    
    // 保存设备状态
    HMDeviceStatus *deviceStatus = [HMDeviceStatus saveProperty:dic];
    deviceStatus.statusType = [dic[@"statusType"]intValue];
    //deviceStatus.serialNumber = [dic[@"serial"]intValue];
    if (!deviceStatus) {
        DLog(@"设备不存在，客户端没有当前设备的记录");
    }else{
        
        // 取消控制命令的loading
        NSArray *cmdArray = self.taskQueue.allValues;
        if (cmdArray.count){
            if ([deviceId isEqualToString:@"0"]) { // coco ，s20等Wifi设备
                deviceId = deviceStatus.deviceId;
            }
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"cmd = %d and deviceId = %@",VIHOME_CMD_CD,deviceId];
            NSArray *controlCmds = [cmdArray filteredArrayUsingPredicate:pred];
            for (ControlDeviceCmd *controlCmd in controlCmds) {
                
                DLog(@"先接收到属性报告，后接收到控制命令");
                [self finishTaskWithStatus:KReturnValueSuccess dictionary:controlCmd.payload];
            }
        }
        
    }
    
    // 发出通知
    [self updateDeviceStatus:deviceStatus];
}

#pragma mark - 处理286号命令 - 新属性报告
- (void)handleNewStatusPropertyData:(NSDictionary*)dic {
    NSArray *statusList = dic[@"statusList"];
    for (NSDictionary *statusDic in statusList) {
        HMDevicePropertyStatus *statusModel = [[HMDevicePropertyStatus alloc] init];
        statusModel.property = statusDic[@"property"];
        statusModel.deviceId = statusDic[@"deviceId"];
        statusModel.uid = dic[@"uid"];
        statusModel.value = statusDic[@"value"];
        [statusModel insertObject];
    }
    [HMBaseAPI postNotification:kNOTIFICATION_DEVICE_PROPERTY_STATUS_REPORT object:dic];
}

#pragma mark - 处理设备上线/掉线报告
-(void)saveDeviceOnlineAndOffline:(NSDictionary*)dic
{
    LogFuncName();
    
    NSString *uid = [dic objectForKey:@"uid"];
    NSString * deviceId = [dic objectForKey:@"deviceId"];
    int online = [[dic objectForKey:@"online"]intValue];
    
    // Zigbee 设备
    if (![deviceId isEqualToString:@"0"]) {
        
        // == 0 是wifi设备； != 0 是Zigbee设备
        HMDevice *device = [HMDevice objectWithDeviceId:deviceId uid:uid];
        
        DLog(@"%@",device);
        // 如果是紧急按钮，就只更新在线状态，不更新是否报警和updateTime
        if (device.deviceType == KDeviceTypeEmergencyButton) {

            NSString *emergencySql = [NSString stringWithFormat:@"update deviceStatus set online = %d where uid = '%@' and deviceId = '%@'",online,uid,deviceId];
            updateInsertDatabase(emergencySql);
            
            DLog(@"紧急按钮只更新 online 字段，不发属性报告上报的通知，防止误报警");
            
            return;
        }
    }
    
    NSString *updateTime = [dic objectForKey:@"updateTime"];
    
    NSString *sql = [NSString stringWithFormat:@"update deviceStatus set online = %d,updateTime = '%@' "
                     "where uid = '%@' and deviceId = '%@'",online,updateTime?:currentTime(),uid,deviceId];
    
    updateInsertDatabase(sql);
    
    HMDeviceStatus *deviceStatus = [HMDeviceStatus objectWithDeviceId:deviceId uid:uid];
    if (!deviceStatus) {
        deviceStatus = [HMDeviceStatus objectFromDictionary:dic];
    }
    [self updateDeviceStatus:deviceStatus];
}

#pragma mark - 处理情景绑定 添加、删除、修改
-(void)saveSceneBind:(NSDictionary*)dic cmd:(VIHOME_CMD)cmd
{
    LogFuncName();
    
    // 给gateway 返回响应

    NSArray *successList = [dic objectForKey:@"successList"];
    
    if (successList.count) {
        
        if (cmd == VIHOME_CMD_SCENE_SERVICE_ADD_BIND) { // 添加情景的结果
            
            for (NSDictionary *bindDic in successList) {
                
                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];

                HMSceneBind *bind = [HMSceneBind objectFromDictionary:realDic];
                [bind insertObject];
                
            }
            
        }else if (cmd == VIHOME_CMD_SCENE_SERVICE_MODIFY_BIND) { // 修改情景的结果
            
            for (NSDictionary *bindDic in successList) {
                
                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];

                HMSceneBind *bind = [HMSceneBind objectFromDictionary:realDic];
                if (!bind.updateTime.length) {
                    bind.updateTime = [dic objectForKey:@"updateTime"];
                }
                [bind updateObject];
                
            }
            
        }else if (cmd == VIHOME_CMD_SCENE_SERVICE_DELETE_BIND) { // 删除情景的结果
            
            NSMutableArray *bindIDArray = [NSMutableArray array];
            for(NSDictionary * dic in successList){
                
                NSString *bindId = dic[@"sceneBindId"];
                [bindIDArray addObject:[NSString stringWithFormat:@"'%@'",bindId]];
            }
            NSString *bindIDs = [bindIDArray componentsJoinedByString:@","];
            NSString *sql = [NSString stringWithFormat:@"delete from sceneBind where "
                             "sceneBindId in (%@)", bindIDs];
            updateInsertDatabase(sql);
        }
    }
    
    [HMBaseAPI postNotification:kNOTIFICATION_SCENE_BIND_RESULT object:dic];
    
}


-(void)updateDeviceStatus:(HMDeviceStatus*)deviceStatus
{
    LogFuncName();
    
    if (deviceStatus) {
        // 发出通知，设备状态更新
        if (deviceStatus.statusType == KDeviceTypeSingleFireSwitch) {
            return; // 属于单火开关报警类型，不处理
        }
        [HMBaseAPI postNotification:kNOTIFICATION_DEVICE_STATUS_REPORT object:deviceStatus];
    }
}


#pragma mark - 处理遥控器绑定 添加、删除、修改
-(void)saveRemoteBind:(NSDictionary*)dic cmd:(VIHOME_CMD)cmd
{
    LogFuncName();
    
    
    NSString *uid = [dic objectForKey:@"uid"];
    NSArray *successList = [dic objectForKey:@"successList"];
    //NSArray *failList = [dic objectForKey:@"failList"];
    
    if (successList.count) {
        
        if (cmd == VIHOME_CMD_RA) { // 添加遥控器绑定的结果
            
            for (NSDictionary *bindDic in successList) {
                
                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];
                [realDic setObject:uid forKey:@"uid"];
                
                HMRemoteBind *bind = [HMRemoteBind objectFromDictionary:realDic];
                [bind insertObject];
                
            }
            
        }else if (cmd == VIHOME_CMD_RM) { // 修改遥控器绑定的结果
            
            for (NSDictionary *bindDic in successList) {
                
                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];
                [realDic setObject:uid forKey:@"uid"];
                
                HMRemoteBind *bind = [HMRemoteBind objectFromDictionary:realDic];
                [bind updateObject];
                
            }
            
        }else if (cmd == VIHOME_CMD_RD) { // 删除遥控器绑定的结果
            
            NSMutableArray *bindIDArray = [NSMutableArray array];
            for(NSDictionary * dic in successList){
                NSNumber *bindIdNumber = [dic objectForKey:@"remoteBindId"];
                NSString *bindId = [NSString stringWithFormat:@"'%@'",bindIdNumber];
                [bindIDArray addObject:bindId];
            }
            NSString *bindIDs = [bindIDArray componentsJoinedByString:@","];
            NSString *sql = [NSString stringWithFormat:@"delete from remoteBind where "
                             "uid = '%@' and remoteBindId in (%@)",uid,bindIDs];
            updateInsertDatabase(sql);
        }
        
    }
    [HMBaseAPI postNotification:kNOTIFICATION_REMOTE_CONTROL_RESULT object:dic];
    
}

#pragma mark - zigbee红外码上报结果

- (void)saveIRLearnResult:(NSDictionary *)IRResultDic
{
    LogFuncName();
    
    HMDeviceIr * IRObject = [HMDeviceIr objectFromDictionary:IRResultDic];
    if (IRObject) {
        HMDevice * device = [HMDevice objectWithDeviceId:IRObject.deviceId uid:IRObject.uid];
        if (device.deviceType == KDeviceTypeCustomerInfrared) {
            [IRObject updateObjectWithDeviceID];
        }else{
            [IRObject insertObject];
        }
    }
    
    [HMBaseAPI postNotification:KNOTIFICATION_DEVICE_IR_LEARN_RESULT object:IRObject];
}

#pragma mark -wifi(Allone)红外码上报
- (void)saveWifiLearnResult:(NSDictionary *)irDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    HMKKDevice *kkDevice = [HMKKDevice objectFromDictionary:[irDic objectForKey:@"kkDevice"]];
    HMKKIr *kkIr = [HMKKIr objectFromDictionary:[irDic objectForKey:@"kkIr"]];
    if (kkDevice) {
        [kkDevice insertObject];
        [dic setObject:kkDevice forKey:@"kkDevice"];
    }
    if (kkIr) {
        [kkIr insertObject];
        [dic setObject:kkIr forKey:@"kkIr"];
    }
    [HMBaseAPI postNotification:KNOTIFICATION_DEVICE_IR_UPLOAD object:dic];
}

#pragma mark - 处理晾衣架状态反馈信息

- (void)updateClothesHorseStatus:(NSDictionary *)resultDic
{
    LogFuncName();
    
    HMClotheshorseStatus *chStatus = [HMClotheshorseStatus objectFromDictionary:resultDic];
    [chStatus updateObject];
    [HMBaseAPI postNotification:KNOTIFICATION_CLOTHESHORSE_STATUS_REPORT object:chStatus];
}

#pragma mark - 处理晾衣架倒计时上报结果

- (void)updateCutDownData:(NSDictionary *)resultDic
{
    LogFuncName();
    
    HMClotheshorseCutdown *chCutDown = [HMClotheshorseCutdown objectFromDictionary:resultDic];
    [chCutDown updateObject];
    [HMBaseAPI postNotification:KNOTIFICATION_CLOTHESHORSE_COUNTDOWN_REPORT object:chCutDown];
}

#pragma mark -处理传感器数据上报143命令
- (void)updateSensorData:(NSDictionary *)resultDic
{
    LogFuncName();
    HMSensorData *sensorData = [HMSensorData sensorDataWithDictionary:resultDic];
    [sensorData updateObject];
    [HMBaseAPI postNotification:KNOTIFICATION_SENSOR_DATA_REPORT object:sensorData];
}

#pragma mark - 处理传感器事件上报命令

- (void)updateSensorEvent:(NSDictionary *)resultDic {

    LogFuncName();
    HMSensorEvent *sensorEvent = [HMSensorEvent sensorEventWithDictionary:resultDic];
    [sensorEvent updateObject];
    [HMBaseAPI postNotification:KNOTIFICATION_SENSOR_EVENT_REPORT object:sensorEvent];
}

#pragma mark  查询用户家庭接口-当家庭数量过多的时候，需要分页
- (void)savePagingData:(NSDictionary *)dic {
    
    LogFuncName();
    
    NSNumber *serialNo = dic[@"serial"];
    
    [self cancelALTimeout:serialNo];
    
    BaseCmd *task = [self getTask:serialNo];
    
    
    if (task) {
        
        NSString *dataKey = @"familyList";
        if (task.cmd == VIHOME_CMD_QUERY_LAST_MESSAGE
            || task.cmd == VIHOME_CMD_NEW_QUERY_AUTHORITY){
            dataKey = @"data"; // 不同的cmd对应的数组key值不同
        }
        
        // 记录家庭列表数据
        NSArray *dataList = dic[dataKey];
        DLog(@"指令%@ 分页数据接收条数：%d",NSStringFromClass([task class]),(int)dataList.count);
        if (!task.pagingArray) {
            task.pagingArray = [dataList mutableCopy];
        }else{
            [task.pagingArray addObjectsFromArray:dataList];
        }
        
         NSNumber *total = dic[@"total"];
        // 数据未接收完成
        if (total.intValue > task.pagingArray.count && dataList.count) {
            [self removeTask:task];
            
            if (task.cmd == VIHOME_CMD_QUERY_LAST_MESSAGE) {
                [self insertDatabase:dataList];
            }
            DLog(@"指令%@ 分页数据未接收完成，总条数：%@，已请求条数：%d 继续请求下一页数据",NSStringFromClass([task class]),total,(int)task.pagingArray.count);
            task.start = @(task.pagingArray.count);
            [task updateSerialNo];
            [self didSendCmd:task completion:task.finishBlock];
        }else{
            // 数据接收完成
            DLog(@"指令%@ 分页数据已接收完成，总条数：%@=%d",NSStringFromClass([task class]),total,(int)task.pagingArray.count);
            if (task.finishBlock) {
                int status = [dic[@"status"] intValue];
                NSMutableDictionary *mdic = [dic mutableCopy];
                mdic[dataKey] = task.pagingArray;
                task.finishBlock(status,mdic);
            }
            [self removeTask:task];
            DLog(@"finishTask:%@",task);
        }
    }else{
        // 读表的时候，第一个包收到之后就会移除任务
        DLog(@"未查找到任务: serial = %@",serialNo);
    }
}

// 传感器messageLast数据即时刷新插入数据库
-(void)insertDatabase:(NSArray *)datas{
    [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
        for (NSDictionary *lastMsgDic in datas) {
            HMMessageLast *msgLastModel = [HMMessageLast objectFromDictionary:lastMsgDic];
            [objectArray addObject:msgLastModel];
        }
    } completion:^{
        [HMBaseAPI postNotification:KNOTIFICATION_REFRESH_LASTEST_MESSAGE object:nil];
    }];
}
#pragma mark - -----------------------接收数据 --- end -----------------------
@end

//
//  RemoteGateway+WiFi.m
//  HomeMate
//
//  Created by Air on 16/7/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RemoteGateway+WiFi.h"
#import "Gateway+RT.h"
#import "HMConstant.h"
#import "QueryWiFiDataCmd.h"

@interface HMWiFiTableTask : NSObject

@property (nonatomic,assign) BOOL finish;

@property (nonatomic,assign) int tryTimes;
@property (nonatomic,assign) int totalPages;

@property (nonatomic,strong) NSString *familyId;
@property (nonatomic,strong) BaseCmd *readTableCmd;
@property (nonatomic,strong) BaseCmd *lostPageCmd;

@property (nonatomic,strong) NSString *updateTime;
@property (nonatomic,strong) NSString *lastUpdateTime;

@property (nonatomic, strong) NSNumber *updateTimeSec;


@property (nonatomic,strong) NSDictionary *tableInfo;
@property (nonatomic,strong) NSMutableArray *pageArray;
@property (nonatomic,strong) NSMutableArray *blockArray;
@property (nonatomic,strong) NSMutableSet *tableNameSet;

-(NSArray *)lostPageArray;
-(BOOL)getTheLastPage;
-(void)receiveTableData:(NSDictionary *)dic;
-(void)updateReadWifiTableTime:(NSDictionary *)dictionary;
+(HMWiFiTableTask *)taskWithFamilyId:(NSString *)familyId block:(commonBlockWithObject)block;

@end

@implementation HMWiFiTableTask
@synthesize lastUpdateTime = _lastUpdateTime;

#pragma mark - 生成读取所有WiFi设备数据表的task

+(HMWiFiTableTask *)taskWithFamilyId:(NSString *)familyId block:(commonBlockWithObject)block
{
    HMWiFiTableTask *task = [[self alloc]init];
    task.familyId = familyId;
    task.tryTimes = 0;
    task.pageArray = [NSMutableArray array];
    task.blockArray = [NSMutableArray array];
    task.tableNameSet = [NSMutableSet set];
    [task.blockArray addObject:block];
    
    return task;
}

#pragma mark - 读取整张表
-(BaseCmd *)readTableCmd
{
    if (!_readTableCmd) {
        QueryWiFiDataCmd *cmd = [QueryWiFiDataCmd object];
        cmd.userId = userAccout().userId;
        cmd.familyId = self.familyId;
        cmd.userName = userAccout().userName;
        cmd.PageIndex = 0;//PageIndex为0的时候是读取整张表
        cmd.dataType = @"all";
        cmd.LastUpdateTime = secondWithString([self lastUpdateTime]);
        cmd.sendToServer = YES;
        cmd.resendTimes = 3;
        _readTableCmd = cmd;
    }
    return _readTableCmd;
}

#pragma mark - 读取丢失的指定页
-(BaseCmd *)lostPageCmd
{
    NSArray *lossArray = [self lostPageArray];
    if (lossArray.count) {
        int page = [[lossArray firstObject]intValue];
        
        QueryWiFiDataCmd *cmd = [QueryWiFiDataCmd object];
        cmd.userId = userAccout().userId;
        cmd.familyId = self.familyId;
        cmd.userName = userAccout().userName;
        cmd.PageIndex = page;//PageIndex不为0的时候是读取指定页的数据
        cmd.dataType = @"all";
        cmd.LastUpdateTime = secondWithString([self lastUpdateTime]);
        cmd.sendToServer = YES;
        
        return cmd;
    }
    return nil;
}

-(NSArray *)lostPageArray
{
    if (!self.finish) {
        
        NSMutableArray *allPacketArray = [NSMutableArray array];
        for (int i = 1; i <= self.totalPages ; i ++) {
            [allPacketArray addObject:[NSNumber numberWithInt:i]];
        }
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT self in %@",self.pageArray];
        NSArray *array = [allPacketArray filteredArrayUsingPredicate:pred];
        
        DLog(@"丢失掉的包序号：%@",array);
        return array;
    }
    return nil;
}

-(BOOL)finish
{
    return (self.pageArray.count == self.totalPages);
}
-(BOOL)getTheLastPage
{
    if (self.totalPages == 0) {
        return YES;//没有数据
    }
    // PageIndex 从1开始
    NSNumber *lastPage = @(self.totalPages);
    return [self.pageArray containsObject:lastPage];
}

-(NSDictionary *)tableInfo
{
    return @{@"familyId":self.familyId};
}

-(void)receiveTableData:(NSDictionary *)dic
{
    NSNumber *page = dic[@"pageIndex"];
    NSNumber *totalPage = dic[@"tPage"];
    
    if (totalPage) {
        self.totalPages = [totalPage intValue];
    }
    
    if (self.totalPages == 0) { // 没有数据
        [self.pageArray removeAllObjects];
        return;
    }
    DLog(@"familyId:%@ 接收到%@号包 总共%d个数据包",self.familyId,page,self.totalPages);
    if (![self.pageArray containsObject:page]) {
        
        DLog(@"familyId:%@ %@号包添加到数组",self.familyId,page);
        
        [self.pageArray addObject:page];
        
        NSArray *tableNameList = dic[@"tableNameList"];
        if ([tableNameList isKindOfClass:[NSArray class]]) {
            [self.tableNameSet addObjectsFromArray:tableNameList];
        }
    }
}

-(void)updateReadWifiTableTime:(NSDictionary *)dictionary
{
    //LogFuncName();
    
    NSNumber *updateTimeSec = [dictionary objectForKey:@"updateTimeSec"];
    if (updateTimeSec) {
        if (updateTimeSec.integerValue > self.updateTimeSec.integerValue) {
            self.updateTimeSec = updateTimeSec;
        }
        
    }else{
        
        NSString *currentUpdateTime = dictionary[@"updateTime"];
        NSString *oldUpdateTime = self.updateTime ?:[self lastUpdateTime];
        
        // 如果 oldUpdateTime 是NSNumber 比较会崩溃
        if (oldUpdateTime && (![oldUpdateTime isKindOfClass:[NSString class]])) {
            oldUpdateTime = dateStringWithSec(oldUpdateTime);
        }
        
        NSComparisonResult compareResult = [currentUpdateTime compare:oldUpdateTime];
        if (compareResult == NSOrderedDescending) {
            
            self.updateTime = currentUpdateTime;
        }
    }
}

-(NSString *)lastUpdateTimeKey
{
    // 根据 uid, tableName 作为key值保存lastUpdateTime
    NSString *lastTimeKey = [NSString stringWithFormat:@"UpdateTimeKey_%@_%@_%@",self.familyId,@"ReadAllWiFiData",kDbVersion];
    DLog(@"%@",lastTimeKey);
    
    return lastTimeKey;
}

-(NSString *)lastUpdateTimeSecKey
{
    NSString *lastUpdateTimeSecKey = [NSString stringWithFormat:@"UpdateTimeSecKey_%@_%@_%@",self.familyId,@"ReadAllWiFiData",kDbVersion];
    DLog(@"%@",lastUpdateTimeSecKey);
    return lastUpdateTimeSecKey;
}

-(void)setLastUpdateTime:(NSString *)lastUpdateTime
{
    if (lastUpdateTime != _lastUpdateTime) {
        
        _lastUpdateTime = lastUpdateTime;
    }
    
    NSString *keyOfLastUpdateTime = [self lastUpdateTimeKey];
    
    if (_lastUpdateTime) {
        
        DLog(@"保存lastUpdateTime:%@ key:%@",_lastUpdateTime,keyOfLastUpdateTime);
        [self saveObject:_lastUpdateTime withKey:keyOfLastUpdateTime];
    }else{
        DLog(@"移除lastUpdateTime familyId:%@",self.familyId);
        [self removeObjectWithKey:keyOfLastUpdateTime];
    }
}

-(NSString *)lastUpdateTime
{
    if (!_lastUpdateTime) {
        
        NSString *lastTimeSecKey = [self lastUpdateTimeSecKey];
        NSString *lastTimeSec = [self objectWithKey:lastTimeSecKey]; // 实际上如果存在应该是nsnumber类型
        
        if (lastTimeSec) {
            _lastUpdateTime = lastTimeSec;
        }else{
            _lastUpdateTime = [self objectWithKey:[self lastUpdateTimeKey]];
        }
        
        DLog(@"获取lastUpdateTime: %@ familyId:%@",_lastUpdateTime,self.familyId);
    }
    return _lastUpdateTime;
}

-(void)saveLastUpdateTime
{
    if (self.updateTime) {
        
        DLog(@"保存lastUpdateTime familyId == %@ 旧lastUpdateTime：%@ 新lastUpdateTime：%@",self.familyId,self.lastUpdateTime,self.updateTime);
        
        // 使用set方法来保存
        self.lastUpdateTime = self.updateTime;
    }
    
    if (self.updateTimeSec) {
        
        NSString *lastTimeSecKey = [self lastUpdateTimeSecKey];
        
        DLog(@"保存updateTimeSec ：%@ key:%@",self.updateTimeSec,lastTimeSecKey);
        
        // 不使用set方法来保存
        [self saveObject:self.updateTimeSec withKey:lastTimeSecKey];
        // 此处不能用set方法,实际上NSNumber类型
        _lastUpdateTime = (NSString *)self.updateTimeSec;
    }
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"familyId: %@",self.familyId];
}
@end

@implementation RemoteGateway (WiFi)

-(HMWiFiTableTask *)taskWithFamilyId:(NSString *)familyId
{
    LogFuncName();
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.familyId = %@",familyId];
    NSArray *findArray = [self.wifiTableQueue filteredArrayUsingPredicate:pred];
    
    return [findArray firstObject];
}

-(void)readWifiTableWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    LogFuncName();
    
    // 是否存在一个读取当前表的task
    HMWiFiTableTask *task = [self taskWithFamilyId:familyId];
    if(task == nil){// 如果不存在则新建一个任务
        
        task = [HMWiFiTableTask taskWithFamilyId:familyId block:completion];
        [self.wifiTableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        [self readWifiTableWithTask:task];
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
    
    
}
#pragma mark - 读表操作
-(void)readWifiTableWithTask:(HMWiFiTableTask *)task
{
    LogFuncName();
    
    [self cancelTimeoutWithWifiTableInfo:task.tableInfo]; // 取消 之前的超时操作
    
    // 添加新的超时操作，
    // 读表命令发出后，如果3秒还没有表数据返回（注意不是读表命令的默认返回，而是真实的表数据），则重发
    [self addTimeoutWithWifiTableInfo:task.tableInfo];
    
    task.tryTimes += 1;// 增加当前task的尝试次数，如果再次失败，依据此值决定是否继续重读
    
    /*
     读表命令，不是一条命令一个返回值类型，可能是发送一条读表命令，返回多页结果
     针对这种情况，发送读表命令后，一旦接收到表数据时会自动调用函数
     -(void)didReceiveTableData:(NSDictionary *)dic 来处理
     此处不返回结果，等待上面的函数被调用，否则走超时路径
     */
    [self sendCmd:task.readTableCmd completion:^(KReturnValue returnValue, NSDictionary *dic) {
        //DLog(@"结果信息%@",dic);
        // 读表命令成功
        if (returnValue == KReturnValueSuccess) {
            
            DLog(@"读取familyId:%@ 命令返回成功",task.familyId);
            
        }else{ // 读表命令失败，等待走超时路径
            
        }
    }];
}

-(void)readWifiTableSuccess:(HMWiFiTableTask *)task
{
    LogFuncName();
    
    if (task) { // 表数据读取成功
        DLog(@"%@",task);
        
        [task saveLastUpdateTime];
        [self cancelTimeoutWithWifiTableInfo:task.tableInfo];
        
        for (commonBlockWithObject finishBlock in task.blockArray) {
            finishBlock(KReturnValueSuccess,task.tableNameSet);
        }
        
        if ([self.wifiTableQueue containsObject:task]) {
            [self.wifiTableQueue removeObject:task];
        }
    }else{
        DLog(@"未成功获取task");
    }
    
}
-(void)readWifiTableFailed:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    //[self clearTableData]; // 清理内存
    NSString *familyId = tableInfo[@"familyId"];
    
    HMWiFiTableTask *task = [self taskWithFamilyId:familyId];
    
    if (task) {
        
        DLog(@"%@",task);
        
        if (task.tryTimes < kReadTableMaxTryTimes) {
            
            DLog(@"尝试读表%d次",task.tryTimes);
            [self readWifiTableWithTask:task];
            
        }else {
            
            for (commonBlockWithObject finishBlock in task.blockArray) {
                finishBlock(KReturnValueSuccess,task.tableNameSet);
            }
            
            if ([self.wifiTableQueue containsObject:task]) {
                [self.wifiTableQueue removeObject:task];
            }
        }
        
    }else {
        DLog(@"读表%@ 任务已经被取消",tableInfo);
    }
    
}

-(void)addTimeoutWithWifiTableInfo:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    DLog(@"读表familyId: %@ 添加超时",tableInfo[@"familyId"]);
    // 先取消旧的超时函数，防止超时函数会被执行多次
    //[self cancelTimeoutWithTableName:tableName];
    
    SEL selector = @selector(readWifiTableFailed:);
    [self performSelector:selector withObject:tableInfo afterDelay: kReadTableTimeOut];
}
-(void)cancelTimeoutWithWifiTableInfo:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    SEL selector = @selector(readWifiTableFailed:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:tableInfo];
}

#pragma mark - 丢包时的处理函数
-(void)lossPageWithWifiTableTask:(HMWiFiTableTask *)task
{
    LogFuncName();
    
    [self cancelTimeoutWithWifiTableInfo:task.tableInfo]; // 取消 之前的超时操作
    [self addTimeoutWithWifiTableInfo:task.tableInfo];;       // 添加 新的超时操作
    BaseCmd *cmd = task.lostPageCmd;
    if (cmd) {
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *dic) {
            
            //DLog(@"结果信息%@",dic);
            // 读表命令成功
            if (returnValue == KReturnValueSuccess) {
                
                DLog(@"读表familyId:%@ 命令返回成功",task.familyId);
                
            }else{ // 读表命令失败，等待走超时路径
                //[weakSelf cancelTimeoutWithTableName:task.tableName]; // 取消超时操作
                //[weakSelf readTableFailed:task.tableName]; // 读表未读完失败
            }
        });
    }
}

#pragma mark - 接收到wifi设备表数据
-(void)didReceiveWifiTableData:(NSDictionary *)dic
{
    LogFuncName();
    
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        
        int cmd = [[dic objectForKey:@"cmd"]intValue];
        if (cmd == VIHOME_CMD_QUERY_WIFI_DEVICE_DATA) { // 读取所有WIFI表数据

            NSString *familyId = dic[@"familyId"]?:userAccout().familyId;
            if (!familyId) {
                DLog(@"familyId 数据异常");
                [self saveWifiTableDataAnyway:dic];
                return;
            }
            
            if (dic[@"security"]) {  // 如果为安防表，需要更新 widget 中的数据
                [HMBaseAPI postNotification:kNOTIFICATION_WIDGET_SECURITY_DATA_RELOAD object:dic];
            }
            
            NSDictionary *tableInfo = @{@"familyId":familyId};
            
            // 接收到真实表数据之后先取消旧的超时，再添加新的超时，防止接收到一半时出故障卡死
            [self cancelTimeoutWithWifiTableInfo:tableInfo];
            HMWiFiTableTask *task = [self taskWithFamilyId:familyId];
            
            if (task) { // 有读表任务未完成
                
                DLog(@"查找到任务%@",task);
                [task receiveTableData:dic];
                [self saveWifiTableData:dic task:task];
                //如果最后一个包一直收不到，则不会进入后续处理，会走超时重读路径
                if ([task getTheLastPage]) {
                    if (task.finish) { // 所有数据全部接收完成
                        [self readWifiTableSuccess:task];
                    }else { // 有数据包丢失（非最后一个包丢失）
                        [self lossPageWithWifiTableTask:task]; // 丢掉某些包的处理
                    }
                }else { // 添加超时，等待其他页数据返回，规定时间未返回则走超时路径
                    [self addTimeoutWithWifiTableInfo:tableInfo];
                }
            }else{
                DLog(@"未查找到任务");
                [self saveWifiTableDataAnyway:dic];
            }
        }
    }
}


#pragma mark - 保存表数据到本地

-(void)saveWifiTableData:(NSDictionary *)dic task:(HMWiFiTableTask *)task
{
    LogFuncName();
    [self asyncSaveTableData:dic task:task];
}

-(void)saveWifiTableDataAnyway:(NSDictionary *)dic
{
    LogFuncName();
    [self asyncSaveTableData:dic task:nil];
}

-(void)asyncSaveTableData:(NSDictionary *)dic task:(HMWiFiTableTask *)task
{
    [[HMDatabaseManager shareDatabase]inSerialQueue:^{
        
        NSArray *tableNameList = [dic objectForKey:@"tableNameList"];
        
        if (tableNameList && [tableNameList isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *objectsArray = [NSMutableArray array];
            
            for (NSString *tableName in tableNameList) {
                
                DLog(@"接收到%@表数据",tableName);
                NSArray *array = dic[tableName];
                
                Class<DBProtocol> class = [[HMDatabaseManager shareDatabase]tableDic][tableName];
                
                if (class && [array isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary * dictionary in array) {
                        
                        // 更新这张表的updateTime
                        if (task) {
                            [task updateReadWifiTableTime:dictionary];
                        }
                        
                        HMBaseModel *model = [class objectFromDictionary:dictionary];
                        [model sql];
                        [objectsArray addObject:model];
                    }
                    
                }else{
                    DLog(@"客户端未用到表名：%@",tableName);
                }
            }
            
            int timeStamp = [BLUtility getTimestamp];
            DLog(@"timeStamp = %d,当前数据包包含的数据表：%@",timeStamp,tableNameList);
            DLog(@"timeStamp = %d,当前数据包包含的数据总条数：%d",timeStamp,objectsArray.count);
            [[HMDatabaseManager shareDatabase]inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                DLog(@"timeStamp = %d,开始插入表数据",timeStamp);
                [objectsArray setValue:db forKey:@"insertWithDb"];
                DLog(@"timeStamp = %d,结束插入表数据",timeStamp);
            }];
            
        }else{
            DLog(@"服务器返回数据有问题：%@",dic);
        }
    }];

}

#pragma mark - 按照familyId 读取这个家庭下面所有的 wifi 设备数据
- (void)readAllDataWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    DLog(@"readAllDataWithFamilyId:%@",familyId);
    
    if (!familyId) return;
    
    // 先查询家庭下面绑定的uid列表
    [self queryDevicebindsWithFamilyId:familyId completion:^(KReturnValue value, NSDictionary *dic) {
        // 查询家庭下面的设备列表，不管成功还是失败，都可以继续使用，最坏的情况下是冗余一些数据
        // 所以，不单独处理此命令的结果，接着就去读取此家庭下面的数据
        [self readWifiTableWithFamilyId:familyId completion:completion];
    }];
}

// 实时查询指定家庭下面绑定的设备，如果当前family下面绑定的设备，在本地数据中有被其他家庭绑定的记录，则应该清除那些家庭（包括当前familyId）的数据
// 否则在当前家庭下面去查设备表时，会把那些旧数据也查出来（因为当前家庭绑定了某个uid，关联设备表时，会把其他账号下的那些家庭下面失效未同步的数据也查出来）
-(void)queryDevicebindsWithFamilyId:(NSString *)familyId completion:(SocketCompletionBlock)completion{
    
    QueryUserGatewayBindCmd *cmd = [QueryUserGatewayBindCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.resendTimes = kMaxTryTimes;
    sendCmd(cmd, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            NSArray *gatewayList = returnDic[@"gatewayList"];
            if (gatewayList.count) {
                NSArray *uids = [gatewayList valueForKey:@"uid"];
                NSString *uidString = stringWithObjectArray(uids);
                __block BOOL findOldBind = NO;
                NSString *sql = [NSString stringWithFormat:@"select distinct familyId from userGatewayBind where uid in (%@) and familyId != '%@' and delFlag = 0",uidString,familyId];
                queryDatabase(sql, ^(FMResultSet *rs) {
                    
                    NSString *otherFamilyId = [rs stringForColumn:@"familyId"];
                    DLog(@"当前家庭下面的设备：%@ 有被家庭：%@绑定过的记录，则应清除掉该家庭的数据",uidString,otherFamilyId);
                    [[HMDatabaseManager shareDatabase]deleteAllWithFamilyId:otherFamilyId];
                    findOldBind = YES;
                });
                if (findOldBind) {
                    DLog(@"当前家庭绑定的设备：%@ 在本地有被其他家庭绑定过的记录,则清除完其他家庭的数据，也要把当前家庭的数据清除掉",uidString);
                    [[HMDatabaseManager shareDatabase]deleteAllWithFamilyId:familyId];
                }else{
                    DLog(@"当前家庭绑定的设备：%@ 未找到其他家庭绑定了这些设备",uidString);
                }
                
            }else {
                // 可能没有设备权限，也可能没有添加设备
                DLog(@"此用户在当前家庭下面没有设备绑定信息：userId: %@ familyId: %@",userAccout().userId,familyId);
            }
        }
        
        if (completion) {
            completion(returnValue,returnDic);
        }
    }));
}
@end

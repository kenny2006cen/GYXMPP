//
//  RemoteGateway+RT.m
//  HomeMate
//
//  Created by Air on 16/3/2.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RemoteGateway+RT.h"
#import "Gateway+RT.h"
#import "RemoteGateway+WiFi.h"
#import "HomeMateSDK.h"


@interface HMTableTask : NSObject

@property (nonatomic,assign) BOOL finish;

@property (nonatomic,assign) int tryTimes;
@property (nonatomic,assign) int totalPages;

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong)NSString *extAddr;
@property (nonatomic,strong) NSString *familyId;
@property (nonatomic,strong) BaseCmd *readTableCmd;
@property (nonatomic,strong) BaseCmd *lostPageCmd;
@property (nonatomic,strong) NSString *tableName;
@property (nonatomic,strong) NSString *deviceId;

@property (nonatomic,strong) NSString *updateTime;
@property (nonatomic,strong) NSString *lastUpdateTime;

@property (nonatomic, strong) NSNumber *updateTimeSec;


@property (nonatomic,strong) NSDictionary *tableInfo;
@property (nonatomic,strong) NSMutableArray *pageArray;
@property (nonatomic,strong) NSMutableArray *blockArray;


-(NSArray *)lostPageArray;
-(BOOL)getTheLastPage;
-(void)receiveTableData:(NSDictionary *)dic;
-(void)updateReadSensorTableTime:(NSDictionary *)dictionary;
+(HMTableTask *)taskWithTableName:(NSString *)name uid:(NSString *)uid block:(commonBlock)block;

@end

@implementation HMTableTask
@synthesize lastUpdateTime = _lastUpdateTime;

+(HMTableTask *)taskWithTableName:(NSString *)name uid:(NSString *)uid extAddr:(NSString *)extAddr block:(commonBlock)block
{
    HMTableTask *task = [HMTableTask taskWithTableName:name uid:uid block:block];
    task.extAddr = extAddr;
    return task;
}

+(HMTableTask *)taskWithTableName:(NSString *)name device:(HMDevice *)device block:(commonBlock)block
{
    HMTableTask *task = [HMTableTask taskWithTableName:name uid:device.uid block:block];
    task.deviceId = device.deviceId;
    
    return task;
}

+(HMTableTask *)taskWithTableName:(NSString *)name familyId:(NSString *)familyId block:(commonBlock)block
{
    HMTableTask *task = [[self alloc]init];
    task.familyId = familyId?:@"";
    task.uid = @"";
    task.tableName = name;
    task.tryTimes = 0;
    task.pageArray = [NSMutableArray array];
    task.blockArray = [NSMutableArray array];
    [task.blockArray addObject:block];
    
    return task;
}

+(HMTableTask *)taskWithTableName:(NSString *)name uid:(NSString *)uid block:(commonBlock)block
{
    HMTableTask *task = [[self alloc]init];
    task.familyId = userAccout().familyId;
    task.uid = uid?:@"";
    task.tableName = name;
    task.tryTimes = 0;
    task.pageArray = [NSMutableArray array];
    task.blockArray = [NSMutableArray array];
    [task.blockArray addObject:block];
    return task;
}
#pragma mark - 读取整张表
-(BaseCmd *)readTableCmd
{
    if (!_readTableCmd) {
        QueryDataCmd *qdCmd = [QueryDataCmd object];
        qdCmd.userName = userAccout().userName;
        
        qdCmd.uid = self.uid;
        qdCmd.LastUpdateTime = secondWithString([self lastUpdateTime]);
        qdCmd.TableName = self.tableName;
        qdCmd.deviceId = self.deviceId;
        qdCmd.extAddr = self.extAddr;
        qdCmd.familyId = self.familyId;
        qdCmd.PageIndex = 0;//PageIndex为0的时候是读取整张表
        qdCmd.dataType = @"all";
        qdCmd.sendToServer = YES;
        qdCmd.resendTimes = 3;
        _readTableCmd = qdCmd;
    }
    return _readTableCmd;
}

#pragma mark - 读取丢失的指定页
-(BaseCmd *)lostPageCmd
{
    NSArray *lossArray = [self lostPageArray];
    if (lossArray.count) {
        int page = [[lossArray firstObject]intValue];
        
        QueryDataCmd *qdCmd = [QueryDataCmd object];
        qdCmd.userName = userAccout().userName;
        qdCmd.uid = self.uid;
        qdCmd.LastUpdateTime = secondWithString([self lastUpdateTime]);
        qdCmd.TableName = self.tableName;
        qdCmd.deviceId = self.deviceId;
        qdCmd.extAddr = self.extAddr;
        qdCmd.familyId = self.familyId;
        qdCmd.PageIndex = page;
        qdCmd.dataType = @"all";
        qdCmd.sendToServer = YES;
        
        return qdCmd;
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
    if (self.deviceId) {
        return @{@"tableName":self.tableName ?:@"",@"uid":self.uid ?:@"",@"deviceId":self.deviceId ?:@""};
    }else if (self.extAddr) {
        return @{@"tableName":self.tableName ?:@"",@"uid":self.uid ?:@"",@"extAddr":self.extAddr ?:@""};
    }
    return @{@"tableName":self.tableName ?:@"",@"uid":self.uid ?:@""};
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
    DLog(@"表%@ 接收到%@号包 总共%d个数据包",self.tableName,page,self.totalPages);
    if (![self.pageArray containsObject:page]) {
        
        DLog(@"表%@ %@号包添加到数组",self.tableName,page);
        
        [self.pageArray addObject:page];
    }
}

-(void)updateReadSensorTableTime:(NSDictionary *)dictionary
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

-(NSString *)keyWithKeyword:(NSString *)keyword{
    
    if (!keyword || [keyword isEqualToString:@""]) {
        return [NSString stringWithFormat:@"UpdateTimeKey_%@_%@_%@",self.familyId,self.tableName,kDbVersion];
    }
    return [NSString stringWithFormat:@"UpdateTimeKey_%@_%@_%@_%@",self.familyId,keyword,self.tableName,kDbVersion];
}

-(NSString *)lastUpdateTimeKey
{
    // 根据 userId, uid, tableName 作为key值保存lastUpdateTime
    if (self.deviceId) {
        NSString *lastTimeKey = [self keyWithKeyword:self.deviceId];
        DLog(@"%@",lastTimeKey);
        return lastTimeKey;
    }
        
    if (self.extAddr){
        NSString *lastTimeKey = [self keyWithKeyword:self.extAddr];
        DLog(@"%@",lastTimeKey);
        return lastTimeKey;
    }
    
    NSString *lastTimeKey = [self keyWithKeyword:self.uid];
    DLog(@"%@",lastTimeKey);
    
    return lastTimeKey;
}

-(NSString *)secKeyWithKeyword:(NSString *)keyword{
    
    if (!keyword || [keyword isEqualToString:@""]) {
        return [NSString stringWithFormat:@"UpdateTimeSecKey_%@_%@_%@",self.familyId,self.tableName,kDbVersion];
    }
    return [NSString stringWithFormat:@"UpdateTimeSecKey_%@_%@_%@_%@",self.familyId,keyword,self.tableName,kDbVersion];
}
-(NSString *)lastUpdateTimeSecKey
{
    if (self.deviceId) {
        NSString *lastUpdateTimeSecKey = [self secKeyWithKeyword:self.deviceId];
        DLog(@"%@",lastUpdateTimeSecKey);
        return lastUpdateTimeSecKey;
    }
        
    if (self.extAddr){
        NSString *lastUpdateTimeSecKey = [self secKeyWithKeyword:self.extAddr];
        DLog(@"%@",lastUpdateTimeSecKey);
        return lastUpdateTimeSecKey;
    }
    
    NSString *lastUpdateTimeSecKey = [self secKeyWithKeyword:self.uid];
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
        DLog(@"移除lastUpdateTime key:%@",keyOfLastUpdateTime);
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
        
         DLog(@"获取lastUpdateTime: %@ %@",_lastUpdateTime,self);
    }
    return _lastUpdateTime;
}

-(void)saveLastUpdateTime
{
    if (self.updateTime) {
        
        DLog(@"保存lastUpdateTime 旧lastUpdateTime：%@ 新lastUpdateTime：%@ %@",self.lastUpdateTime,self.updateTime,self);
        
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
    if (self.deviceId) {
        return [NSString stringWithFormat:@"tableName=%@ uid=%@ deviceId: %@",self.tableName,self.uid,self.deviceId];
    }else if (self.extAddr){
        return [NSString stringWithFormat:@"tableName=%@ uid=%@ extAddr: %@",self.tableName,self.uid,self.extAddr];
    }
    return [NSString stringWithFormat:@"tableName=%@ uid=%@",self.tableName,self.uid];
}
@end


@implementation RemoteGateway (RT)

-(HMTableTask *)taskWithDicionary:(NSDictionary *)tableInfo
{
    NSString *tableName = tableInfo[@"tableName"];
    NSString *uid = tableInfo[@"uid"]?:@"";
    NSString *deviceId = tableInfo[@"deviceId"];
    NSString *extAddr = tableInfo[@"extAddr"];
    
    HMTableTask *task = extAddr ? [self taskWithSensorTableName:tableName uid:uid extAddr:extAddr]
    :[self taskWithSensorTableName:tableName uid:uid deviceId:deviceId];
    return task;
    
}

-(HMTableTask *)taskWithSensorTableName:(NSString *)tableName uid:(NSString *)uid extAddr:(NSString *)extAddr
{
    LogFuncName();
    
    NSPredicate *pred = nil;
    if (tableName && uid && extAddr) {
        pred = [NSPredicate predicateWithFormat:@"tableName = %@ and uid = %@ and extAddr = %@",tableName,uid,extAddr];
    }else if (tableName && uid){
        pred = [NSPredicate predicateWithFormat:@"tableName = %@ and uid = %@",tableName,uid];
    }else{
        pred = [NSPredicate predicateWithFormat:@"tableName = %@",tableName];
    }
    
    NSArray *findArray = [self.sensorTableQueue filteredArrayUsingPredicate:pred];
    
    return [findArray firstObject];
}


-(HMTableTask *)taskWithSensorTableName:(NSString *)tableName uid:(NSString *)uid deviceId:(NSString *)deviceId
{
    //LogFuncName();
    
    NSPredicate *pred = nil;
    if (tableName && uid && deviceId) {
        pred = [NSPredicate predicateWithFormat:@"tableName = %@ and uid = %@ and deviceId = %@",tableName,uid,deviceId];
    }else if (tableName && uid){
        pred = [NSPredicate predicateWithFormat:@"tableName = %@ and uid = %@",tableName,uid];
    }else{
        pred = [NSPredicate predicateWithFormat:@"tableName = %@",tableName];
    }

    
    NSArray *findArray = [self.sensorTableQueue filteredArrayUsingPredicate:pred];
    
    return [findArray firstObject];
}
-(HMTableTask *)taskWithTableName:(NSString *)tableName device:(HMDevice *)device
{
    return [self taskWithSensorTableName:tableName uid:device.uid?:@"" deviceId:device.deviceId];
}

-(HMTableTask *)taskWithSensorTableName:(NSString *)tableName uid:(NSString *)uid
{
    return [self taskWithSensorTableName:tableName uid:uid?:@"" deviceId:nil];
}
#pragma mark - 读表操作
-(void)readSensorTableWithTask:(HMTableTask *)task
{
    //LogFuncName();
    
    [self cancelTimeoutWithSensorTableInfo:task.tableInfo]; // 取消 之前的超时操作
    
    // 添加新的超时操作，
    // 读表命令发出后，如果3秒还没有表数据返回（注意不是读表命令的默认返回，而是真实的表数据），则重发
    [self addTimeoutWithSensorTableInfo:task.tableInfo];
    
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
            
            DLog(@"读取表%@ 命令返回成功",task.tableName);
            
        }else{ // 读表命令失败，等待走超时重试路径
            DLog(@"读表命令失败，错误码：%d",returnValue);
        }
    }];
}

-(void)readSensorTableSuccess:(HMTableTask *)task
{
    LogFuncName();
    
    if (task) { // 表数据读取成功
        DLog(@"%@",task);

        [task saveLastUpdateTime];
        [self cancelTimeoutWithSensorTableInfo:task.tableInfo];
        
        for (commonBlock finishBlock in task.blockArray) {
            finishBlock(KReturnValueSuccess);
        }

        if ([self.sensorTableQueue containsObject:task]) {
            [self.sensorTableQueue removeObject:task];
        }
    }else{
        DLog(@"未成功获取task");
    }
    
}
-(void)readSensorTableFailed:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    HMTableTask *task = [self taskWithDicionary:tableInfo];
    
    if (task) {
        
        DLog(@"%@",task);
        
        if (task.tryTimes < kReadTableMaxTryTimes) {
            
            DLog(@"尝试读表%d次",task.tryTimes);
            [self readSensorTableWithTask:task];
            
        }else {
            
            for (commonBlock finishBlock in task.blockArray) {
                finishBlock(KReturnValueTimeout);
            }

            if ([self.sensorTableQueue containsObject:task]) {
                [self.sensorTableQueue removeObject:task];
            }
        }
        
    }else {
        DLog(@"读表%@ 任务已经被取消",tableInfo);
    }
    
}

-(void)addTimeoutWithSensorTableInfo:(NSDictionary *)tableInfo
{
    //LogFuncName();
    
    DLog(@"读表 %@ 添加超时",tableInfo[@"tableName"]);
    // 先取消旧的超时函数，防止超时函数会被执行多次
    //[self cancelTimeoutWithTableName:tableName];
    
    SEL selector = @selector(readSensorTableFailed:);
    [self performSelector:selector withObject:tableInfo afterDelay: kReadTableTimeOut];
}
-(void)cancelTimeoutWithSensorTableInfo:(NSDictionary *)tableInfo
{
    //LogFuncName();
    SEL selector = @selector(readSensorTableFailed:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:tableInfo];
}

#pragma mark - 丢包时的处理函数
-(void)lossPageWithSensorTableTask:(HMTableTask *)task
{
    LogFuncName();
    
    [self cancelTimeoutWithSensorTableInfo:task.tableInfo]; // 取消 之前的超时操作
    [self addTimeoutWithSensorTableInfo:task.tableInfo];;       // 添加 新的超时操作
    BaseCmd *cmd = task.lostPageCmd;
    if (cmd) {
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *dic) {
            
            //DLog(@"结果信息%@",dic);
            // 读表命令成功
            if (returnValue == KReturnValueSuccess) {
                
                DLog(@"读取表%@ 命令返回成功",task.tableName);
                
            }else{ // 读表命令失败，等待走超时路径
                //[weakSelf cancelTimeoutWithTableName:task.tableName]; // 取消超时操作
                //[weakSelf readTableFailed:task.tableName]; // 读表未读完失败
            }
        });
    }
}

#pragma mark - 接收到表数据
-(void)didReceiveTableData:(NSDictionary *)dic
{
    if (dic) {
        
        int cmd = [[dic objectForKey:@"cmd"]intValue];
        if (cmd == VIHOME_CMD_QD) { // 读取表数据
            
            NSString *tableName = dic[@"tableName"];
            
            if ([tableName isEqualToString:@"rStatus"]
                || [tableName isEqualToString:@"dStatus"]
                || [tableName isEqualToString:@"mStatus"]
                || [tableName isEqualToString:@"message"]
                || [tableName isEqualToString:@"messageType"]
                || [tableName isEqualToString:@"securityWarning"]
                || [tableName isEqualToString:@"warningMember"]
                || [tableName isEqualToString:@"secLeftCallCount"]
                || [tableName isEqualToString:@"energyUploadDay"]
                || [tableName isEqualToString:@"energyUploadWeek"]
                || [tableName isEqualToString:@"energyUploadMonth"]
                || [tableName isEqualToString:@"channelCollection"]

                //TODO打开注释
                || [tableName isEqualToString:@"sensorDataDay"]
                || [tableName isEqualToString:@"sensorDataWeek"]
                || [tableName isEqualToString:@"sensorDataMonth"]
                || [tableName isEqualToString:@"sensorEvent"]
                || [tableName isEqualToString:@"sensorData"]
                || [tableName isEqualToString:@"sensorDataLast"]
                || [tableName isEqualToString:@"deviceBrand"]
                || [tableName isEqualToString:@"frequentlyMode"]
                || [tableName isEqualToString:@"floor"]
                || [tableName isEqualToString:@"room"]
                || [tableName isEqualToString:@"remoteBind"]
                || [tableName isEqualToString:@"linkage"]
                || [tableName isEqualToString:@"statusRecord"]
                || [tableName isEqualToString:@"theme"]
                
                ) {

                DLog(@"接收到-----%@----表数据",tableName);
                NSString *uid = dic[@"uid"]?:@"";
                NSString *deviceId = dic[@"deviceId"];
                NSString *extAddr = dic[@"extAddr"];
                
                NSDictionary *tableInfo = @{@"tableName":tableName,@"uid":uid};
                if (extAddr) {
                    tableInfo = @{@"tableName":tableName,@"uid":uid,@"extAddr":extAddr};
                }else if (deviceId){
                    tableInfo = @{@"tableName":tableName,@"uid":uid,@"deviceId":deviceId};
                }
                
                // 接收到真实表数据之后先取消旧的超时，再添加新的超时，防止接收到一半时出故障卡死
                [self cancelTimeoutWithSensorTableInfo:tableInfo];
                
                HMTableTask *task = [self taskWithDicionary:tableInfo];
                
                if (task) { // 有读表任务未完成
                    
                    DLog(@"查找到任务%@",task);
                    [task receiveTableData:dic];
                    [self saveSensorTableData:dic task:task];// 保存表数据到本地
                    //如果最后一个包一直收不到，则不会进入后续处理，会走超时重读路径
                    if ([task getTheLastPage]) {
                        
                        if (task.finish) { // 所有数据全部接收完成
                            
                            [self readSensorTableSuccess:task];
                            
                        }else { // 有数据包丢失（非最后一个包丢失）
                            
                            [self lossPageWithSensorTableTask:task]; // 丢掉某些包的处理
                        }
                    }else { // 添加超时，等待其他页数据返回，规定时间未返回则走超时路径
                        
                        [self addTimeoutWithSensorTableInfo:tableInfo];
                    }
                }else{
                    DLog(@"未找到读取-----%@----表的Task，直接保存数据",tableName);
                    [self saveTableAnyway:dic];
                }
                
            }else{
                [super didReceiveTableData:dic];
            }
            
        }else if (cmd == VIHOME_CMD_QUERY_WIFI_DEVICE_DATA){
            
            [self didReceiveWifiTableData:dic];
        }
    }
}


#pragma mark - 保存表数据到本地

-(void)saveSensorTableData:(NSArray *)array task:(HMTableTask *)task tableName:(NSString *)tableName
{
    LogFuncName();
    if (![array isKindOfClass:[NSArray class]]) {

        DLog(@"数据类型错误");
        return;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (self = %@)",[NSNull null]];
    NSArray *filterArray = [array filteredArrayUsingPredicate:pred];

    Class<DBProtocol> class = [[HMDatabaseManager shareDatabase]tableDic][tableName];
    
    if (class && filterArray.count) {
        
        [[HMDatabaseManager shareDatabase]inSerialQueue:^{
            
            NSMutableArray *objectsArray = [NSMutableArray array];
            
            for (NSDictionary * content in filterArray) {
                
                // 更新这张表的updateTime
                [task updateReadSensorTableTime:content];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:content];
                
                NSString *uid = dictionary[@"uid"];
                if ((!uid) || (!isValidUID(uid))) {
                    [dictionary setObject:task.uid forKey:@"uid"];
                }
                
                if ([tableName isEqualToString:@"room"]) {
                    if (task.familyId) {
                        dictionary[@"familyId"] = task.familyId;
                    }
                }
                
                HMBaseModel *model = [class objectFromDictionary:dictionary];
                [model sql];
                [objectsArray addObject:model];
            }
            
            [[HMDatabaseManager shareDatabase]inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                [objectsArray setValue:db forKey:@"insertWithDb"];
            }];
            
        }];
        
    }else{
        DLog(@"无数据，tableName = %@",tableName);
    }
}
-(void)saveSensorTableData:(NSDictionary *)dic task:(HMTableTask *)task
{
    LogFuncName();
    
    NSString *tableName = dic[@"tableName"];
    
    NSArray *array = [dic objectForKey:@"allList"];
    
    [self saveSensorTableData:array task:task tableName:tableName];
}

#pragma mark - 按uid来读取统计数据

-(void)readSensorTableWithName:(NSString *)tableName uid:(NSString *)_uid completion:(commonBlock)completion
{
    //LogFuncName();
    
    // remoteBind表 绑定逻辑已经修改，现在不能按uid方式读，而要按familyId来读取整个家庭下的数据
    // 所以uid要置空，否则服务器会转发给主机，新主机不会返回数据
    NSString *uid = [tableName isEqualToString:@"remoteBind"] ? @"" : _uid;
    // 是否存在一个读取当前表的task
    HMTableTask *task = [self taskWithSensorTableName:tableName uid:uid];
    if(task == nil){// 如果不存在则新建一个任务
        
        task = [HMTableTask taskWithTableName:tableName uid:uid block:completion];
        [self.sensorTableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        [self readSensorTableWithTask:task];
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
}


-(void)didReadSensorTableArray:(NSMutableArray *)tableArray uid:(NSString *)uid completion:(commonBlock)completion
{
    //LogFuncName();
    if (tableArray.count) {
        
        NSString *tableName = [tableArray firstObject];
        
        [self readSensorTableWithName:tableName uid:uid completion:^(KReturnValue value) {
            if (value == KReturnValueSuccess) {
                DLog(@"%@表读取成功",tableName);
                [tableArray removeObject:tableName];
                DLog(@"******读表的任务数组%@",tableArray);
                [self didReadSensorTableArray:tableArray uid:uid completion:completion];
            }else{
                // 读表失败，返回错误码
                completion(value);
            }
        }];
        
    }else{
        // 全部读取完成，返回成功
        completion(KReturnValueSuccess);
    }
}

// 读取安防打电话表信息
-(void)readSecurityTableWithCompletion:(commonBlock)completion
{
    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"warningMember",@"securityWarning", nil];
    [self didReadSensorTableArray:tableArray uid:@"" completion:completion];
}


// 读取甲醛、CO探测仪日、周、月浓度统计表
- (void)readAvgConcentrationWithUid:(NSString *)uid completion:(commonBlock)completion
{
    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"sensorDataDay",@"sensorDataWeek",@"sensorDataMonth", nil];
    [self didReadSensorTableArray:tableArray uid:(uid?:@"") completion:completion];
}

- (void)readChannelCollectTableWithUid:(NSString *)uid completion:(commonBlock)completion {

    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"channelCollection", nil];
    [self didReadSensorTableArray:tableArray uid:(uid?:@"") completion:completion];
}

-(void)readTableWithUid:(NSString *)uid tableName:(NSString *)tableName completion:(commonBlock)completion
{
    [self readTableWithUid:(uid?:@"") tableArray:@[tableName] completion:completion];
}

- (void)readTableOfSensorWithUid:(NSString *)uid completion:(commonBlock)completion {

    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"sensorEvent", @"sensorDataLast", nil];
   [self didReadSensorTableArray:tableArray uid:(uid?:@"") completion:completion];
}

#pragma mark - 按uid和表名来同步数据
- (void)readTableWithUid:(NSString *)uid tableArray:(NSArray *)array completion:(commonBlock)completion
{
    if (userAccout().isWidget) {
        DLog(@"widget登录，不读表");
        return;
    }
    if (array && [array isKindOfClass:[NSArray class]]) {
        
        NSString *tableName = @"theme";
        // 如果包含主题表，则特殊处理
        if ([array containsObject:tableName]) {
            NSMutableArray *tableArray = [NSMutableArray arrayWithArray:array];
            HMDevice *device = [HMDevice objectWithUid:uid];
            if (device) {
                [[RemoteGateway shareInstance] readTableOfDevice:device tableName:tableName completion:^(KReturnValue value) {
                    DLog(@"读取%@表数据 returnValue : %d",tableName,value);
                    [tableArray removeObject:tableName];
                    
                    // 只有一个主题表需要读取，则读取完毕就返回成功
                    if (0 == tableArray.count) {
                        if (completion) {
                            completion(value);
                        }
                    }else{
                        
                        // 除了主题表，还有其他表需要读取，则移除主题表后，继续按照旧的方式读取其他数据表
                        [self didReadSensorTableArray:tableArray uid:(uid?:@"") completion:completion];
                    }
                }];
                return;
            }else{
                DLog(@"本地数据库没有查询到%@对应的device",uid);
            }
        }
        
        NSMutableArray *tableArray = [NSMutableArray arrayWithArray:array];
        [self didReadSensorTableArray:tableArray uid:(uid?:@"") completion:completion];
    }
}
#pragma mark - 按设备来读取统计数据

- (void)readTableOfDevice:(HMDevice *)device completion:(commonBlock)completion
{
    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"energyUploadDay",@"energyUploadWeek",@"energyUploadMonth", nil];
    [self didReadDeviceTableArray:tableArray device:device completion:completion];
}

- (void)readTableOfDevice:(HMDevice *)device tableName:(NSString *)tableName completion:(commonBlock)completion
{
    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:tableName,nil];
    [self didReadDeviceTableArray:tableArray device:device completion:completion];
}

-(void)didReadDeviceTableArray:(NSMutableArray *)tableArray device:(HMDevice *)device completion:(commonBlock)completion
{
    LogFuncName();
    if (tableArray.count) {
        
        NSString *tableName = [tableArray firstObject];
        [self readDeviceTableWithName:tableName device:device completion:^(KReturnValue value) {
            if (value == KReturnValueSuccess) {
                DLog(@"%@表读取成功",tableName);
                [tableArray removeObject:tableName];
                DLog(@"******读表的任务数组%@",tableArray);
                [self didReadDeviceTableArray:tableArray device:device completion:completion];
            }else{
                // 读表失败，返回错误码
                completion(value);
            }
        }];
        
    }else{
        // 全部读取完成，返回成功
        completion(KReturnValueSuccess);
    }
}


-(void)readDeviceTableWithName:(NSString *)tableName device:(HMDevice *)device completion:(commonBlock)completion
{
    LogFuncName();
    
    // 是否存在一个读取当前表的task
    HMTableTask *task = [self taskWithTableName:tableName device:device];
    if(task == nil){// 如果不存在则新建一个任务
        
        task = [HMTableTask taskWithTableName:tableName device:device block:completion];
        
        [self.sensorTableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        [self readSensorTableWithTask:task];
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
}

// 读取常用模式表数据
- (void)readFrequentlyModeWithDevice:(HMDevice *)device completion:(commonBlock)completion
{
    // 统一到服务器读表，不传uid，否则会转发到服务器
    HMDevice *newDevice = [device copy];
    newDevice.uid = @"";
    [self readDeviceTableWithName:@"frequentlyMode" device:newDevice completion:completion];
    
}
// 读取遥控器绑定表数据
- (void)readRemoteBindWithCompletion:(commonBlock)completion
{
    // 单独同步remoteBind时，如果uid有值，会将指令发给主机，但是新版本remoteBind数据会存储在server上，所以uid不能有值
    [self readTableWithUid:@"" tableName:@"remoteBind" completion:completion];
}

// 读取指定家庭的楼层房间数据
- (void)readFloorAndRoomWithFamilyId:(NSString *)familyId completion:(commonBlock)completion
{
    [self readTableWithFamilyId:familyId tableArray:@[@"floor",@"room"] completion:completion];
}

#pragma mark - 按familyId和表名来同步数据
- (void)readTableWithFamilyId:(NSString *)familyId tableArray:(NSArray *)array completion:(commonBlock)completion
{
    if (array && [array isKindOfClass:[NSArray class]]) {
        NSMutableArray *tableArray = [NSMutableArray arrayWithArray:array];
        [self didReadTableArray:tableArray familyId:familyId completion:completion];
    }
}


-(void)didReadTableArray:(NSMutableArray *)tableArray familyId:(NSString *)familyId completion:(commonBlock)completion
{
    LogFuncName();
    if (tableArray.count) {
        
        NSString *tableName = [tableArray firstObject];
        [self readTableWithName:tableName familyId:familyId completion:^(KReturnValue value) {
            if (value == KReturnValueSuccess) {
                DLog(@"%@表读取成功",tableName);
                [tableArray removeObject:tableName];
                DLog(@"******读表的任务数组%@",tableArray);
                [self didReadTableArray:tableArray familyId:familyId completion:completion];
            }else{
                // 读表失败，返回错误码
                completion(value);
            }
        }];
        
    }else{
        // 全部读取完成，返回成功
        completion(KReturnValueSuccess);
    }
}
#pragma mark - 按uid来读取统计数据

-(void)readTableWithName:(NSString *)tableName familyId:(NSString *)familyId completion:(commonBlock)completion
{
    LogFuncName();
    
    // 是否存在一个读取当前表的task
    HMTableTask *task = [self taskWithSensorTableName:tableName uid:@""];
    if(task == nil){// 如果不存在则新建一个任务
        
        task = [HMTableTask taskWithTableName:tableName familyId:familyId block:completion];
        [self.sensorTableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        [self readSensorTableWithTask:task];
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
}


#pragma mark -【新配电箱】按extAddr统计电量
- (void)readVoltameter:(NSString *)uid extAddr:(NSString *)extAddr completion:(commonBlock)completion
{
    NSMutableArray *tableArray = [NSMutableArray arrayWithObjects:@"energyUploadDay",@"energyUploadWeek",@"energyUploadMonth", nil];
    [self didReadTableArray:tableArray uid:(NSString *)uid extAddr:extAddr completion:completion];
}

-(void)didReadTableArray:(NSMutableArray *)tableArray uid:(NSString *)uid extAddr:(NSString *)extAddr completion:(commonBlock)completion
{
    LogFuncName();
    if (tableArray.count) {
        
        NSString *tableName = [tableArray firstObject];
        [self readTableWithName:tableName uid:uid extAddr:extAddr completion:^(KReturnValue value) {
            if (value == KReturnValueSuccess) {
                DLog(@"%@表读取成功",tableName);
                [tableArray removeObject:tableName];
                DLog(@"******读表的任务数组%@",tableArray);
                [self didReadTableArray:tableArray uid:(NSString *)uid extAddr:extAddr completion:completion];
            }else{
                // 读表失败，返回错误码
                completion(value);
            }
        }];
        
    }else{
        // 全部读取完成，返回成功
        completion(KReturnValueSuccess);
    }
}

-(void)readTableWithName:(NSString *)tableName uid:(NSString *)uid extAddr:(NSString *)extAddr completion:(commonBlock)completion
{
    LogFuncName();
    
    // 是否存在一个读取当前表的task
    HMTableTask *task = [self taskWithSensorTableName:tableName uid:uid extAddr:extAddr];
    if(task == nil){// 如果不存在则新建一个任务
        
        task = [HMTableTask taskWithTableName:tableName uid:uid extAddr:extAddr block:completion];
        [self.sensorTableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        [self readSensorTableWithTask:task];
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
}

// 读取消息类型表（此表返回当前家庭有哪些种类的消息）
- (void)readMessageTypeWithCompletion:(commonBlock)completion
{
    NSString *familyId = userAccout().familyId;
    [self readTableWithFamilyId:familyId tableArray:@[@"messageType"] completion:completion];
}

@end

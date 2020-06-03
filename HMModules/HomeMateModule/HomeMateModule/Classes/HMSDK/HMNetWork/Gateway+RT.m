 //
//  Gateway+RT.m
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+RT.h"
#import "HMConstant.h"
#import "QueryDataCmd.h"


@interface ALTableTask : NSObject

@property (nonatomic,assign) BOOL finish;
@property (nonatomic,assign) int tryTimes;
@property (nonatomic,retain) Gateway *gateway;
@property (nonatomic,retain,readonly) NSString *uid;
@property (nonatomic,retain,readonly) NSDictionary *tableInfo;
@property (nonatomic,retain) BaseCmd *cmd;
@property (nonatomic,retain) BaseCmd *lostPageCmd;
@property (nonatomic,retain) NSString *tableName;
@property (nonatomic,retain) NSDictionary *tableDic;
@property (nonatomic,retain) NSMutableArray *blockArray;
@property (nonatomic,retain) NSMutableArray *pageArray;


// 是否指定发送命令到服务器,默认为NO，发送命令到网关
@property (nonatomic,assign) BOOL sendToServer;

// 是否是专门同步状态表的task
@property (nonatomic,assign) BOOL isReadSpecificTable;


+(ALTableTask *)taskWithTableName:(NSString *)name dic:(NSDictionary *)dic gateway:(Gateway *)gateway remote:(BOOL)isRemote block:(commonBlock)block;

-(NSArray *)lostPageArray;
-(BOOL)needToReadTable;
-(BOOL)getTheLastPage;
-(void)receiveTableData:(NSDictionary *)dic;

@end

@implementation ALTableTask

@synthesize tableName;
@synthesize tableDic;
@synthesize tryTimes;
@synthesize finish;
@synthesize pageArray;
@synthesize gateway;
@synthesize cmd;
@synthesize lostPageCmd;
@synthesize sendToServer;
@synthesize blockArray;

+(ALTableTask *)taskWithTableName:(NSString *)name dic:(NSDictionary *)dic gateway:(Gateway *)gateway remote:(BOOL)isRemote block:(commonBlock)block
{
    ALTableTask *task = [[self alloc]init];
    task.gateway = gateway;
    task.tableName = name;
    task.tableDic = dic;
    task.tryTimes = 0;
    task.pageArray = [NSMutableArray array];
    task.sendToServer = isRemote;
    task.blockArray = [NSMutableArray array];
    [task.blockArray addObject:block];
    return task;
}

-(NSString *)uid
{
    return self.gateway.uid?:@"";
}
-(NSDictionary *)tableInfo
{
    return @{@"tableName":self.tableName,@"uid":self.uid};
}
#pragma mark - 读取整张表
-(BaseCmd *)cmd
{
    QueryDataCmd *qdCmd = [QueryDataCmd object];
    qdCmd.userName = userAccout().userName;
    qdCmd.uid = self.uid;
    qdCmd.LastUpdateTime = secondWithString([self lastUpdateTime]);
    qdCmd.TableName = tableName;
    qdCmd.PageIndex = 0;//PageIndex为0的时候是读取整张表
    qdCmd.dataType = @"all";
    qdCmd.sendToServer = sendToServer;
    
    return qdCmd;
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
        qdCmd.TableName = tableName;
        qdCmd.PageIndex = page;
        qdCmd.dataType = @"all";
        qdCmd.sendToServer = sendToServer;
        
        return qdCmd;
    }
    return nil;
}

-(NSString *)lastUpdateTime
{
    if (self.isReadSpecificTable) {
        
        return [self.gateway tableUpdateTime:self.tableName];
    }
    return self.gateway.lastUpdateTime;
}
-(int)totalPages
{
    return [[tableDic objectForKey:@"allPageNum"]intValue];
}
-(NSArray *)lostPageArray
{
    if (!self.finish) {
        
        NSMutableArray *allPacketArray = [NSMutableArray array];
        for (int i = 1; i <= [self totalPages] ; i ++) {
            [allPacketArray addObject:[NSNumber numberWithInt:i]];
        }
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT self in %@",pageArray];
        NSArray *array = [allPacketArray filteredArrayUsingPredicate:pred];
        
        DLog(@"丢失掉的包序号：%@",array);
        return array;
    }
    return nil;
}

-(BOOL)finish
{
    return (pageArray.count == [self totalPages]);
}
-(BOOL)getTheLastPage
{
    // PageIndex 从1开始
    NSNumber *lastPage = @([self totalPages]);
    return [pageArray containsObject:lastPage];
}
-(BOOL)needToReadTable
{
    int AllNum = [[tableDic objectForKey:@"allNum"]intValue];

    return (AllNum != 0);
}

-(void)receiveTableData:(NSDictionary *)dic
{
    NSNumber *page = [dic objectForKey:@"pageIndex"];
    DLog(@"表%@ 接收到%@号包 总共%d个数据包",tableName,page,[self totalPages]);
    if (![pageArray containsObject:page]) {
        
        DLog(@"表%@ %@号包添加到数组",tableName,page);
        
        [pageArray addObject:page];
    }
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"tableName: %@ uid: %@",tableName,self.uid];
}
@end


@implementation Gateway (RT)


-(ALTableTask *)tableTask:(NSString *)tableName uid:(NSString *)uid
{
    LogFuncName();
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.tableName = %@ and self.uid = %@",tableName,uid];
    NSArray *findArray = [self.tableQueue filteredArrayUsingPredicate:pred];
    
    return [findArray firstObject];
}
-(void)readTableSuccess:(ALTableTask *)task
{
    LogFuncName();
    
    if (task) { // 表数据读取成功
        DLog(@"%@",task);
        //
        [self cancelTimeoutWithTableInfo:task.tableInfo];
        
        for (commonBlock finishBlock in task.blockArray) {
            finishBlock(KReturnValueSuccess);
        }
        if ([self.tableQueue containsObject:task]) {
            [self.tableQueue removeObject:task];
        }
    }else{
        DLog(@"未成功获取task");
    }
    
}
-(void)readTableFailed:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    //[self clearTableData]; // 清理内存
    NSString *tableName = tableInfo[@"tableName"];
    NSString *uid = tableInfo[@"uid"];
    
    ALTableTask *task = [self tableTask:tableName uid:uid];
    
    if (task) {
        
        DLog(@"%@",task);
        
        if (task.tryTimes < kReadTableMaxTryTimes) {
            
            DLog(@"尝试读表%d次",task.tryTimes);
            [self readTableWithTask:task];
            
        }else {
            
            for (commonBlock finishBlock in task.blockArray) {
                finishBlock(KReturnValueTimeout);
            }
            
            if ([self.tableQueue containsObject:task]) {
                [self.tableQueue removeObject:task];
            }
            //DLog(@"表%@ 读取失败",task.tableName);
        }
        
    }else {
        DLog(@"读表%@ 任务已经被取消",tableInfo);
    }
    
}

-(void)addTimeoutWithTableInfo:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    DLog(@"读表 %@ 添加超时",tableInfo[@"tableName"]);
    // 先取消旧的超时函数，防止超时函数会被执行多次
    //[self cancelTimeoutWithTableName:tableName];
    
    SEL selector = @selector(readTableFailed:);
    [self performSelector:selector withObject:tableInfo afterDelay: kReadTableTimeOut];
}
-(void)cancelTimeoutWithTableInfo:(NSDictionary *)tableInfo
{
    LogFuncName();
    
    SEL selector = @selector(readTableFailed:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:tableInfo];
}

#pragma mark - 查询统计信息

-(void)readTableWithUid:(NSString *)gatewayUid remote:(BOOL)isRemote completion:(commonBlock)block
{
    LogFuncName();
    
    NSString *uid = gatewayUid?:@"";
    
    __weak Gateway *weakSelf = self;
    
    weakSelf.statusInfo[uid] = @(YES);
    
    DLog(@"当前状态：读取所有表 uid:%@",uid);
    commonBlock completion = ^(KReturnValue value){
        
        weakSelf.statusInfo[uid] = @(NO);
        
        DLog(@"当前状态：读表完成 uid:%@",uid);
        if (block) {
            block(value);
        }
    };
    
    // 查询更新统计
    QueryStatisticsCmd *qsCmd = [QueryStatisticsCmd object];
    qsCmd.userName = userAccout().userName;
    qsCmd.uid = uid;
    qsCmd.LastUpdateTime = secondWithString(getGateway(uid).lastUpdateTime);
    qsCmd.sendToServer = isRemote;
    
    sendCmd(qsCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            if ([returnDic isKindOfClass:[NSDictionary class]]) {
                
                NSMutableDictionary *statisticsInfo = [NSMutableDictionary dictionaryWithDictionary:returnDic];
                
                // 移除数据更新条数为 0 的表
                NSMutableArray *array = [NSMutableArray array];
                
                for (NSString *tableName in statisticsInfo) {
                    
                    NSDictionary *dic = statisticsInfo[tableName];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        
                        int allNumber = [dic[@"allNum"]intValue];
                        if (allNumber == 0) {
                            [array addObject:tableName];
                        }
                    }else{
                        [array addObject:tableName];
                    }
                    
                }
                if (array.count > 0) {
                    [statisticsInfo removeObjectsForKeys:array];
                }
                // 一张表一张表读
                [weakSelf recursionReadTableWithUid:uid statisticsInfo:statisticsInfo remote:isRemote completion:completion];
                
            }else{
                
                if (completion) {
                    completion(KReturnValueFail);
                }
                DLog(@"数据异常");
            }
            
        }else {
            
            DLog(@"查询统计信息失败，错误码：%d",returnValue);
            completion(returnValue);
        }
    });
}

-(NSString *)getTableName:(NSArray *)keys
{
    static NSArray *priorityArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        priorityArray = @[ @{@"tableName":[HMGateway tableName]       ,@"priority":@(1)}
                           ,@{@"tableName":[HMAccount tableName]      ,@"priority":@(2)}
                           ,@{@"tableName":[HMDevice tableName]       ,@"priority":@(3)}
                           ,@{@"tableName":[HMDeviceStatus tableName] ,@"priority":@(4)}
                           ,@{@"tableName":[HMLinkage tableName]      ,@"priority":@(5)}
                           ,@{@"tableName":[HMScene tableName]        ,@"priority":@(6)}
                           ,@{@"tableName":[HMTiming tableName]                 ,@"priority":@(7)}
                           ,@{@"tableName":[HMCameraInfo tableName]             ,@"priority":@(8)}
                           ,@{@"tableName":[HMDeviceIr tableName]               ,@"priority":@(9)}
                           ,@{@"tableName":[HMDeviceSettingModel tableName]     ,@"priority":@(10)}
                           ,@{@"tableName":[HMFrequentlyModeModel tableName]    ,@"priority":@(11)}
                           ,@{@"tableName":[HMDoorUserModel tableName]          ,@"priority":@(12)}
                           ,@{@"tableName":[HMAuthorizedUnlockModel tableName]  ,@"priority":@(13)}
                           ,@{@"tableName":[HMDoorLockRecordModel tableName]    ,@"priority":@(14)}
                           ,@{@"tableName":[HMRemoteBind tableName]             ,@"priority":@(15)}
                           ,@{@"tableName":[HMSecurity tableName]               ,@"priority":@(16)}
                           ];
        
    });
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.tableName in %@",keys];
    NSArray *filterArray = [priorityArray filteredArrayUsingPredicate:pred];
    if (filterArray.count) {
        
        NSSortDescriptor *sortDsctor = [[NSSortDescriptor alloc]initWithKey:@"priority" ascending:YES];
        NSArray *resultArray = [filterArray sortedArrayUsingDescriptors:@[sortDsctor]];
        
        return [resultArray firstObject][@"tableName"];
    }
    return [keys firstObject];
}

#pragma mark - 递归读表
-(void)recursionReadTableWithUid:(NSString *)uid
                  statisticsInfo:(NSMutableDictionary *)statisticsInfo
                          remote:(BOOL)isRemote
                      completion:(commonBlock)completion
{
    DLog(@"%@ uid = %@ isRemote = %d",NSStringFromSelector(_cmd),uid,isRemote);
    
    __block Gateway *weakSelf = self;
    
    if (statisticsInfo.count) {
        
        // 有数据需要更新，读表
        NSString *tableName = [weakSelf getTableName:statisticsInfo.allKeys];
        
        NSDictionary *dic = statisticsInfo[tableName];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            [self readTableWithName:tableName dic:dic uid:uid remote:isRemote completion:^(KReturnValue value) {
                
                if (value == KReturnValueSuccess) { // 当前表读取成功
                    
                    DLog(@"%@ 读%@表成功",isRemote?@"远程":@"本地", tableName);
                    
                    [statisticsInfo removeObjectForKey:tableName];
                    // 继续读取下一张表
                    [weakSelf recursionReadTableWithUid:uid statisticsInfo:statisticsInfo remote:isRemote completion:completion];
                    
                }else { // 当前表读取失败
                    DLog(@"%@表读取失败，错误码：%d",tableName,value);
                    
                    if (completion) {
                        completion(value);// 返回错误码
                    }
                }
                
            }];
        }else{
            
            DLog(@"%@表读取失败，数据错误",tableName);
            if (completion) {
                completion(KReturnValueFail);// 返回失败
            }
        }
        
    }else {
        
        DLog(@"uid == %@ ----数据全部读取成功",uid);
        // 当前网关登录成功
        getGateway(uid).isLoginSuccessful = YES;

        // 保存更新时间
        [getGateway(uid) saveLastUpdateTime];
        
        // 全部读取完成，返回成功
        if (completion) {
            completion(KReturnValueSuccess);
        }
        
    }

}

#pragma mark - 封装读表任务
-(void)readTableWithName:(NSString *)name dic:(NSDictionary *)dic uid:(NSString *)uid remote:(BOOL)isRemote completion:(commonBlock)completion
{
    [self readTableWithName:name dic:dic uid:uid remote:isRemote specific:NO completion:completion];
}

-(void)readTableWithName:(NSString *)name dic:(NSDictionary *)dic uid:(NSString *)uid remote:(BOOL)isRemote specific:(BOOL) specific completion:(commonBlock)completion
{
    LogFuncName();
    
    // 是否存在一个读取当前表的task
    ALTableTask *task = [self tableTask:name uid:uid];
    if(task == nil){// 如果不存在则新建一个任务
        task = [ALTableTask taskWithTableName:name dic:dic gateway:getGateway(uid) remote:isRemote block:completion];
        [self.tableQueue addObject:task];
        DLog(@"新增一个任务:%@",task);
        
    }else{
        [task.blockArray addObject:completion];
        DLog(@"已经存在任务");
    }
    task.isReadSpecificTable = specific;
    
    [self readTableWithTask:task];
}
#pragma mark - 读表操作
-(void)readTableWithTask:(ALTableTask *)task
{
    LogFuncName();
    
    // 无数据更新，直接返回成功
    if ([task needToReadTable]){ // 有数据更新
        
        [self cancelTimeoutWithTableInfo:task.tableInfo]; // 取消 之前的超时操作
        
        // 添加新的超时操作，
        // 读表命令发出后，如果3秒还没有表数据返回（注意不是读表命令的默认返回，而是真实的表数据），则重发
        [self addTimeoutWithTableInfo:task.tableInfo];
        
        task.tryTimes += 1;// 增加当前task的尝试次数，如果再次失败，依据此值决定是否继续重读
        
        /*
         读表命令，不是一条命令一个返回值类型，可能是发送一条读表命令，返回多页结果
         针对这种情况，发送读表命令后，一旦接收到表数据时会自动调用函数
         -(void)didReceiveTableData:(NSDictionary *)dic 来处理
         此处不返回结果，等待上面的函数被调用，否则走超时路径
         */
        [self sendCmd:task.cmd completion:^(KReturnValue returnValue, NSDictionary *dic) {
            //DLog(@"结果信息%@",dic);
            // 读表命令成功
            if (returnValue == KReturnValueSuccess) {
                
                DLog(@"读取表%@ 命令返回成功",task.tableName);
                
            }else{ // 读表命令失败，等待走超时路径
                //[weakSelf cancelTimeoutWithTableName:task.tableName]; // 取消超时操作
                //[weakSelf readTableFailed:task.tableName]; // 读表未读完失败
            }
        }];
    }
    else{
        
        [self readTableSuccess:task];
    }
    
}
#pragma mark - 接收到表数据
-(void)didReceiveTableData:(NSDictionary *)dic
{
    LogFuncName();
    
    if (dic) {
        
        int cmd = [[dic objectForKey:@"cmd"]intValue];
        if (cmd == VIHOME_CMD_QD) { // 读取表数据
            
            NSString *tableName = [dic objectForKey:@"tableName"];
            NSString *uid = dic[@"uid"];
            DLog(@"接收到%@表数据",tableName);
            // 接收到真实表数据之后先取消旧的超时，再添加新的超时，防止接收到一半时出故障卡死
            [self cancelTimeoutWithTableInfo:@{@"tableName":tableName,@"uid":uid}];
            ALTableTask *task = [self tableTask:tableName uid:uid];
            
            if (task) { // 有读表任务未完成
                
                DLog(@"查找到任务%@",task);
                [task receiveTableData:dic];
                [self saveTableData:dic task:task];// 保存表数据到本地
                //如果最后一个包一直收不到，则不会进入后续处理，会走超时重读路径
                if ([task getTheLastPage]) {
                    
                    if (task.finish) { // 所有数据全部接收完成
                        
                        [self readTableSuccess:task];
                        
                    }else { // 有数据包丢失（非最后一个包丢失）
                        
                        [self lossPageWithTask:task]; // 丢掉某些包的处理
                    }
                }else { // 添加超时，等待其他页数据返回，规定时间未返回则走超时路径
                    
                    [self addTimeoutWithTableInfo:@{@"tableName":tableName,@"uid":uid}];
                }
            }else{
                DLog(@"未查找到任务：%@",dic);
                [self saveTableAnyway:dic];
            }
        }
    }
}

-(void)saveTableAnyway:(NSDictionary *)dic
{
    LogFuncName();
    
    [[HMDatabaseManager shareDatabase]inSerialQueue:^{
        
        NSString *tableName = dic[@"tableName"];
        NSArray *array = [dic objectForKey:@"allList"];
        
        if (tableName && [array isKindOfClass:[NSArray class]]) {
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (self = %@)",[NSNull null]];
            NSArray *filterArray = [array filteredArrayUsingPredicate:pred];
            
            Class<DBProtocol> class = [[HMDatabaseManager shareDatabase]tableDic][tableName];
            if (class) {
                
                NSMutableArray *objectsArray = [NSMutableArray array];
                
                for (NSDictionary * dictionary in filterArray) {
                    
                    HMBaseModel *model = [class objectFromDictionary:dictionary];
                    [model sql];
                    [objectsArray addObject:model];
                }
                
                [[HMDatabaseManager shareDatabase]inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    
                    [objectsArray setValue:db forKey:@"insertWithDb"];
                }];
            }
        }
    }];
}

#pragma mark - 丢包时的处理函数
-(void)lossPageWithTask:(ALTableTask *)task
{
    LogFuncName();
    
    [self cancelTimeoutWithTableInfo:task.tableInfo]; // 取消 之前的超时操作
    [self addTimeoutWithTableInfo:task.tableInfo];;       // 添加 新的超时操作
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

-(void)updateReadTableTime:(NSDictionary *)dictionary task:(ALTableTask *)task
{
    //LogFuncName();
    
    NSNumber *updateTimeSec = [dictionary objectForKey:@"updateTimeSec"];
    if (updateTimeSec) {
        if (updateTimeSec.integerValue > self.updateTimeSec.integerValue) {
            self.updateTimeSec = updateTimeSec;
        }
    }else {
    
        NSString *currentUpdateTime = [dictionary objectForKey:@"updateTime"];
        NSString *oldUpdateTime = task.isReadSpecificTable ? [self tableUpdateTime:task.tableName] : self.updateTime;
//        如果 oldUpdateTime 是NSNumber 比较会崩溃
        if (oldUpdateTime && (![oldUpdateTime isKindOfClass:[NSString class]])) {
            oldUpdateTime = dateStringWithSec(oldUpdateTime);
        }
        
        NSComparisonResult compareResult = [currentUpdateTime compare:oldUpdateTime];
        if (compareResult == NSOrderedDescending) {
            if (task.isReadSpecificTable) {
                self.specificTableUpdateTime[task.tableName] = currentUpdateTime;
            }else {
                self.updateTime = currentUpdateTime;
            }
        }
        
    }
}
#pragma mark - 保存表数据到本地

-(void)didSave:(NSArray *)array task:(ALTableTask *)task tableName:(NSString *)tableName
{
    LogFuncName();
    
    Class<DBProtocol> class = [[HMDatabaseManager shareDatabase]tableDic][tableName];
    
    if (class && [array isKindOfClass:[NSArray class]]) {
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (self = %@)",[NSNull null]];
        NSArray *filterArray = [array filteredArrayUsingPredicate:pred];
        // 读取了账号表
        if ([tableName isEqualToString:[HMAccount tableName]] // 账号表
            && isValidUID(task.uid)) {  // uid非空
            
            NSString *uid = task.uid;
            HMGateway *gateway = [HMGateway objectWithUid:uid];
            if (gateway && isHostModel(gateway.model)) { // 确定是主机时才做此操作
                
                // 读取了主机的 account 表，但是只需要写入当前登录的这个账号的信息
                // 其他分享来的账号信息，不能写入数据库，但是updateTime需要更新
                // 如果updateTime不更新的话，会导致再次修改主机数据时，主机会返回41的错误码
                // 但客户端传入的lastupdateTime一直不是最新的，因为抛弃了分享来的账号，他们的更新时间也没有记录
                
                for (NSDictionary * content in filterArray) {
                    
                    // 不使用self，是因为可能是远程读表，此时self.uid 为空
                    [task.gateway updateReadTableTime:content task:task];
                }
                
                // 当主机不能及时同步服务器的账号表信息时，客户端把主机的账号表都读取下来，会出现显示出来分享的账号信息跟实际情况不一致的情况
                // 所以这里的处理是以服务器的账号表为准，主机的账号表信息，只保存当前登录的这个，分享来的账户信息不保存（因为可能不准）
                // 另外，如果用子账号登录，也会把所有的账号信息都读取下来，会误判定主账号是当前账号的子账号
                
                
                NSString *currentUserName = userAccout().currentUserName;
                
                DLog(@"读取了主机的账号表 uid = %@，当前登录的用户名：%@，当前userId = %@",uid,currentUserName,userAccout().userId);
                
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"userId = %@ or phone = %@ or email = %@ or email = %@",currentUserName,currentUserName,currentUserName.lowercaseString,currentUserName];
                NSArray *filtArray = [filterArray filteredArrayUsingPredicate:pred];
                
                if (filtArray.count) {
                    
                    DLog(@"从主机的账号表中过滤出来的数据：%@",filtArray);
                    
                    NSDictionary *dic = filtArray.lastObject;
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        
                        DLog(@"只保留当前账号表信息，分享的账号信息不显示");
                        filterArray = @[dic];
                        
                    }else{
                        
                        filterArray = @[]; // 置空数组，不写入数据库
                        DLog(@"数据类型错误，不写入数据库");
                    }
                    
                }else{
                    
                    filterArray = @[]; // 置空数组，不写入数据库
                    DLog(@"未查找到当前账号，不写入数据库");
                }
            
                DLog(@"写入数据库的账号信息：%@",filterArray);
                
            }else{
                DLog(@"非主机账号表，不做处理：%@",gateway);
            }
        }
        
        
        [[HMDatabaseManager shareDatabase]inSerialQueue:^{
            
            NSMutableArray *objectsArray = [NSMutableArray array];
            
            for (NSDictionary * content in filterArray) {
                
                // 不使用self，是因为可能是远程读表，此时self.uid 为空
                [task.gateway updateReadTableTime:content task:task];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setDictionary:content];
                
                NSString *uid = dictionary[@"uid"];
                if ((!uid) || (!isValidUID(uid))) {
                    [dictionary setObject:task.uid forKey:@"uid"];
                }
                // 摄像头表有一个cameraUid 被修改为uid 了
                if ([tableName isEqualToString:@"cameraInfo"]) {
                    dictionary[@"cameraUid"] = uid;
                }
                
                //[[class objectFromDictionary:dictionary]insertObject];
                HMBaseModel *model = [class objectFromDictionary:dictionary];
                
                if (model) {
                    
                    [model sql];
                    [objectsArray addObject:model];
                }
            }
            
            [[HMDatabaseManager shareDatabase]inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                [objectsArray setValue:db forKey:@"insertWithDb"];
                
            }];
            
        }];
        
    }else{
        DLog(@"客户端未用到表名：%@",tableName);
    }
}
-(void)saveTableData:(NSDictionary *)dic task:(ALTableTask *)task
{
    LogFuncName();
    
    NSString *tableName = dic[@"tableName"];
    
    NSArray *array = [dic objectForKey:@"allList"];
    
    [self didSave:array task:task tableName:tableName];
}

@end


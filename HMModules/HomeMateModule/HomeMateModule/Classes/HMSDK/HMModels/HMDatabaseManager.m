//
//  BLDatabaseMgr.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDatabaseManager.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "HMDescConfig.h"
#import "HMConstant.h"
#import "HMStorage.h"

/**
 *  清除当前key对应的lastupdateTime值
 *
 *  @param keyString key
 */
void cleanLastUpdateTime(NSString *keyString);

void cleanLastUpdateTimeWithFamilyId(NSString *familyId,NSString *keyString);

BOOL queryDatabase(NSString *sql , FMBlock queryBlock)
{
    @autoreleasepool {
        
        FMResultSet * rs = [[HMDatabaseManager shareDatabase] executeQuery:sql];
        
        while([rs next])
        {
            queryBlock(rs);
        }
        [rs close];
    }
    
    return YES;
}

BOOL queryDatabaseStop(NSString *sql, FMSBlock stopBlock)
{
    @autoreleasepool {
        
        BOOL stop = NO;
        
        FMResultSet * rs = [[HMDatabaseManager shareDatabase] executeQuery:sql];
        
        while([rs next])
        {
            stopBlock(rs,&stop);
            if (stop) {
                break;
            }
        }
        [rs close];
    }
    return YES;
}

FMResultSet *executeQuery(NSString*sql, ...)
{
    return [[HMDatabaseManager shareDatabase] executeQuery:sql];
}

BOOL executeUpdate(NSString*sql, ...)
{
    return [[HMDatabaseManager shareDatabase] executeUpdate:sql];
}

BOOL updateInsertDatabase(NSString *sql)
{
    return [[HMDatabaseManager shareDatabase] executeUpdate:sql];
}


/**
 *  清除当前key对应的lastupdateTime值
 */
void cleanLastUpdateTime(NSString *keyString)
{
    cleanLastUpdateTimeWithFamilyId(nil, keyString);
}
void cleanLastUpdateTimeWithFamilyId(NSString *familyId,NSString *keyString)
{
    DLog(@"cleanLastUpdateTimeWithFamilyId:%@ key:%@",familyId,keyString);
    
    if (!keyString) return;
    
    void (^didRemoveObject)(NSString *) = ^(NSString *key){
        DLog(@"清除UserDefaults数据: key:%@ value:%@",key,[HMUserDefaults objectForKey:key]);
        [HMUserDefaults removeObjectForKey:key];
        [HMUserDefaults synchronize];
    };
    
    NSArray *array = [[HMUserDefaults dictionaryRepresentation] allKeys];
    
    if (familyId) {
        
        for (NSString *key in array) {
            if (stringContainString(key, familyId) && stringContainString(key, keyString)) {
                didRemoveObject(key);
            }
        }
    }else{
        for (NSString *key in array) {
            if (stringContainString(key, keyString)) {
                didRemoveObject(key);
            }
        }
    }
    
    // 只清除NSUserDefault 当中包含 UpdateTime 的key值，非userId
    if ([keyString isEqualToString:@"UpdateTime"]) {
        return;
    }
    // 如果传入的keyString是一个网关uid，则直接把网关的lastUpdatetime设置为0(清除内存中的数据)
    Gateway *gateway1 = userAccout().gatewayDicList[keyString];
    if (gateway1) {
        gateway1.lastUpdateTime = nil;
    }
}

@interface HMDatabaseManager ()

@property(nonatomic,strong)NSMutableDictionary *tableDic;
@property(nonatomic,strong)NSString *dbPath;

@property(nonatomic,strong)FMDatabaseQueue * fmdbQueue;

@property(nonatomic,assign)BOOL isDbVersionChanged;

@property(nonatomic,assign)BOOL isTransactionBusy;

@end
@implementation HMDatabaseManager
{
    dispatch_queue_t    _queue;
}

// 查询数据
- (FMResultSet *)executeQuery:(NSString*)sql, ...
{
    return [_db executeQuery:sql];
}

// 更新数据
- (BOOL)executeUpdate:(NSString*)sql, ...
{
    return [_db executeUpdate:sql];
}

// 更新数据，可用?占位符
- (BOOL)executeUpdate:(NSString *)sql withVAList:(va_list)args {
    BOOL result = [_db executeUpdate:sql withVAList:args];
    return result;
}

- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName
{
    return [_db columnExists:columnName inTableWithName:tableName];
}

- (BOOL)tableExists:(NSString*)tableName
{
    return [_db tableExists:tableName];
}

- (sqlite3*)sqliteHandle
{
    return [_db sqliteHandle];
}

+ (HMDatabaseManager *)shareDatabase
{
    static HMDatabaseManager * shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[HMDatabaseManager alloc] init];
    });
    return shareInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"database.%@", self] UTF8String], NULL);
    }
    return self;
}

- (FMDatabase *)db
{
    if (!_db) {
        
        _db = [[FMDatabase alloc] initWithPath:self.dbPath];
        _checkUpgradeDB = YES;
        
    }
    return _db;
}

- (void)upgradeDatabase{
    
    NSString *tmppath = [self changeDatabasePath:self.dbPath];
    if(tmppath){
        const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';",self.dbPath,@"5Am3WkGWREPa$vpX"] UTF8String];
        
        sqlite3 *unencrypted_DB;
        if (sqlite3_open([tmppath UTF8String], &unencrypted_DB) == SQLITE_OK) {
            DLog(@"打开未加密临时数据库成功 开始附加数据库 %@",tmppath);
            // Attach empty encrypted database to unencrypted database
            int rs1 = sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, NULL);
            
            // export database
            int rs2 = sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
            
            // Detach encrypted database
            int rs3 = sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
            
            sqlite3_close(unencrypted_DB);
            DLog(@"附加数据库完成,rs1 = %d,rs2 = %d,rs3 = %d",rs1,rs2,rs3);
            //delete tmp database
            [self removeDatabasePath:tmppath];
            
            self.checkUpgradeDB = NO;
        }
        else {
            sqlite3_close(unencrypted_DB);
            NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
        }
    }
}

- (NSString *)removeDatabasePath:(NSString *)path{
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    BOOL result = [fm removeItemAtPath:path error:&err];
    if(!result){
        DLog(@"删除临时数据库失败");
        return nil;
    }else{
        return path;
    }
}

- (NSString *)changeDatabasePath:(NSString *)path{
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSString *tmppath = [NSString stringWithFormat:@"%@.tmp",path];
    BOOL result = [fm moveItemAtPath:path toPath:tmppath error:&err];
    if(!result){
        DLog(@"生成临时数据库失败");
        return nil;
    }else{
        
        if([fm fileExistsAtPath:path]) {
            DLog(@"path:%@\ntmppath:%@",path,tmppath);
        }
        
        return tmppath;
    }
}

/** 设备描述表数据 */
-(NSArray *)descDataArray
{
    if ([HMDescConfig isBuiltInDataVersionChanged]) {
        
        return [HMDescConfig localConfigSQL];
    }
    return nil;
}

/** 软件工厂数据 */
-(NSArray *)appFactoryDataArray
{
    // 内置Appfactory的数据版本号变化了（已包含首次启动App的情况）
    // 或者数据库大版本号发生变化了，会先把工厂表数据清空，再重新插入本地数据
    if ([HMAppFactoryAPI localConfigDataChange] || self.isDbVersionChanged) {
        
        return [HMAppFactoryAPI localConfigSQL];
    }
    return nil;
}

/** 把App内置数据写进数据库 */

-(void)insertBuiltInData
{
    LogFuncName();
    
    DLog(@"-----开始把内置数据写进数据库");
    // 把App内置数据写进数据库
    
    NSArray *appFactoryArray = [self appFactoryDataArray];
    NSArray *descArray = [self descDataArray];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    if (appFactoryArray.count) {
        [dataArray setArray:appFactoryArray];
    }
    if (descArray.count) {
        [dataArray addObjectsFromArray:descArray];
    }
    
    if (dataArray.count) {
        
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            DLog(@"-----Transaction开始把内置数据写进数据库");
            for (NSString * sql in dataArray) {
                
                if (sql.length > 10) {
                    [db executeUpdate:sql];
                }else{
                    DLog(@"sql 语句有问题 ：%@",sql);
                }
            }
            DLog(@"-----Transaction内置数据写进数据库完成");
        }];
    }
    DLog(@"-----内置数据写进数据库完成");
}


- (void)initDatabase
{
    // 初始化数据库
    NSString *newDbName = @"HomeMate.db";
    NSString *newDbPath = [kNEWDBDIR stringByAppendingPathComponent:newDbName];
    DLog(@"%@",newDbPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *oldDbName = @"ViHomePro_v10.db";
    NSString *oldDbPath = [kDBDIR stringByAppendingPathComponent:oldDbName];
    
    // 旧数据库存在则换到新目录
    if ([fileManager fileExistsAtPath:oldDbPath]) {
        [fileManager moveItemAtPath:oldDbPath toPath:newDbPath error:nil];
    }
    
    BOOL isNewDbExist = [fileManager fileExistsAtPath:newDbPath];
    if (!isNewDbExist) {
        
        // 如果数据库被手动清除，则移除所有的lastUpdateTime值
        cleanLastUpdateTime(@"UpdateTime");
        [userAccout() setAutoLogin:NO];
        // 数据库不存在则创建一个
        BOOL operationResult = [fileManager createFileAtPath:newDbPath contents:nil attributes:nil];
        if (!operationResult) {
            DLog(@"数据库文件创建失败");
        }else{
            DLog(@"数据库文件创建成功");
        }
    }
    
    self.dbPath = newDbPath;
    self.isTransactionBusy = NO;
//    sqlite3_shutdown();
//    int err=sqlite3_config(SQLITE_CONFIG_SERIALIZED);
//    if (err == SQLITE_OK) {
//        NSLog(@"Can now use sqlite on multiple threads, using the same connection");
//    }
    
    // 数据库打开后建表
    if ([self.db open]) {
        
        /**
            修复多线程访问数据库闪退问题
            https://blog.csdn.net/liuyinghui523/article/details/78672271
         */
        
        [self.db setShouldCacheStatements:YES];
        
        [self fmdbQueue]; // 初始化数据库队列
        
        // 首次登录，db 不存在则把当前的dbVersion值存进数据库
        if (!isNewDbExist) {
            
            DLog(@"刚建立数据库时，建好所有表");
            [self createTable];
            [HMVersionModel saveCurrentDbVersion];
            
        }else{
            
            [HMStorage shareInstance].lastFamilyCount = [HMFamily familyCount];
            
            HMVersionModel *oldVersion = [HMVersionModel oldVersion];
            
            // 数据库存在的情况下要去判断版本号是否改变，若改变则先删除旧表，再建新表
            if (![oldVersion.dbVersion isEqualToString:kDbVersion]) {
                
                self.isDbVersionChanged = YES;
                DLog(@"数据库版本号变化");

                // 移除所有的lastUpdateTime值，后续登录时可以全部同步回来
                cleanLastUpdateTime(@"UpdateTime");
                
                // 删除旧表（可以在server上重新读取到的数据表）
                [self dropTable];
                
                // 再建新表
                [self createTable];
                
                // 将新值更新到数据库
                oldVersion.dbVersion = kDbVersion;
                [oldVersion updateObject];
                
            }else{
                
                // 数据库版本号未改变，执行一遍此函数，那么当新增一张表时也可以加进来
                DLog(@"数据库版本号未改变");
                [self createTable];
                
            }
        }
        
         // 把App内置数据写进数据库
        [self insertBuiltInData];
    }
    
}


/**
 *  常量表，创建之后，数据库版本升级，或者清除账号信息时都不用清除这些表中的数据
 *
 *  @return 数据库类数组
 */
-(NSArray *)constantTableArray
{
    return @[[HMAuthority class],               // 本地权限表
             [HMLocalAccount class],            // 本地账号表
             [HMVersionModel class],            // 版本控制表
             [HMClotheshorseCutdown class],     // 晾衣架倒计时表
             [HMClotheshorseStatus class],      // 晾衣架状态表
             [HMCommonDeviceModel class],       // 常用设备表
             [HMCommonScene class],             // 常用情景表
             [HMAccreditPersonModel class],     // 门锁-最近联系人
             [HMT1AccreditPersonModel class],     // t1/9113门锁-最近联系人
             [HMEnergySaveDeviceModel class],   // 节能提醒设备表
             [HMDeviceDesc class],              // 设备描述表
             [HMDeviceLanguage class],          // 设备描述语言表
             [HMQrCodeModel class],             // 二维码对照表
             [HMFloorOrderModel class],         // 楼层排序表
             [HMRoomOrderModel class],          // 房间排序表
             [HMDeviceSort class],              // 设备排序表
             [HMSceneExtModel class],           // 场景排序表
             [HMLinkageExtModel class],         // 联动排序表
             [HMSecurityDeviceSort class],      // 安防设备置顶排序表
             [HMFamilyExtModel class],          // 家庭排序表
             [HMDistBoxAttributeModel class],   // 配电箱属性表
             [HMHubOnlineModel class],           // 网关在线表
             [HMLanCommunicationKeyModel class],  //局域网通信密钥表
             [HMT1IgnoreAlertRecordModel class],  // T1 忽略的消息
             [HMAMapTip class],                   //家庭地理位置搜索记录
             [HMLocalDoorUserBind class],         //c1门锁本地用户绑定表
             [HMQuickDeviceModel class],           //快捷页面设备表
             [HMOauth2ClientsModel class]          //第三方平台设备信息表
             ];
}


/**
 *  App工厂数据表，App各种配置项对应的数据表
 *
 *  @return 数据库类数组
 */


-(NSArray *)appFactoryTableArray
{
    return @[
             [HMAppNaviTab class],
             [HMAppNaviTabLanguage class],
             [HMAppProductType class],
             [HMAppProductTypeLanguage class],
             [HMAppSetting class],
             [HMAppSettingLanguage class],
             [HMAppMyCenter class],
             [HMAppMyCenterLanguage class],
             [HMAppService class],
             [HMAppServiceLanguage class],
             ];
}

/**
 *  server表，创建之后，数据库版本升级，或者清除账号信息时会清除这些表中的数据，登录时重新获取一次最新数据
 *
 *  @return 数据库类数组
 */
-(NSArray *)serverTableArray
{
    NSArray *array = @[
                      [HMAccount class],
                      [HMAlarmMessage class],
                      [HMCameraInfo class],
                      [HMDevice class],
                      [HMDeviceSettingModel class],
                      [HMDeviceJoinIn class],
                      [HMDeviceStatus class],
                      [HMFloor class],
                      [HMGateway class],
                      [HMLinkage class],
                      [HMLinkageCondition class],
                      [HMLinkageOutput class],
                      [HMRemoteBind class],
                      [HMRoom class],
                      [HMScene class],
                      [HMSceneBind class],
                      [HMStandardIr class],
                      [HMDeviceIr class],
                      [HMStandardIRDevice class],
                      [HMTiming class],
                      [HMMessagePush class],
                      [HMMessage class],
                      [HMMessageTypeModel class],
                      [HMUserGatewayBind class],
                      [HMAuthorizedUnlockModel class],
                      [HMDoorUserModel class],
                      [HMDoorLockRecordModel class],
                      [HMFrequentlyModeModel class],
                      [HMCountdownModel class],
                      [HMSecurity class],
                      [HMThirdAccountId class],
                      [HMKKIr class],
                      [HMKKDevice class],
                      [HMSecurityWarningModel class],
                      [HMWarningMemberModel class],
                      [HMEnergyUploadDay class],
                      [HMEnergyUploadWeek class],
                      [HMEnergyUploadMonth class],
                      [HMTimingGroupModel class],
                      [HMChannelCollectionModel class],
                      [HMCustomPicture class],
                      [HMMessageSecurityModel class],
                      [HMGroup class],
                      [HMGroupMember class],
                      [HMDeviceBrand class],
                      [HMFamily class],
                      [HMFamilyUsers class],
                      [HMFamilyInvite class],
                      [HMThemeModel class],
                      //TODO正式提测注释掉
                      [HMAvgConcentrationDay class],
                      [HMAvgConcentrationWeek class],
                      [HMAvgConcentrationMonth class],
                      [HMSensorData class],
                      [HMSensorEvent class],
                      [HMDoorUserBind class],
                      
                      // 配电箱属性表
                      [HMDistBoxAttributeModel class],
                      
                      //这几张本地表需要修改字段
                      [HMMessageCommonModel class],        // 普通消息表
                      [HMStatusRecordModel class],         // 状态记录表
                      [HMMessageLast class],               // 最后消息表
                      [HMSensorAverageDataModel class],    // 光照传感器历史数据表
                      [HMMessageTypeModel class],          // 消息类型表
                      [HMCustomChannel class],             //自定义频道表
                      [HMChannel class],                   //频道表
                      [HMDevicePropertyStatus class],      //设备属性状态表表
                      [HMMusicModel class]                 //音乐表
                      ];
    
    NSMutableArray *allTables = [array mutableCopy];
    [allTables addObjectsFromArray:[self appFactoryTableArray]];
    return allTables;
}

/**
 *  返回所有需要存储的数据表类
 *
 *  @return 数据库类数组
 */
-(NSArray *)allTables
{
    NSMutableArray *array = [NSMutableArray array];
    
    [array setArray:[self serverTableArray]];
    [array addObjectsFromArray:[self constantTableArray]];
    
    return array;
}

/**
 *  返回所有需要存储的数据表类和表名键值对
 *
 *  @return 数据表类和表名字典
 */

-(NSDictionary *)tableDic
{
    if (!_tableDic) {
        
        _tableDic = [[NSMutableDictionary alloc]init];
        
        for (Class<DBProtocol> class in [self allTables]) {
            
            [_tableDic setObject:class forKey:[class tableName]];
        }
    }
    
    return _tableDic;
}
/**
 *  创建数据库表
 */
- (void)createTable
{
    LogFuncName();
    
    NSArray *tables = [self allTables];
    
    for (Class<DBProtocol> aClass in tables) {
        
        [aClass createTable];
    }
}

-(void)dropTable
{
    LogFuncName();
    
    NSArray *tables = [self serverTableArray];
    [self dropTableWithArray:tables];
}

-(void)dropTableWithArray:(NSArray *)tables
{
    for (Class<DBProtocol> aClass in tables) {
        
        NSString *tableName = [aClass tableName];
        NSString *dropTableSql = [NSString stringWithFormat:@"drop table if exists %@",tableName];
        [self executeUpdate:dropTableSql];
    }
}

-(NSMutableArray *)selectAllRecord:(Class<DBProtocol>)aClass withCondition:(NSString *)condition
{
    
    NSMutableString * SQL = [NSMutableString stringWithFormat:@"select * from %@ where", [aClass tableName]];
    
    if (condition) {
        [SQL appendFormat:@" %@", condition];
    }
    
    NSMutableArray * recordsArray = [[NSMutableArray alloc] init];
    
    queryDatabase(SQL, ^(FMResultSet *rs) {
        
        [recordsArray addObject:[aClass object:rs]];
    });
    
    return recordsArray;
}

-(NSArray *)filterArray
{
    // messageCommon 表、 statusRecord 表数据不清除
    // messageCommon 表的 delFlag = 1 的数据不能清，清空消息时，每个家庭每个用户的最大序号的消息delFlag 会置为1
    NSArray *array = @[[HMMessageCommonModel class],[HMStatusRecordModel class],[HMFamily class],[HMMessageSecurityModel class]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT self in (%@)",array];
    NSArray *filter = [[self serverTableArray]filteredArrayUsingPredicate:pred];
    return filter;
}


-(void)deleteAllWithUserId:(NSString *)userId
{
    LogFuncName();
    
    // 找到当前用户的所在的全部家庭
    NSMutableArray *familys = [HMFamily familysWithUserId:userId];
    
    // 清除userId相关的数据
    [self deleteDataWithUserId:userId];
    
    for (HMFamily *family in familys) {
        // 按照家庭来清除数据库数据
        [self deleteAllWithFamilyId:family.familyId];
    }
}

-(void)deleteDataWithUserId:(NSString *)userId
{
    LogFuncName();

    NSArray *tables = [self filterArray];
    
    for (Class<DBProtocol> aClass in tables) {
        
        NSString *tableName = [aClass tableName];
        
        // 当前表存在 userId 字段
        if ([self columnExists:@"userId" inTableWithName:tableName]) {
            
            if ([tableName isEqualToString:@"account"]){
                //帐号表中的删除要根据fatherUserId来判断，fatherUserId才是当前帐号真正的userId，不然如果主账号和子账号都在同一台手机登录过，
                //删除子账号的时候，会把主帐号存在帐号表的子账号也删除掉，导致在家庭成员中显示不了子帐号
                NSString *deleteSql = [NSString stringWithFormat:@"delete from account where fatherUserId = '%@'",userId];
                [self executeUpdate:deleteSql];
            }else {
                NSString * sql = [NSString stringWithFormat:@"delete from %@ where userId = '%@'",tableName,userId];
                [self executeUpdate:sql];
            }
        }
    }
}

-(void)deleteAllWithFamilyId:(NSString *)familyId
{
    LogFuncName();
    // 清除 family 相关的 LastUpdateTime，保证下次输入账号密码时读取所有数据
    cleanLastUpdateTimeWithFamilyId(familyId, @"UpdateTime");
    // 找到每个家庭下面绑定的设备
    NSArray *bindArray = [HMUserGatewayBind bindArrayWithFamilyId:familyId];
    for (HMUserGatewayBind *bind in bindArray) {
        
        // 清除当前family下面设备(uid)相关的 LastUpdateTime
        cleanLastUpdateTime(bind.uid);
    }
    
    // 当前familyId下面绑定设备数组
    NSArray *uidArray = bindArray.count ? [bindArray valueForKey:@"uid"]:nil;
    NSString *uidString = uidArray.count ? stringWithObjectArray(uidArray) : nil;
    
    NSArray *tables = [self filterArray];
    for (Class<DBProtocol> aClass in tables) {
        
        NSString *tableName = [aClass tableName];
        
         if([self columnExists:@"familyId" inTableWithName:tableName]){
            
            NSString * sql = [NSString stringWithFormat:@"delete from %@ where familyId = '%@'",tableName,familyId];
            [self executeUpdate:sql];
            
        }else{
            // 当前账号至少绑定了一个设备
            if (uidArray.count) {
                // 当前表不存在 userId 字段，但存在uid字段，那么所有设备对应的数据也应该清除
                if ([self columnExists:@"uid" inTableWithName:tableName]) {
                    NSString * sql = [NSString stringWithFormat:@"delete from %@ where uid in (%@)",tableName,uidString];
                    [self executeUpdate:sql];
                }
            }
        }
    }
}

-(void)deleteAllWithUid:(NSString *)uid
{
    DLog(@"deleteAllWithUid:%@",uid);
    
    if (uid && isValidUID(uid)) {
        // 移除当前网关上次更新时间，那么下次读表就会把所有数据全部重读一遍
        NSArray *array = [HMDevice deviceArrWithUid:uid];
        for (HMDevice *device in array) {
            cleanLastUpdateTime(device.deviceId);
        }
        
        cleanLastUpdateTime(uid);
        // 如果删除网关则将内存中的网关状态修改，并删除
        removeDevice(uid);
    }
    
    
    NSArray *tables = [self filterArray];
    for (Class<DBProtocol> aClass in tables) {
        
        NSString *tableName = [aClass tableName];
        
        // uid == nil 清除 delFlag = 1的数据
        if (uid == nil) {
            
            DLog(@"清除%@表 delFlag = 1的数据",tableName);
            // 当前表存在delFlag字段
            if ([self columnExists:@"delFlag" inTableWithName:tableName]) {
                
                NSString *sql = [NSString stringWithFormat:@"delete from %@ where delFlag = 1",tableName];
                [self executeUpdate:sql];
                
            }
        }else{
            
            DLog(@"清除%@表 uid = %@的数据",tableName,uid);
            // 当前表存在uid字段
            if ([self columnExists:@"uid" inTableWithName:tableName]) {
                
                // 如果联动条件里面有uid里面的设备，则设备删除后，对应的联动也应该删除
                if ([tableName isEqualToString:@"linkageCondition"]) {
                    
                    NSString *delLinkageSql = [NSString stringWithFormat:@"delete from linkage where linkageId in (select DISTINCT linkageId from linkageCondition where uid = '%@')",uid];
                    
                    [self executeUpdate:delLinkageSql];
                }
                
                NSString *sql = [NSString stringWithFormat:@"delete from %@ where uid = '%@'",tableName,uid];
                
                [self executeUpdate:sql];
            }
        }
    }
}
    

-(void)deleteAppFactoryData
{
    // 先删旧表，再建新表，可以兼容字段变化
    NSArray *tables = [self appFactoryTableArray];
    [self dropTableWithArray:tables];
    
    for (Class<DBProtocol> aClass in tables) {
        [aClass createTable];
    }
}


- (FMDatabaseQueue *)fmdbQueue
{
    if (!_fmdbQueue) {
        
        _fmdbQueue = [[FMDatabaseQueue alloc] initWithPath:self.dbPath];
    }
    return _fmdbQueue;
}
- (void)inDatabase:(void (^)(FMDatabase *db))block
{
    [_fmdbQueue inDatabase:block];
}
/**数据库事务 - 子线程*/
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block
{
    __weak typeof(self) weakSelf = self;
    if (weakSelf.isTransactionBusy) {
        DLog(@"数据库inTransaction线程处于阻塞状态");
    }
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        weakSelf.isTransactionBusy = YES;
        block(db,rollback);
        weakSelf.isTransactionBusy = NO;
    }];
}

- (void)inSerialQueue:(void (^)(void))block
{
    //int timeStamp = [BLUtility getTimestamp];
    //DLog(@"serialQueueTimeStamp = %d,开始执行",timeStamp);
    dispatch_sync(_queue,block);
    //dispatch_async(_queue, block);
   // DLog(@"serialQueueTimeStamp = %d,结束执行",timeStamp);
}

+ (void)insertInTransactionWithHandler:(void (^)(NSMutableArray *))handler completion:(VoidBlock)completion {
    HMDatabaseManager *databaseManager = [HMDatabaseManager shareDatabase];
    [databaseManager inSerialQueue:^{
        NSMutableArray *objectArray = [NSMutableArray array];
        if(handler) {
            handler(objectArray);
            [databaseManager inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                if (objectArray.count > 0) {
                    [objectArray setValue:db forKey:@"insertWithDb"];
                }
                if(completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion();
                    });
                }
            }];
        }
    }];
}

@end

//
//  AccountSingleton.m
//  Vihome
//
//  Created by Air on 15-3-10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#define HMLogoutKey   @"HMLogoutKey"

#import "HMLoginBusiness+Token.h"
#import "AccountSingleton+RT.h"
#import "HMTypes.h"
#import "HMStorage.h"
#import "HMUtil.h"

@interface AccountSingleton()

@property (nonatomic,assign)BOOL isFirstIn;
/**
 *  当前userId上一次选择的familyId
 */
@property (nonatomic, strong) NSString        *lastFamilyId;

@end

@implementation AccountSingleton

@synthesize currentLocalAccount = _currentLocalAccount;
@synthesize delegate = theDelegate;
@synthesize familyId = _familyId;
@synthesize lastFamilyId = _lastFamilyId;

-(id <AccountProtocol>)delegate
{
    if (theDelegate) {
        return theDelegate;
    }
    return [HMStorage shareInstance].delegate;
}

-(void)addOutsideTask:(VoidBlock)task
{
    if (task) {
        [[HMStorage shareInstance].taskArray addObject:task];
    }
}

-(void)performOutsideTasks
{
    NSMutableArray *tasks = [HMStorage shareInstance].taskArray;
    if (tasks.count) {
        NSMutableArray *tmpTasks = [NSMutableArray arrayWithArray:tasks];
        [tasks removeAllObjects];
        for (VoidBlock block in tmpTasks) {
            block();
        }
        [tmpTasks removeAllObjects];
    }
}
-(id)init
{
    self = [super init];
    if (self) {
        
        self.gatewayDicList = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(networkStatusChanged)
                                                    name:NOTIFICATION_NETWORKSTATUS_CHANGE
                                                  object:nil];
        
        // 开始监听进入前台后台
        [self hm_startNotifierForeground:@selector(enterForeground)
                           background:@selector(willEnterBackground)];
        
        self.isFirstIn = YES;
    }
    return self;
}

+ (instancetype)shareInstance
{
    Singleton();
}

#pragma mark - 重连server 和本地网关
-(void)relinkNetwork
{
    // 如果正处于AP配置模式，则不做断开重连操作
    if (self.isInAPConfiguring) {
        
        DLog(@"当前正在进行AP配置");
        return;
    }
    
    if (self.isReading) {
        DLog(@"当前正在读取数据，不重复进行同步操作");
        return;
    }
    
    DLog(@"relinkNetwork 重新连接");
    
    __weak typeof(self) weakSelf = self;
    
    
    NSString *password = self.currentPassword;
    NSString *userName = self.currentUserName;
    
    if (!(userName && password) && ![HMLoginBusiness canUseTokenLogin]) {
        
        DLog(@"userName = %@ & password = %@",userName,password);
        return;
    }
    
    // mdns搜索到主机后逐个登录本地网关
    DLog(@"后台到前台，开始局域网搜索主机");

    [HMLoginAPI localLoginWithUserName:weakSelf.userName password:weakSelf.password completion:^(KReturnValue value, NSDictionary *returnDic) {
        DLog(@"后台到前台，局域网搜索主机并登录完成");
    }];
    
    if (isNetworkAvailable()) {
        
        DLog(@"后台到前台，开始远程重新登录，同步所有数据");
        
        [HMLoginAPI autoLoginAndUpdateDataWithCompletion:^(KReturnValue value,NSSet *tables) {
            
            DLog(@"后台到前台，数据同步%@",(value == KReturnValueSuccess) ? @"成功" : @"失败");
            
            [weakSelf foregroundLoginFinish:value];
            
            [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:tables];
            
            [weakSelf performOutsideTasks];
            
        }];
        
    }else{
        DLog(@"后台到前台，无网络");
    }
}

#pragma mark - 网络变化

-(void)networkStatusChanged
{
    DLog(@"检测到网络发生变化");
    
    if (self.isFirstIn) {
        
        DLog(@"当前是首次启动");
        self.isFirstIn = NO;
    }else{
        
        if (self.isLogin) {
            
            DLog(@"已登录情况下进行重连操作");
            [self relinkNetwork];
        }
    }
}

- (void)enterForeground
{
    DLog(@"即将进入前台");
    
    self.isEnterBackground = NO;
    if (self.isLogin) {
        
        DLog(@"进入前台重连");
        [self relinkNetwork];
    }
    
    
}
- (void)willEnterBackground
{
    DLog(@"即将进入后台");
    
    self.isEnterBackground = YES;
    self.isReading = NO;
    
    //[HMBaseAPI postNotification:kNOTIFICATION_CANCEL_SOCKET_TASK object:nil];
}


-(NSString *)userId
{
    if (self.isWidget) {
        NSDictionary *widgetDict = [self widgetUserInfo];
        if (widgetDict) {
            return widgetDict[@"userId"];
        }
    }
    HMLocalAccount *localAcc = [self currentLocalAccount];
    return localAcc.userId?:@"";
}
-(NSString *)familyId
{
    if (_familyId) {
        return _familyId;
    }
    
    return self.lastFamilyId;
}

-(void)setFamilyId:(NSString *)familyId
{
    _familyId = familyId;
    self.lastFamilyId = familyId;
}

- (NSString *)lastFamilyId{
    
    NSString *lastFmlyId = [HMUserDefaults valueForKey:CurrentFamilyIDKey];
    return lastFmlyId;
}

- (void)setLastFamilyId:(NSString *)lastFamilyId {
    if (lastFamilyId) {
        
        DLog(@"保存账号选择的familyId = %@ key = %@",lastFamilyId,CurrentFamilyIDKey);
        [self saveObject:lastFamilyId withKey:CurrentFamilyIDKey];
    }else{
        DLog(@"setLastFamilyId:%@",lastFamilyId);
        [self removeObjectWithKey:CurrentFamilyIDKey];
    }
}

-(NSString *)theUserName{
    if (!self.isLogin && _currentUserName) {
        return _currentUserName;
    }
    
    HMLocalAccount *localAcc = [self currentLocalAccount];
    if (localAcc) {
        return localAcc.lastUserName;
    }
    return @"";
}
-(NSString *)userName
{
    __weak typeof(self) weakSelf = self;
    NSString *usrName = ^{
        if (!weakSelf.isLogin && weakSelf.currentUserName) {
            return weakSelf.currentUserName;
        }
        
        HMLocalAccount *localAcc = [weakSelf currentLocalAccount];
        if (localAcc) {
            return localAcc.lastUserName;
        }
        return @"";
    }();
    
    if (isBlankString(usrName)) {
        return weakSelf.userId;
    }
    return usrName;
}

-(NSString *)currentUserName
{
    if (_currentUserName) {
        return _currentUserName;
    }
    return @"";
}

-(NSString *)password
{
    __weak typeof(self) weakSelf = self;
    NSString *pwd = ^{
        if (!weakSelf.isLogin && weakSelf.currentPassword) {
            return weakSelf.currentPassword;
        }
        
        HMLocalAccount *localAcc = [weakSelf currentLocalAccount];
        if (localAcc) {
            return localAcc.password;
        }
        return @"";
    }();
    if (isBlankString(pwd)) {
        HMAccount *accout = [HMAccount objectWithUserId:userAccout().userId];
        return accout.password;
    }
    return pwd;
}

-(NSString *)email
{
    NSString *sql = [NSString stringWithFormat:@"select * from account where userId = '%@' and fatherUserId != '(null)' and delFlag = 0",self.userId];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    if ([resultSet next]) {
        HMAccount *account = [HMAccount object:resultSet];
        NSString *email = account.email;
        if (email && (![email isEqualToString:@"null"])) {
            
            [resultSet close];
            return email;
        }
    }
    [resultSet close];
    return @"";
}
-(NSString *)phone
{
    NSString *sql = [NSString stringWithFormat:@"select * from account where userId = '%@' and fatherUserId != '(null)' and delFlag = 0",self.userId];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    if ([resultSet next]) {
        HMAccount *account = [HMAccount object:resultSet];
        NSString *phone = account.phone;
        if (phone && (![phone isEqualToString:@"null"])) {
            
            [resultSet close];
            return phone;
        }
    }
    [resultSet close];
    return @"";
}
-(HMLocalAccount *)currentLocalAccount
{
    if (!_currentLocalAccount) {
        HMLocalAccount *localAcc = [HMLocalAccount lastAccountInfo];
        _currentLocalAccount = localAcc;
    }
    return _currentLocalAccount;
}


-(HMAccount *)currentAccount
{
    HMLocalAccount *localAcc = [self currentLocalAccount];
    HMAccount *account = [HMAccount objectWithUserId:localAcc.userId];
    return account;
}

-(NSArray *)accountArr
{
    NSArray *arr = [HMLocalAccount getAllLocalAccountArr];
    return arr;
}

-(NSString *)autoLoginKey
{
    return @"AutoLogin";
}
-(BOOL)isAutoLogin
{
    if (self.isWidget) {
        return [[[self widgetUserDefault]objectForKey:[self autoLoginKey]]boolValue];
    }
    BOOL isAutoLg = [[self objectWithKey:[self autoLoginKey]] boolValue];
    return isAutoLg;
}

-(void)setAutoLogin:(BOOL)isAutoLogin
{
    [self saveObject:@(isAutoLogin) withKey:[self autoLoginKey]];
    
    // wiget 也要记住登录状态
    [[self widgetUserDefault] setObject:@(isAutoLogin) forKey:[self autoLoginKey]];
    [[self widgetUserDefault] synchronize];
}

-(BOOL)isLogin
{
    return [self isAutoLogin];
}
-(void)setIsLogin:(BOOL)isLogin
{
    [self setAutoLogin:isLogin];
}
- (NSUserDefaults *)widgetUserDefault
{
    if (!_widgetUserDefault) {
        
        NSString *widgetSuiteName = [HMSDK memoryDict][@"widgetSuiteName"];
        if (widgetSuiteName) {
            _widgetUserDefault = [[NSUserDefaults alloc] initWithSuiteName:widgetSuiteName];
        }else{
            NSString *suitename = @"group.com.orvibo.HomeMateWidget";
            NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
            if ([bundleId hasPrefix:@"com.orvibo.theLifeMaster"]) {
                suitename = @"group.com.orvibo.theLifeMaster";
            }else if ([bundleId hasPrefix:@"com.home.lamptan"]){
                suitename = @"group.com.home.lamptan";
            }else if ([bundleId hasPrefix:@"com.Korea.homemate"]){
                suitename = @"group.com.korea.HomeMateWidget";
            }else if ([bundleId hasPrefix:@"com.orvibo.cloudPlatform"]){
                suitename = @"group.com.orvibo.HomeMateWidget";
            }
            _widgetUserDefault = [[NSUserDefaults alloc] initWithSuiteName:suitename];
        }
    }
    return _widgetUserDefault;
}



-(void)addLocalAccountWithUserId:(NSString *)userId token:(NSString *)token
{
    DLog(@"当前账号信息：token = %@ userId = %@",token,userId);
    
    HMLocalAccount *account = [HMLocalAccount objectWithUserId:userId];
    if (!account) {
        account = [[HMLocalAccount alloc] init];
    }
    account.userId = userId;
    account.token = token;
    [account insertObject];
    
    _currentLocalAccount = account;
    
    [self widgetSaveUserInfo];
}

-(void)addLocalAccountWithUserName:(NSString *)userName password:(NSString *)password userId:(NSString *)userId
{
    DLog(@"当前账号信息：userName = %@ userId = %@",userName,userId);
    
    HMLocalAccount *account = [HMLocalAccount objectWithUserId:userId];
    if (!account) {
        account = [[HMLocalAccount alloc] init];
    }
    account.password = password;
    account.lastUserName = userName;
    account.loginTime = [[NSDate date] timeIntervalSince1970];
    account.userId = userId;
    [account insertObject];
    
    [HMBaseAPI postNotification:KNOTIFICATION_SAVEACCOUNT object:nil];

    _currentPassword = password;
    _currentUserName = userName;
    _currentLocalAccount = account;
    
    [self widgetSaveUserInfo];
    
}

-(void)deleteLocalAccountWithUserId:(NSString *)userId
{
    HMLocalAccount *account = [[HMLocalAccount alloc] init];
    account.userId = userId;
    [account deleteObject];
}

-(void)deleteAccountWithUserId:(NSString *)userId
{
    LogFuncName();
    
    //清除数据库中的数据
    [[HMDatabaseManager shareDatabase] deleteAllWithUserId:userId];
    
    // 保存需要清除的用户ID
    [self.widgetUserDefault setBool:YES forKey:[NSString stringWithFormat:@"cleanUserId_%@",userId]];
    [self.widgetUserDefault synchronize];
}

-(void)updateNickName:(NSString *)nickName
{
    [HMAccount updateNickName:nickName];
}

#pragma mark - 忘记密码后重置密码，或者修改密码后更新内存中的密码
-(void)updatePassword:(NSString *)password
{
    [HMAccount updatePassword:password];
    [HMAccount updatePasswordNew:password];
    [HMLocalAccount updatePassword:password];
    
    HMLocalAccount *localAcc = [self currentLocalAccount];
    localAcc.password = password;
    
    self.currentPassword = password;
    
    [self widgetSaveUserInfo];
}

- (void)updateEmail:(NSString *)email
{
    [HMAccount updateEmail:email];
    [HMLocalAccount updateEmail:email];
    _currentLocalAccount = nil;
    
    [self widgetSaveUserInfo];
}

- (void)updatePhone:(NSString *)phone
{
    [HMAccount updatePhone:phone];
    [HMLocalAccount updatePhone:phone];
    _currentLocalAccount = nil;
    
    [self widgetSaveUserInfo];
}



-(void)setIsInAPConfiguring:(BOOL)isInAPConfiguring
{
    DLog(@"%@",isInAPConfiguring ? @"进入AP配置模式" : @"结束AP配置模式");
    _isInAPConfiguring = isInAPConfiguring;
    
    if (!isInAPConfiguring) {
        DLog(@"%@",isInAPConfiguring ? @"进入AP配置模式" : @"结束AP配置模式");
    }else{
//        [getGateway(nil)cancelTask];
    }
}

-(BOOL)hasHostCanDisplayInMyCenter
{
    NSArray *all = [AllZigbeeHostModel() allObjects];
    NSArray *mixPad = [MixPadModelIDArray() allObjects];
    
    // 从所有的model中去除掉所有MixPad的model
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",mixPad];
    NSArray *filterArray = [all filteredArrayUsingPredicate:pred];
    
    NSString *modelIdString  = stringWithObjectArray(filterArray);
    
    // MixPad也是主机，但不显示在个人中心中
    __block BOOL hasZigbeeHost = NO;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from %@ "
                     "where familyId = '%@' and (model like '%%%@%%' or model like '%%%@%%' or model in (%@))",[HMUserGatewayBind modelTable],self.familyId,kViHomeModel,kHubModel,modelIdString];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        hasZigbeeHost = ([rs intForColumn:@"count"] > 0);
    });
    return hasZigbeeHost;
}

#pragma mark - 判断当前账号是否绑定了ViHome主机
-(BOOL)hasZigbeeHost
{    
    __block BOOL hasZigbeeHost = NO;
    __block NSInteger hostCount = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from %@ "
                     "where familyId = '%@' and (model like '%%%@%%' or model like '%%%@%%' or model in (%@))",[HMUserGatewayBind modelTable],self.familyId,kViHomeModel,kHubModel,HostModelIDs()];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        hasZigbeeHost = ([rs intForColumn:@"count"] > 0);
        hostCount = [rs intForColumn:@"count"];
    });
    
    DLog(@"当前账号当前家庭%@主机的绑定关系 ---- 主机数量 ：%d",hasZigbeeHost ? @"有":@"没有",hostCount);
    
    return hasZigbeeHost;
}

-(NSUInteger)zigbeeMiniCount
{
    __block NSUInteger zigbeeMiniCount = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from %@ "
                     "where familyId = '%@' and (model like '%%%@%%' or model in (%@))",[HMUserGatewayBind modelTable],self.familyId,kHubModel,MiniHubModelIDs()];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        zigbeeMiniCount = [rs intForColumn:@"count"];
    });
    
    DLog(@"当前账号当前家庭小主机的数量 ：%d",zigbeeMiniCount);
    
    return zigbeeMiniCount;
}

- (NSUInteger)zigbeeVicenterCount
{
    __block NSUInteger zigbeeVicenterCount = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from %@ "
                     "where familyId = '%@' and (model like '%%%@%%' or model in (%@))",[HMUserGatewayBind modelTable],self.familyId,kViHomeModel,ViHomeModelIDs()];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        zigbeeVicenterCount = [rs intForColumn:@"count"];
    });
    
    DLog(@"当前账号当前家庭大主机的数量 ：%d",zigbeeVicenterCount);
    
    return zigbeeVicenterCount;
}


#pragma mark - 判断当前账号是否绑定了Wifi类的设备
-(BOOL)hasWifiDevice
{
    __block BOOL hasWifiDevice = NO;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from %@ "
                     "where familyId = '%@' and (model in (%@) or model like '%%%@%%' or model like '%%%@%%' or "
                     "model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%')"
                     ,[HMUserGatewayBind modelTable],self.familyId,wifiDeviceModelIDs(),kCocoModel,kYSCameraModel,kS20cModel,kCLHModel,kS20Model,kHudingStripModel];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        hasWifiDevice = ([rs intForColumn:@"count"] > 0);
    });
    return hasWifiDevice;
}


#pragma mark - 退出登录
-(void)logoutWithCompletion:(SuccessBlock)block
{
    SuccessBlock completion = ^(BOOL success){
        
        if (block) {
            block(success);
        }
        
        [userAccout() logoutAccount];
    };
    
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate logoutWithCompletion:completion];
    }else{
        [self sendLogoutRequestWithTimeout:6.0f completion:completion];
    }
}

/**
 *  应在返回前台后会重新登录，登录完成后调用
 */
-(void)foregroundLoginFinish:(KReturnValue)returnValue
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate foregroundLoginFinish:returnValue];
    }
}

-(void)logoutAccount
{
    LogFuncName();
    
    // 重置变量
    self.isManualLogout = YES;
    self.isReading = NO;
    self.isLogin = NO;
    // 重置当前账号的网关，下次再调用的时候会重新查询，否则会保留上次的信息

    for (NSString *uid in self.gatewayDicList) {
        
        Gateway *gateway = self.gatewayDicList[uid];
        [gateway hm_removeAllObserver];
        gateway.isLoginSuccessful = NO;
    }
    
    [self.gatewayDicList removeAllObjects];
    self.isInAPConfiguring = NO;
    self.persistSocketFlag = NO;
    self.currentUserName = nil;
    self.currentPassword = nil;
    _familyId = nil;
    _lastFamilyId = nil;
    _currentLocalAccount = nil;
    // 退出时清除 widget 公用 UD 中的当前用户信息
    [self widgetRemoveUserInfo];
    
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate logoutAccount];
    }
    
    [HMBaseAPI postNotification:kNOTIFICATION_LOG_OFF object:nil];
}

- (void)sendLogoutRequestWithTimeout:(NSTimeInterval)timeout completion:(SuccessBlock)block{
    
    
    __weak typeof(self) weakSelf = self;
    SuccessBlock completion = ^(BOOL suceess){
        
        weakSelf.lastLogoutNotifiedServer = suceess;
        if (block) {
            block(suceess);
        }
    };
    
    if (isNetworkAvailable()) {
        
        DLog(@"有网络，向服务器发送退出登录请求");
        NSString *token = [HMUserDefaults objectForKey:@"token"];
        if (token) {
            
            NSString *URL = [NSString stringWithFormat:kGet_Logout_URL,token];
            URL = dynamicDomainURL(URL);
            DLog(@"%@",URL);
            
            requestURL(URL, timeout, ^(NSData *data, NSURLResponse *response, NSError *error) {
                
                BOOL success = NO;
                
                if (!error && data) {
                    
                    NSError *jsonError = nil;
                    NSDictionary *getLogoutDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    
                    DLog(@"服务器返回退出登录请求的结果：%@",getLogoutDic);
                    
                    if (!jsonError && getLogoutDic) {
                        
                        NSNumber *errorCode = getLogoutDic[@"errorCode"];
                        if (errorCode.intValue == KReturnValueSuccess) {
                            
                            DLog(@"退出登录成功");
                            success = YES;
                            
                        }else{
                            DLog(@"errorCode:%@ errorMessage:%@",errorCode,getLogoutDic[@"errorMessage"]);
                        }
                    }else{
                        
                        DLog(@"error:%@",jsonError);
                    }
                }else{
                    
                    if (error) {
                        DLog(@"%@",error);
                    }
                    
                    if (!data) {
                        DLog(@"获取服务器返回退出登录请求的结果为空，数据异常，直接退出登录");
                    }
                }
                
                // 不管向服务器发送的请求结果如何，页面交互都直接退出登录页面
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(success);
                    });
                }
            });
            
        }else{
            
            DLog(@"本地没有token，直接退出");
            if (completion) {
                completion(NO);
            }
        }
        
    }else{
        
        DLog(@"无网络，直接退出");
        if (completion) {
            completion(NO);
        }
    }
}

-(BOOL)lastLogoutNotifiedServer
{
    BOOL isNotified = [HMUserDefaults boolForKey:HMLogoutKey];
    
    DLog(@"lastLogoutNotifiedServer == %@",isNotified?@"YES":@"NO");
    return isNotified;
}
-(void)setLastLogoutNotifiedServer:(BOOL)lastLogoutNotifiedServer
{
    [HMUserDefaults setBool:lastLogoutNotifiedServer forKey:HMLogoutKey];
    [HMUserDefaults synchronize];
    
    DLog(@"setLastLogoutNotifiedServer == %@",lastLogoutNotifiedServer?@"YES":@"NO");
}


-(BOOL)isFamilyCreator
{
    HMFamily * family = [HMFamily familyWithId:self.familyId];
    return [family.creator isEqualToString:self.userId]; // 家庭创建者,超级管理员
}

- (BOOL)isAdministrator {
    
    HMFamily * family = [HMFamily familyWithId:self.familyId];
    return (family.userType == 0); // userType 0:管理员  1: 非管理员
}

-(void)setIsAdministrator:(BOOL)isAdministrator{
    DLog(@"只读方法，set操作不做任何处理");
}

-(NSUInteger)lastFamilyCount{
    return [HMStorage shareInstance].lastFamilyCount;
}
@end

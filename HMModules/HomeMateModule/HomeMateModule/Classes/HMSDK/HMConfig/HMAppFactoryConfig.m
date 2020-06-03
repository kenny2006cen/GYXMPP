//
//  HMAppFactoryConfig.m
//  HomeMateSDK
//
//  Created by PandaLZMing on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppFactoryConfig.h"
#import "HMAppFactoryLocalConfig.h"
#import "HMConstant.h"
#import "HMAppService.h"
#import "HMAppSetting.h"
#import "HMStorage.h"
#import "NSObject+MJKeyValue.h"

static HMAppFactoryConfig * factoryConfig = nil;
@interface HMAppFactoryConfig ()
@property (nonatomic, strong)NSMutableArray <HMAppProductType *> * addDeviceFirstArray;
@property (nonatomic, strong)NSMutableArray <HMAppNaviTab *> * tabBarItemArray;
@property (nonatomic, strong)NSMutableArray * myCenterItemsArray;
@property (nonatomic, strong)NSMutableArray * settingConfigItemsArray;
@property (nonatomic, strong)HMAppSetting * appSetting;
@property (nonatomic, strong)HMAppSettingLanguage * appSettingLangu;
@property (nonatomic, strong)HMAppNaviTab * voiceTabbarItem;
@property (nonatomic, strong)HMAppNaviTab * sceneTabbarItem;
@property (nonatomic, assign)int buildVersionCode;
@property (nonatomic, assign)BOOL appFactoryGetData;
@property (nonatomic, strong)NSMutableArray * appFactoryGetDataCallBacks;
@end


@implementation HMAppFactoryConfig

+ (instancetype)appFactory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factoryConfig = [[HMAppFactoryConfig alloc] init];
    });
    
    return factoryConfig;
}

- (int)versionCode {
    return self.buildVersionCode;
}

- (instancetype)init {
    if (self == [super init]) {
        self.addDeviceFirstArray = [NSMutableArray array];
        self.tabBarItemArray = [NSMutableArray array];
        self.myCenterItemsArray = [NSMutableArray array];
        self.settingConfigItemsArray = [NSMutableArray array];
        self.appFactoryGetDataCallBacks = [NSMutableArray array];
        self.appFactoryGetData = NO;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *buildVersionCode = [infoDictionary objectForKey:@"CFBundleVersion"];//app的build号
        DLog(@"buildVersionCode号:%@\n",buildVersionCode);
        
        NSArray * buildVersionCodeArray = [buildVersionCode componentsSeparatedByString:@"."];
        NSMutableArray * array = [NSMutableArray arrayWithArray:buildVersionCodeArray];
        if(buildVersionCodeArray.count >= 4) {
            int index1 = [array[1] intValue];
            NSString * index1String = [NSString stringWithFormat:@"%02d",index1];
            
            int index2 = [array[2] intValue];
            
            NSString * index2String = [NSString stringWithFormat:@"%02d",index2];
            [array replaceObjectAtIndex:1 withObject:index1String];
            [array replaceObjectAtIndex:2 withObject:index2String];
            buildVersionCode = [array componentsJoinedByString:@""];
            DLog(@"buildVersionCode号:%@\n",buildVersionCode);
            self.buildVersionCode = [buildVersionCode intValue];
        }else {
            // 还没想好怎么处理
        }
    }
    return self;
}

+(NSArray *)localConfigSQL {
    return [HMAppFactoryLocalConfig localConfigSQL];
}

+(BOOL)localConfigDataChange {
    return [HMAppFactoryLocalConfig localConfigDataChange];
}

- (BOOL)supportPhone {
    return self.appSetting.smsRegisterEnable;
}
- (BOOL)supportEmail {
    return self.appSetting.emailRegisterEnable;
}

- (BOOL)supportValueAddedService {
    __block BOOL support = NO;
    NSString *sql = [self m_valueAddedServiceSqlWithSource:self.appSource];
    queryDatabase(sql, ^(FMResultSet *rs) {
        support = [rs intForColumn:@"count"] > 0 ? NO : YES;
    });
    DLog(@"是否支持增值服务 ： %d",support);
    return support;
}

// prviate method
- (NSString *)m_valueAddedServiceSqlWithSource:(NSString *)source {
    NSString *sql = nil;
    if ([source isEqualToString:@"ZhiJia365"]) { // 智家365 很多设备的source都为空
        sql = [NSString stringWithFormat:@"select count() as count from deviceDesc where (source = '%@' or source = '') and model in (select distinct model from device where uid in %@ and delFlag = 0 UNION select distinct model from gateway where uid in %@ and delFlag = 0) and valueAddedService = 0 and delFlag = 0",source,[HMUserGatewayBind uidStatement],[HMUserGatewayBind uidStatement]];
    }else {
        sql = [NSString stringWithFormat:@"select count() as count from deviceDesc where source = '%@' and model in (select distinct model from device where uid in %@ and delFlag = 0 UNION select distinct model from gateway where uid in %@ and delFlag = 0) and valueAddedService = 0 and delFlag = 0",source,[HMUserGatewayBind uidStatement],[HMUserGatewayBind uidStatement]];
    }
    return sql;
}

- (NSString *)appSource {
    return [HMStorage shareInstance].appName;
}

- (BOOL)scanBarEnable {
    return [self.appSetting.scanBarEnable boolValue];
}

/**
 是否校验邮箱注册验证码
 
 @return YES  校验  NO 不校验
 */
- (BOOL)checkEmailRegisterCode {
    if([[HMStorage shareInstance].appName isEqualToString:@"OEM_Korea"]) {
        return YES;
    }
    return NO;
}

/**
 *  获取版本介绍
 *
 *  @return
 */
- (NSString *)updateHistoryUrl {
    return self.appSettingLangu.updateHistoryUrl;
}

- (NSString *)adviceUrl {
    return self.appSettingLangu.adviceUrl;
}
    
/**
 获取appid 用于用户评分
 
 @return
 */
- (NSString *)appId {
    return self.appSetting.aMapKey;
}

/**
 *  版本更新的历史记录
 */
+(NSString *)updateHistoryUrl
{
    NSMutableString *url = [NSMutableString stringWithString:@"http://www.orvibo.com"];
    NSString *sql = [NSString stringWithFormat:@"select updateHistoryUrl from appSettingLanguage where delFlag = 0 and language = '%@'",[RunTimeLanguage deviceLanguage]];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        NSString *updateHistoryUrl = [rs stringForColumn:@"updateHistoryUrl"];
        if ([updateHistoryUrl.lowercaseString hasPrefix:@"http"]) {
            [url setString:updateHistoryUrl];
        }
        
    });
    return url;
}
+ (void)getAppFactoryDataFromServer:(AppFactoryUpdateCallback)callBack{

    LogFuncName();

    if (!isNetworkAvailable()) {
        DLog(@"获取App软件工厂数据时无网络，不再获取");
        if(callBack){
            callBack(NO);
        }
        return;
    }

    BOOL getData = [[HMAppFactoryConfig appFactory] appFactoryGetData];
    if (getData) {
        DLog(@"-----APP工厂数据正在请求数据，要暂存");
        NSMutableDictionary * dict = [NSMutableDictionary  dictionary];
        if (callBack) {
            DLog(@"-----APP工厂数据正在请求数据，要暂存，有回调");
            [dict setObject:callBack forKey:@"callback"];
        }else {
            DLog(@"-----APP工厂数据正在请求数据，要暂存，没有回调");
            [dict setObject:@"1" forKey:@"callback"];
        }
        [[HMAppFactoryConfig appFactory] appFactorySetAppFactoryDataCallBack:dict];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int lastUpdateTime = [self getMaxLastUpdateTime];
        
        dispatch_async(dispatch_queue_create("com.orvibo.getAppFactoryDataFromServer", NULL), ^{
            [self didGetFactoryWithCallBack:callBack lastUpdateTime:lastUpdateTime];
        });
    });
}

+ (void)didGetFactoryWithCallBack:(AppFactoryUpdateCallback)callBack lastUpdateTime:(int)lastUpdateTime
{
    NSError *error = nil;
    
    NSString *descSource = [HMStorage shareInstance].appName;
    NSString *urlString = [NSString stringWithFormat:kGet_APP_Factory_Data_URL,lastUpdateTime,descSource,userAccout().userId?:@"",userAccout().familyId?:@""];
    urlString = dynamicDomainURL(urlString);
    DLog(@"获取APP工厂数据URL:%@",urlString);
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[HMAppFactoryConfig appFactory] setAppFactoryGetData:YES];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];

    if (data) {
        NSDictionary *appFactoryDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error && appFactoryDic) {
            NSNumber *errorCode = appFactoryDic[@"errorCode"];
            if (errorCode.intValue == KReturnValueSuccess) {
                
                [self receivedFactoryData:appFactoryDic callBack:callBack];
                
            }else {
                DLog(@"获取app工厂数据错误码：%@ %@",errorCode,errorCode.intValue == 51 ? @"App工厂数据无更新":@"");
                [[HMAppFactoryConfig appFactory] setAppFactoryGetData:NO];
                if(callBack){
                    callBack(NO);
                }
                [self requestNextData];
            }
        }else {
            [[HMAppFactoryConfig appFactory] setAppFactoryGetData:NO];
            if(callBack){
                callBack(NO);
            }
            [self requestNextData];
            
        }
    }else {
        [[HMAppFactoryConfig appFactory] setAppFactoryGetData:NO];
        if(callBack){
            callBack(NO);
        }
        [self requestNextData];
    }
}

+ (void)receivedFactoryData:(NSDictionary *)appFactoryDic callBack:(AppFactoryUpdateCallback)callBack
{
    DLog(@"http获取APP工厂信息成功:%@",appFactoryDic);
    NSMutableArray *objectsArray = [NSMutableArray array];
    
    
    // APP软件参数配置表 appSetting
    NSArray *appSettingArr = [appFactoryDic objectForKey:@"appSettingInfoList"];
    if ([appSettingArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appSettingArr) {
            HMAppSetting *appSettingObj = [HMAppSetting objectFromDictionary:dic];
            if (appSettingObj) {
                [objectsArray  addObject:appSettingObj];
            }
        }
    }
    
    
    // APP软件参数配置多国语言表 appSettingLanguage
    NSArray *appFactoryDicArr = [appFactoryDic objectForKey:@"appSettingLanguageList"];
    if ([appFactoryDicArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appFactoryDicArr) {
            HMAppSettingLanguage *appSettingLanguageObj = [HMAppSettingLanguage objectFromDictionary:dic];
            if (appSettingLanguageObj) {
                [objectsArray  addObject:appSettingLanguageObj];
            }
        }
    }
    
    // APP导航栏配置表 appNaviTab
    NSArray *appNaviTabArr = [appFactoryDic objectForKey:@"appNaviTabList"];
    if ([appNaviTabArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appNaviTabArr) {
            HMAppNaviTab *appNaviTabObj = [HMAppNaviTab objectFromDictionary:dic];
            if (appNaviTabObj) {
                [objectsArray  addObject:appNaviTabObj];
            }
        }
    }
    
    // APP导航栏多国语言表 appNaviTabLanguage
    NSArray *appNaviTabLanguageArr = [appFactoryDic objectForKey:@"appNaviTabLanguageList"];
    if ([appNaviTabLanguageArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appNaviTabLanguageArr) {
            HMAppNaviTabLanguage *appNaviTabLanguagebObj = [HMAppNaviTabLanguage objectFromDictionary:dic];
            if (appNaviTabLanguagebObj) {
                [objectsArray  addObject:appNaviTabLanguagebObj];
            }
        }
    }
    
    // APP添加设备表 appProductType
    NSArray *appProductTypeArr = [appFactoryDic objectForKey:@"appProductTypeList"];
    if ([appProductTypeArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appProductTypeArr) {
            HMAppProductType *appProductTypeObj = [HMAppProductType objectFromDictionary:dic];
            if (appProductTypeObj) {
                [objectsArray  addObject:appProductTypeObj];
            }
        }
    }
    
    // APP添加设备多国语言表 appProductTypeLanguage
    NSArray *appProductTypeLanguageArr = [appFactoryDic objectForKey:@"appProductTypeLanguageList"];
    if ([appProductTypeLanguageArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appProductTypeLanguageArr) {
            HMAppProductTypeLanguage *appProductTypeLanguageObj = [HMAppProductTypeLanguage objectFromDictionary:dic];
            if (appProductTypeLanguageObj) {
                [objectsArray  addObject:appProductTypeLanguageObj];
            }
        }
    }
    
    // 我的页面配置表 appMyCenter
    NSArray * appMyCenterDicArr = [appFactoryDic objectForKey:@"appMyCenterList"];
    if ([appMyCenterDicArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appMyCenterDicArr) {
            HMAppMyCenter *appSettingLanguageObj = [HMAppMyCenter objectFromDictionary:dic];
            if (appSettingLanguageObj) {
                [objectsArray  addObject:appSettingLanguageObj];
            }
        }
    }
    
    // 我的页面多国语言配置表 appMyCenterLanguage
    NSArray * appMyCenterLanguageDicArr = [appFactoryDic objectForKey:@"appMyCenterLanguageList"];
    if ([appMyCenterLanguageDicArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appMyCenterLanguageDicArr) {
            HMAppMyCenterLanguage *appSettingLanguageObj = [HMAppMyCenterLanguage objectFromDictionary:dic];
            if (appSettingLanguageObj) {
                [objectsArray  addObject:appSettingLanguageObj];
            }
        }
    }
    
    // 服务页面配置表 appService
    NSArray * appServiceDicArr = [appFactoryDic objectForKey:@"appServiceList"];
    if ([appServiceDicArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appServiceDicArr) {
            HMAppService *appServiceObj = [HMAppService objectFromDictionary:dic];
            if (appServiceObj) {
                [objectsArray  addObject:appServiceObj];
            }
        }
    }
    
    // 服务页面语言配置表 appServiceLanguage
    NSArray * appServiceLanguageDicArr = [appFactoryDic objectForKey:@"appServiceLanguageList"];
    if ([appServiceLanguageDicArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in appServiceLanguageDicArr) {
            HMAppServiceLanguage *appServiceLanguageObj = [HMAppServiceLanguage objectFromDictionary:dic];
            if (appServiceLanguageObj) {
                [objectsArray  addObject:appServiceLanguageObj];
            }
        }
    }
    
    [[HMDatabaseManager shareDatabase] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        DLog(@"-----开始把APP工厂表%ld信息写入数据库",(long)objectsArray.count);
        [objectsArray setValue:db forKey:@"insertWithDb"];
        DLog(@"-----APP工厂表信息写入数据库完成");
    }];
    
    if (objectsArray.count) {
        [HMAppFactoryAPI reset];
        DLog(@"-----APP工厂有数据更新返回");
        if(callBack){
            callBack(YES);
        }
        //清除缓存的图片
        NSString *path = @"/HMAPPFactory";
        NSArray * docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docdir = [docdirs objectAtIndex:0];
        
        NSString * configFilePath = [docdir stringByAppendingPathComponent:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:configFilePath]) {
            DLog(@"-----APP工厂有数据更新返回，app工厂图片路径 %@ 存在，删除",configFilePath);
            [[NSFileManager defaultManager] removeItemAtPath:configFilePath error:nil];
        }else {
            DLog(@"-----APP工厂有数据更新返回，app工厂图片路径 %@ 不存在",configFilePath);
        }
        
    }else {
        DLog(@"-----APP工厂没有数据更新返回");
        if(callBack){
            callBack(NO);
        }
    }
    [[HMAppFactoryConfig appFactory] setAppFactoryGetData:NO];
    [self requestNextData];
    
}

+ (void)requestNextData {
    
    NSDictionary * dict = [[HMAppFactoryConfig appFactory] appFactoryGetAppFactoryDataCallBack];
    if (dict) {
        DLog(@"-----APP工厂请求数据返回，还有暂存的数据");
        id callBack = [dict objectForKey:@"callback"];
        if ([callBack isKindOfClass:[NSString class]]) {
            DLog(@"-----APP工厂请求数据返回，还有暂存的数据，暂存的数据没有回调，请求数据");
            [HMAppFactoryConfig getAppFactoryDataFromServer:nil];
        }else {
            DLog(@"-----APP工厂请求数据返回，还有暂存的数据，暂存的数据有回调，请求数据");
            callBack = (AppFactoryUpdateCallback)callBack;
            [HMAppFactoryConfig getAppFactoryDataFromServer:callBack];
        }
    }else {
        DLog(@"-----APP工厂请求数据返回，没有暂存的数据，请求结束");
    }
    
}


/**
 获取六张表最大的 updateTime
 */
+ (int)getMaxLastUpdateTime {

    int lastUpdatime = 0;

    NSString *sql = [NSString stringWithFormat:@"select max(updateTime) as MaxUpdateTime from (select max(updateTime) as updateTime from appNaviTab  UNION select max(updateTime) as updateTime from appNaviTabLanguage UNION select max(updateTime) as updateTime from appProductType UNION select max(updateTime) as updateTime from appProductTypeLanguage UNION select max(updateTime) as updateTime from appSetting UNION select max(updateTime) as updateTime from appSettingLanguage UNION select max(updateTime) as updateTime from appMyCenter UNION select max(updateTime) as updateTime from appMyCenterLanguage UNION select max(updateTime) as updateTime from appService UNION select max(updateTime) as updateTime from appServiceLanguage)"];
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    if ([set next]) {
        NSString *dateStr = [set stringForColumn:@"MaxUpdateTime"];
        if (dateStr
            && (![dateStr isEqualToString:@""])
            && (![dateStr isEqualToString:@"null"])) {

            lastUpdatime = secondWithString(dateStr);
            DLog(@"获取APP工厂最大更新时间：%@",dateStr);
        }
    }
    [set close];

    DLog(@"获取APP工厂最大更新时间：%d",lastUpdatime);
    return lastUpdatime;
}


/**
 判断是否正在下载数据
 
 @return YES 正在下载 NO 没有下载
 */
- (BOOL)appFactoryGetAppFactoryDataFromServer {
    return self.appFactoryGetData;
}



/**
 设置是否正在下载
 
 @param getData YES 正在下载  NO 没有正在下载
 */
- (void)appFactorySetAppFactoryDataFromServer:(BOOL)getData {
    self.appFactoryGetData = getData;
}

/**
 获取保存获取数据的回调
 
 @return
 */
- (NSDictionary *)appFactoryGetAppFactoryDataCallBack {
    if(self.appFactoryGetDataCallBacks.count) {
        NSDictionary * tempDict = self.appFactoryGetDataCallBacks.firstObject;
        NSDictionary * dict = [NSDictionary dictionaryWithDictionary:tempDict];
        [self.appFactoryGetDataCallBacks removeObjectAtIndex:0];
        DLog(@"-----APP获取请求的回调 %@",self.appFactoryGetDataCallBacks);
        return dict;
    }
    
    return nil;
}

/**
 设置保存获取数据的回调
 
 @return
 */
- (void)appFactorySetAppFactoryDataCallBack:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [self.appFactoryGetDataCallBacks addObject:dict];
    
    DLog(@"-----APP暂存请求的回调 %@",self.appFactoryGetDataCallBacks);

}


-(BOOL)nativeAppFactoryData {
    if (self.appSetting) {
        return YES;
    }else {
        return NO;
    }
}

- (void)reset {
    self.appSetting = nil;
    self.appSettingLangu = nil;
    [self.addDeviceFirstArray removeAllObjects];
    [self.tabBarItemArray removeAllObjects];
    [self.myCenterItemsArray removeAllObjects];

}
//'我的' 页面的 (帮助中心 和 关于)
- (NSMutableArray *)settingConfigItems {
    [self myCenterItemsContainShop:YES];
    return _settingConfigItemsArray;
}

//中国idc  开发环境是901 测试环境是902 正式环境是1
- (BOOL)isInChinaIdc {
    int idc = [HMAccount objectWithUserId:userAccout().userId].idc;
    if (idc == 1 || idc == 901 || idc == 902) {
        return YES;
    }
    return NO;
}

-(BOOL)shouldDisplayStore{
    return (CHinese && [self isInChinaIdc]);
}

- (NSMutableArray *)myCenterItemsContainShop:(BOOL)containShop {

    [self.myCenterItemsArray removeAllObjects];
    [self.settingConfigItemsArray removeAllObjects];
    
    BOOL isSupportValueAddService = [self supportValueAddedService];
    BOOL isAdministrator = userAccout().isAdministrator;
    NSString * language = [RunTimeLanguage deviceLanguage];
    BOOL  chinese = [RunTimeLanguage isZh_Hans];
    BOOL  viCenter = userAccout().isLogin /*&& [userAccout() hasHostCanDisplayInMyCenter] v3.6 改成“设备管理”，去掉此逻辑*/ && isAdministrator;
    NSString *appName = [HMStorage shareInstance].appName;
    int verCode = [self versionCode];
    
    NSString *sql = [NSString stringWithFormat:@"select B.name as myCenterName,A.* from appMyCenter A LEFT join appMyCenterLanguage B on A.myCenterId = B.myCenterId where B.language = '%@' and B.delFlag = 0 and A.factoryId = '%@' and A.verCode <= %d and A.delFlag = 0 order by A.groupIndex,A.sequence",language,appName,verCode];
    
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    NSMutableArray * myCenterArray = [NSMutableArray array];

    while ([set next]) {
        
        HMAppMyCenter * myCenter = [HMAppMyCenter object:set];
        
        // item名称异常(为空)则不显示
        if (!myCenter.myCenterName.length
            || [myCenter.myCenterName isEqualToString:@""]
            || [myCenter.myCenterName.lowercaseString isEqualToString:@"null"]) {
            
            DLog(@"工厂item名称异常，不显示此项viewId：%@",myCenter.viewId);
            continue;
        }
        
        if ([myCenter.viewId rangeOfString:@"url|json"].length) {//帮助中心挪到设置里面
            NSArray * viewIdArray = [myCenter.viewId componentsSeparatedByString:@"|"];
            if (viewIdArray.count >= 3) {
                NSString * jsonString = viewIdArray.lastObject;
                NSArray * array = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                BOOL findHelpItem = NO;
                for (NSDictionary * dict in array) {
                    NSString * currentlanguage = language;
                    NSString * language = [dict objectForKey:@"language"];
                    if ([currentlanguage isEqualToString:language]) {
                        //inside为 1 表示挪到设置里面, 0标识否
                        int inside = [[dict objectForKey:@"inside"] intValue];
                        if (inside == 1) {
                            findHelpItem = YES;
                            [self.settingConfigItemsArray addObject:myCenter];
                            break;
                        }
                    }
                }
                if (findHelpItem) {
                    continue;
                }
            }
        }
        
        if ([myCenter.viewId rangeOfString:@"|about"].length) {//关于挪到设置里面
            [self.settingConfigItemsArray addObject:myCenter];
            continue;
        }
        
        if (!isAdministrator) { // 非管理员去掉设备联动
            if ([myCenter.viewId rangeOfString:@"device_linkage"].length) {
                continue;
            }
        }
        
        if ([myCenter.viewId rangeOfString:@"sound"].length) {// 去掉桌面音乐
            continue;
        }
        
        if (!chinese || (!isSupportValueAddService)) {// 非中文去掉商城
            if ([myCenter.viewId rangeOfString:@"|shop"].length) {
                continue;
            }
        }
        
        if (!viCenter) {//没有主机去掉主机
            if ([myCenter.viewId rangeOfString:@"my_host"].length) {
                continue;
            }
        }
        
        if (!containShop) {
            if ([myCenter.viewId rangeOfString:@"|shop"].length) {
                continue;
            }
        }
        
        // 商城，服务, 根据增值服务判断是否显示
        if ([myCenter.viewId rangeOfString:@"|service"].length
            || [myCenter.viewId rangeOfString:@"|tmall"].length) {

            if (!isSupportValueAddService) continue;
            
        }
        
        // 非管理员/家庭没有mixpad隐藏此项
        if ([myCenter.viewId rangeOfString:@"|mixpad"].length) {
            if (!isAdministrator || ![HMDevice allMixPadInFamily].count) {
                continue;
            }
        }
        
        // 若系统版本低于iOS 12，则不显示捷径菜单
        if ([myCenter.viewId rangeOfString:@"|siriShortcuts"].length) {
            if (!isSupportSiriShortcuts()){
                continue;
            }
        }
        
        // 非管理员或者非中国idc，则不显示第三方平台设备入口
        if ([myCenter.viewId rangeOfString:@"skills"].length) {
            if (!isAdministrator || ![self isInChinaIdc]) {
                continue;
            }
        }

        
        if ([myCenter.viewId rangeOfString:@"|store"].length) {
            if (![self shouldDisplayStore]){
                continue; // 2020年3月6日 需求： 只有简体中文&&idc是中国区才显示商城
            }
        }
        
        //组功能
        if([myCenter.viewId rangeOfString:@"|device_group"].length) {
            if (!userAccout().isAdministrator || ![HMDevice countForDownLight]) {
                continue;
            }
        }
        
        if ([myCenter.viewId rangeOfString:@"ad|"].length) {
            
            //广告根据增值服务判断是否显示
            if (!isSupportValueAddService) continue;
            
            //距上次关闭广告间隔没超过48小时,不显示广告
            NSTimeInterval closeTime = [[HMUserDefaults objectForKey:@"HMT1ADCloseTime"] doubleValue];
            NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
            if ((currentTime - closeTime) < (48 * 3600)) continue;
            
            //账号里有对应model的设备, 不显示广告
            NSArray * viewIdArray = [myCenter.viewId componentsSeparatedByString:@"|"];
            if([viewIdArray containsObject:@"ad"]) {
                if([viewIdArray containsObject:@"json"]) {
                    if (viewIdArray.count >= 3) {
                        NSString *jsonStr = viewIdArray.lastObject;
                        NSDictionary *jsonDic = [jsonStr mj_JSONObject];
                        NSArray *picArr = jsonDic[@"no_display"];
                        __block NSInteger count = 0;
                        for (NSDictionary *dic in picArr) {
                            NSString *modelId = dic[@"model_id"];
                            NSString *sql = [NSString stringWithFormat:@"select count() as count from device where model = '%@' and uid in %@ and delFlag = 0", modelId, [HMUserGatewayBind uidStatement]];
                            queryDatabase(sql, ^(FMResultSet *rs) {
                                count = [rs intForColumn:@"count"];
                            });
                            if (count > 0) break;
                        }
                        if (count > 0) continue;
                    }
                }
            }
        }
        
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.viewId = %@",myCenter.viewId];
        NSArray * array = [myCenterArray filteredArrayUsingPredicate:pre];
        if (array.count) {//已经添加了，又有一个，要判断versionCode，只显示versionCode最大的
            HMAppMyCenter * center = array.firstObject;
            if (center.verCode < myCenter.verCode) {
                [myCenterArray replaceObjectAtIndex:[myCenterArray indexOfObject:center] withObject:myCenter];
            }else if(myCenter.verCode == center.verCode){//版本号一样
                if ([myCenter.updateTime compare:center.updateTime] == NSOrderedDescending) {//更新时间大的替换更新时间小的
                    [myCenterArray replaceObjectAtIndex:[myCenterArray indexOfObject:center] withObject:myCenter];
                }
            }
        }else {
            [myCenterArray addObject:myCenter];
        }
    }
    
    [set close];
    
    
    NSSet * groupIndexSet = [NSSet setWithArray:[myCenterArray valueForKey:@"groupIndex"]];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];

    NSArray * groupIndex = [groupIndexSet sortedArrayUsingDescriptors:sortDesc];

    for (NSNumber * number in groupIndex) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupIndex = %d",number.intValue];
        NSArray * array = [myCenterArray filteredArrayUsingPredicate:predicate];//这个查出来顺序会变，还是要在排一下
        if (array.count) {
           NSMutableArray * sortArray = [NSMutableArray arrayWithArray:array];
            [sortArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                HMAppMyCenter * center1 = (HMAppMyCenter *)obj1;
                HMAppMyCenter * center2 = (HMAppMyCenter *)obj2;
                return center1.sequence > center2.sequence;
            }];
            
            [self.myCenterItemsArray addObject:sortArray];
        }
    }
    return self.myCenterItemsArray;
}

/**
 *  获取QQ授权码
 */
- (NSString *)qqAuth {
    
    if ([self.appSetting.qqAuth rangeOfString:@"null"].length || self.appSetting.qqAuth.length == 0) {
        return @"";
    }
    
    return self.appSetting.qqAuth;
}

/**
 *  获取微博授权码
 */
- (NSString *)weiboAuth {
    if ([self.appSetting.weiboAuth rangeOfString:@"null"].length || self.appSetting.weiboAuth.length == 0) {
        return @"";
    }
    return self.appSetting.weiboAuth;

}

/**
 *  获取微信授权码
 */
- (NSString *)wechatAuth {
    if ([self.appSetting.wechatAuth rangeOfString:@"null"].length || self.appSetting.wechatAuth.length == 0) {
        return @"";
    }
    return self.appSetting.wechatAuth;
}


/**
 *  获取微信token
 */
- (NSString *)wechatAuthToken {
    
    // iOS与跟安卓的微信key是一样的，stomp平台上没有iOS专门的设置项
    __block NSString * token = @"";
    NSString *appName = [HMStorage shareInstance].appName;
    NSString *sql = [NSString stringWithFormat:@"select * from appSetting where  factoryId = '%@' and platform = 'Android' and delFlag = 0 order by createTime desc limit 1",appName];
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    if ([set next]) {
        HMAppSetting * appSetting = [HMAppSetting object:set];
        NSArray * array = [appSetting.wechatAuth componentsSeparatedByString:@"|"];
        token = array.lastObject;
    }
    [set close];
    return token;
}

/**
 *  获取taobao授权码
 */
- (NSString *)taobaoAuth {
    
    if ([self.appSetting.keyParam rangeOfString:@"null"].length || self.appSetting.keyParam.length == 0) {
        return @"";
    }
    
    NSError *error = nil;
    NSData *jsonData = [self.appSetting.keyParam dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (!error && [dic isKindOfClass:[NSDictionary class]]) {
        return dic[@"taobaoAppKey"];
    }
    
    return @"";
}

/**
 *  彩生活授权码
 */
- (NSString *)caiShengHuoAuth
{
    if ([self.appSetting.keyParam rangeOfString:@"null"].length || self.appSetting.keyParam.length == 0) {
        return @"";
    }
    
    NSError *error = nil;
    NSData *jsonData = [self.appSetting.keyParam dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (!error && [dic isKindOfClass:[NSDictionary class]]) {
        return dic[@"colourlifeAuth"];
    }
    
    return @"";
}
/**
 *  获取高德地图key
 */
- (NSString *)gaodeMapKey
{
    NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([bundleId isEqualToString:@"com.orvibo.theLifeMaster"]) {//企业板
        return @"8d2127cb92427095fe2d2600012364f2";
    }else if([bundleId isEqualToString:@"com.orvibo.cloudPlatform"]){
        return @"8bff6cff6bb87fbd5e0b0dc710a8f0f7";
    }
    
    if ([self.appSetting.keyParam rangeOfString:@"null"].length ||
        self.appSetting.keyParam.length == 0) {
        // 没有配置或者配置异常，则使用默认的365的key值
    }else{
        
        // 获取到配置信息
        NSError *error = nil;
        NSData *jsonData = [self.appSetting.keyParam dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (!error && [dic isKindOfClass:[NSDictionary class]]) {
            NSString * key = dic[@"gaodeMapKey"];
            if (!isBlankString(key)) {
                return key;
            }
        }
    }
     return @"8bff6cff6bb87fbd5e0b0dc710a8f0f7";
}


/**
 *  获取大拿AppKey
 */
- (NSString *)daNaAppKey {
    NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.orvibo.theLifeMaster"]) {
        return @"ZMMKT7QFhF6olmJIlPsBCZd6e1S2YLD4hrxGbo2694f9/Nw077D2LAhyRBTShzVO";
    }else if([bundleId isEqualToString:@"com.orvibo.cloudPlatform"]){
        return @"gC154+5cDHJ9KVUCfftGb+t1g9HB8eJPZ3v3kA5MW1j9/Nw077D2LAhyRBTShzVO";
    }
    return self.appSetting.daLaCoreCode?:@"gC154+5cDHJ9KVUCfftGb+t1g9HB8eJPZ3v3kA5MW1j9/Nw077D2LAhyRBTShzVO";
}

/**
 *  获取sourceUrl
 */
- (NSString *)sourceUrl {
    NSString *url = self.appSettingLangu.sourceUrl;
    return url;

}

/**
 *  获取用户协议
 */
- (NSString *)agreementUrl {
    return self.appSettingLangu.agreementUrl;
}

/**
 *  隐私协议
 */
- (NSString *)privacyUrl {
    return self.appSettingLangu.privacyUrl;
}

/**
 *  获取商店Url
 */
- (NSString *)shopUrl {
    return self.appSettingLangu.shopUrl;

}

/**
 *  获取商店名称
 */
- (NSString *)shopName {
    return self.appSettingLangu.shopName?self.appSettingLangu.shopName:@"";

}

/**
 *  获取app名称
 */
- (NSString *)appName {
    return self.appSettingLangu.appName?self.appSettingLangu.appName:@"";

}

/**
 *  获取controller的背景颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)controllerBgColor {
    return self.appSetting.controllerBgColor?self.appSetting.controllerBgColor:[UIColor whiteColor];
}

/**
 *  获取彩色字体颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)appFontColor {
    
    if([[HMStorage shareInstance].appName isEqualToString:@"ZhiJia365"]) {
        return RGBCOLORV(0xF18F00);
    }
    
    return self.appSetting ? self.appSetting.lableFontColor :  HomeMateDefaultThemeColor ;
}
- (UIColor *)appFontColorAlpha:(CGFloat)alpha {
    return [[self appFontColor] colorWithAlphaComponent:alpha];
}

/**
 *  获取app主题颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)appTopicColorAlpha:(CGFloat)alpha {
    if([[HMStorage shareInstance].appName isEqualToString:@"ZhiJia365"]) {
        return [RGBCOLORV(0xF18F00) colorWithAlphaComponent:alpha];
    }
    return self.appSetting ? [self.appSetting.appTopicColor colorWithAlphaComponent:alpha] : HomeMateDefaultThemeColor;
}


/**
 获取主题颜色的hex字符串
 
 @return颜色的hex字符串
 */
- (NSString *)appTopicColorString{
    if([[HMStorage shareInstance].appName isEqualToString:@"ZhiJia365"]) {
        return @"#F18F00";
    }
    return self.appSetting.topicColor.length?self.appSetting.topicColor:@"#F18F00";
    
}


/**
 *  获取安防颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)secuityBgColor {
    if([[HMStorage shareInstance].appName isEqualToString:@"ZhiJia365"]) {
        return RGBCOLORV(0x7c6f68);
    }
    
    return self.appSetting.securityColor?self.appSetting.securityColor:HomeMateDefaultThemeColor;
}

/**
 * 获取app设置表
 */
- (HMAppSettingLanguage *)appSettingLanguageModel {
    return self.appSettingLangu;
}

- (HMAppSettingLanguage *)appSettingLangu {
    
        NSString *appName = [HMStorage shareInstance].appName;
        NSString * language = [RunTimeLanguage deviceLanguage];

        NSString *sql = [NSString stringWithFormat:@"select * from appSettingLanguage where factoryId = '%@' and language = '%@' and delFlag = 0 order by createTime desc limit 1",appName,language];
        FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
        if ([set next]) {
            HMAppSettingLanguage * appSetting = [HMAppSettingLanguage object:set];
            _appSettingLangu = appSetting;
        }
        [set close];
    
    return _appSettingLangu;
}

- (HMAppSetting *)appSetting {
    
    if (_appSetting == nil) {
        NSString *appName = [HMStorage shareInstance].appName;
        NSString *sql = [NSString stringWithFormat:@"select * from appSetting where  factoryId = '%@' and platform = 'iOS' and delFlag = 0 order by createTime desc limit 1",appName];
        FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
        
        if ([set next]) {
            HMAppSetting * appSetting = [HMAppSetting object:set];
            self.appSetting = appSetting;
        }
        
        [set close];
    }
    return _appSetting;
}

/**
 *  获取tabbarItem
 *
 *  @return NSArray 包含HMAppNaviTab对象
 */
- (NSArray <HMAppNaviTab *> *)tabBarItems {
    
    if (self.tabBarItemArray.count) {
        [self.tabBarItemArray removeAllObjects];
    }
    self.voiceTabbarItem = nil; // 先置空，再根据数据库中查到的数据，动态决定显示还是不显示语音button
    self.sceneTabbarItem = nil;
    NSString *appName = [HMStorage shareInstance].appName;
    NSString * language = [RunTimeLanguage deviceLanguage];

    NSString *sql = [NSString stringWithFormat:@"select a.*,b.naviName as title from appNaviTab a,appNaviTabLanguage b where a.verCode <= %d and a.factoryId = '%@' and a.delFlag = 0  and b.naviTabId = a.naviTabId and b.language = '%@' and b.delFlag = 0 order by a.sequence ",[self versionCode],appName,language];

    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    while ([set next]) {
        HMAppNaviTab * naviTab = [HMAppNaviTab object:set];
        NSArray *components = [naviTab.viewId componentsSeparatedByString:@"|"];
        if (components.count >= 2) {
            NSString *viewId = components[1];
            if (naviTab.title.length == 0) {
                if([viewId rangeOfString:@"home"].length){
                    naviTab.title = @"Home";
                }else if([viewId rangeOfString:@"scene"].length){
                    naviTab.title = @"scene";
                }else if([viewId rangeOfString:@"secure"].length){
                    naviTab.title = @"secure";
                }else if([viewId rangeOfString:@"my"].length){
                    naviTab.title = @"my";
                }else if([viewId rangeOfString:@"store"].length){
                    naviTab.title = @"store";
                }
            }
            
            if([viewId rangeOfString:@"voice"].length) {//声音单独处理
                // 2020年3月6日需求：智家365不再显示 语音Tab
                // OEM 允许动态配置语音Tab
                if (![@"ZhiJia365" isEqualToString:[self appSource]]) {
                    if(CHinese){
                        self.voiceTabbarItem = naviTab;
                    }
                }
                continue;
            }else if([viewId containsString:@"scene"]) {
                self.sceneTabbarItem = naviTab;
            }else if([viewId containsString:@"store"]) {
                if (![self shouldDisplayStore]){
                    continue; // 2020年3月6日 需求： 只有简体中文&&idc是中国区才显示商城
                }
            }
        }
        
        
        
        
        
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.viewId = %@",naviTab.viewId];
        NSArray * array = [self.tabBarItemArray filteredArrayUsingPredicate:pre];
        if (array.count) {//已经添加了，又有一个，要判断versionCode，只显示versionCode最大的
            HMAppNaviTab * oldNaviTab = array.firstObject;
            if (oldNaviTab.verCode < naviTab.verCode) {
                [self.tabBarItemArray replaceObjectAtIndex:[self.tabBarItemArray indexOfObject:oldNaviTab] withObject:naviTab];
            }else if(oldNaviTab.verCode == naviTab.verCode){//版本号一样
                if ([naviTab.updateTime compare:oldNaviTab.updateTime] == NSOrderedDescending) {//更新时间大的替换更新时间小的
                    [self.tabBarItemArray replaceObjectAtIndex:[self.tabBarItemArray indexOfObject:oldNaviTab] withObject:naviTab];
                }
            }
        }else {
            [self.tabBarItemArray addObject:naviTab];
        }
        
    }
    
    [set close];
    
    
     [self.tabBarItemArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
         HMAppNaviTab * tab1 = (HMAppNaviTab *)obj1;
         HMAppNaviTab * tab2 = (HMAppNaviTab *)obj2;
         return tab1.sequence > tab2.sequence;
     }];
     
    return self.tabBarItemArray;
}

/**
 * 获取声音的item
 */
- (HMAppNaviTab *)voicetabBarItem {
    return self.voiceTabbarItem;
}

- (HMAppNaviTab *)scenetabbarItem {
    return self.sceneTabbarItem;
}

- (NSArray <HMAppProductType *>*)addDeviceFirstLevel {
    
    // 有数据时直接返回
    if (self.addDeviceFirstArray.count) {
         [self.addDeviceFirstArray removeAllObjects];//为了适配多语言
    }
    
    // 没有数据是从数据库查询
    NSString *appName = [HMStorage shareInstance].appName;
    NSString * language = [RunTimeLanguage deviceLanguage];

    NSString * allDevicesql = [NSString stringWithFormat:@"select * from appProductType where verCode <= %d and factoryId = '%@' and language = '%@' and level = 1 and delFlag = 0  order by sequence",[self versionCode],appName,language];
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:allDevicesql];
    
    while ([set next]) {
        HMAppProductType * product = [HMAppProductType object:set];
        if (product.customName.length) {
            product.productName = product.customName;
        }
        
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.productName = %@",product.productName];//这里不能用viewId来判断，因为有二级目录的viewid都为 @""
        NSArray * array = [self.addDeviceFirstArray filteredArrayUsingPredicate:pre];
        if (array.count) {//已经添加了，又有一个，要判断versionCode，只显示versionCode最大的
            HMAppProductType * oldproduct = array.firstObject;
            if (oldproduct.verCode < product.verCode) {
                [self.addDeviceFirstArray replaceObjectAtIndex:[self.addDeviceFirstArray indexOfObject:oldproduct] withObject:product];
            }else if(oldproduct.verCode == product.verCode){//版本号一样
                if ([product.updateTime compare:oldproduct.updateTime] == NSOrderedDescending) {//更新时间大的替换更新时间小的
                    [self.addDeviceFirstArray replaceObjectAtIndex:[self.addDeviceFirstArray indexOfObject:oldproduct] withObject:product];
                }
            }
        }else {
            [self.addDeviceFirstArray addObject:product];
        }
    }
    [set close];
    
    return self.addDeviceFirstArray;
}

- (NSArray <HMAppProductType *>*)addDeviceSecondLevel:(NSString *)preProductTypeId {
    NSMutableArray * allSubDeviceArray = [NSMutableArray array];
    
    NSString *appName = [HMStorage shareInstance].appName;
    NSString * language = [RunTimeLanguage deviceLanguage];
    
    NSString * allDevicesql = [NSString stringWithFormat:@"select * from appProductType where verCode <= %d and factoryId = '%@' and language = '%@' and level = 2 and preProductTypeId = '%@' and delFlag = 0 order by sequence",[self versionCode],appName,language,preProductTypeId];

    FMResultSet *set = executeQuery(allDevicesql);
    
    while ([set next]) {
        HMAppProductType * product = [HMAppProductType object:set];
        if (product.customName.length) {
            product.productName = product.customName;
        }
        
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.productName = %@",product.productName];//这里不能用viewId来判断，因为有二级目录的viewid都为 @""
        NSArray * array = [allSubDeviceArray filteredArrayUsingPredicate:pre];
        if (array.count) {//已经添加了，又有一个同样名字的，要判断versionCode，只显示versionCode最大的
            HMAppProductType * oldproduct = array.firstObject;
            if (oldproduct.verCode < product.verCode) {//版本号大的替换版本号小的
                [allSubDeviceArray replaceObjectAtIndex:[allSubDeviceArray indexOfObject:oldproduct] withObject:product];
            }else if(oldproduct.verCode == product.verCode){//版本号一样
                if ([product.updateTime compare:oldproduct.updateTime] == NSOrderedDescending) {//更新时间大的替换更新时间小的
                    [allSubDeviceArray replaceObjectAtIndex:[allSubDeviceArray indexOfObject:oldproduct] withObject:product];
                }
            }
        }else {
            [allSubDeviceArray addObject:product];
        }
        
    }
    
    [set close];
    
    
    return allSubDeviceArray;
}

/**
 *  根据ViewUrl获取PAppProductType
 *
 *  @return  HMAppProductType对象 有可能为nil
 */
- (HMAppProductType *)getAppProductTypeWithViewUrl:(NSString *)viewUrl {
    
    NSString *appName = [HMStorage shareInstance].appName;
    NSString * language = [RunTimeLanguage deviceLanguage];
    
    NSString * allDevicesql = [NSString stringWithFormat:@"select * from appProductType where verCode <= %d and factoryId = '%@' and language = '%@'  and delFlag = 0 and viewUrl = '%@' order by updateTime desc",[self versionCode],appName,language,viewUrl];
    
    FMResultSet *set = executeQuery(allDevicesql);
    
    while ([set next]) {
        HMAppProductType * product = [HMAppProductType object:set];
        if (product.customName.length) {
            product.productName = product.customName;
        }
        [set close];

        return product;
    }
    
    [set close];
    return nil;
}


- (NSArray<HMAppService *> *)appServiceItemsArr {
    
    NSString *appName = [HMStorage shareInstance].appName;
    NSString * language = [RunTimeLanguage deviceLanguage];
    NSString *sql = [NSString stringWithFormat:@"select a.*, b.name as languageName from appService a, appServiceLanguage b where a.delFlag = 0 and a.id = b.serviceId and b.language = '%@' and a.factoryId = '%@' and a.verCode <= %d order by groupIndex asc, sequence asc",language,appName,[self versionCode]];
    
    FMResultSet *set = executeQuery(sql);
    NSMutableArray <HMAppService *>*tmpArr = [NSMutableArray array];
    while ([set next]) {
        HMAppService * appService = [HMAppService object:set];
        appService.name = [set stringForColumn:@"languageName"];// 把多语言名字付给name属性
        if (!isBlankString(appService.name)) { // 不为空才显示
            [tmpArr addObject:appService];
        }
    }
    [set close];
    
    if (!tmpArr.count) {
        return @[];
    }
    
    // 对查出来的进行分组
    NSMutableArray *appServiceArr = [NSMutableArray array]; // 二维数组

    __block  NSString *preGroupId = [[tmpArr firstObject] groupId];
    __block  NSMutableArray *preSectionArr = [NSMutableArray array];
    [appServiceArr addObject:preSectionArr];
    
    [tmpArr enumerateObjectsUsingBlock:^(HMAppService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSString *currGroupId = obj.groupId;
        if ([currGroupId isEqualToString:preGroupId]) {
            [preSectionArr addObject:obj];
        }else { // 跟前面的groupId不同，则新建一个数组
            NSMutableArray *currSectionArr = [NSMutableArray array];
            preSectionArr = currSectionArr;
            preGroupId = currGroupId;
            [currSectionArr addObject:obj];
            [appServiceArr addObject:currSectionArr];
        }
    }];
    return appServiceArr;
}

- (NSString *)appServiceGroupNameWithGroupId:(NSString *)groupId
{
    __block NSString *groupName = @"";
    NSString *sql = [NSString stringWithFormat:@"select name from appServiceLanguage where serviceId = '%@' and language = '%@' and delFlag = 0",groupId,[RunTimeLanguage deviceLanguage]];
    queryDatabase(sql, ^(FMResultSet *rs) {
        groupName = [rs stringForColumn:@"name"];
    });
    return groupName;
}

- (NSUInteger)personTabBarItemIndex {
    __block NSUInteger index = 0;
    NSArray *tabBarItems = [HMAppFactoryAPI tabBarItems];
    [tabBarItems enumerateObjectsUsingBlock:^(HMAppNaviTab * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.viewId isEqualToString:@"id|my_default"]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}
@end

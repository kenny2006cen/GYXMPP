//
//  AccountSingleton.h
//  Vihome
//
//  Created by Air on 15-3-10.
//  Copyright © 2017年 orvibo. All rights reserved.
//
#import "SingletonClass.h"
#import "AccountProtocol.h"
#import "HMLocalAccount.h"
#import "HMAccount.h"

@interface AccountSingleton : SingletonClass <AccountProtocol>

@property (nonatomic, weak) id <AccountProtocol> delegate;

/**
 *  当前账号对应的userId
 */
@property (nonatomic, strong) NSString                  *userId;

/**
*  当前userId选择的familyId，如果家庭全部被删除，则此值为 nil
*/
@property (nonatomic, strong) NSString                  *familyId;

/**
 本次登录时使用的用户名
 */
@property (nonatomic, strong, readonly) NSString        *userName;

/**
 本次登录时输入的密码
 */
@property (nonatomic, strong, readonly) NSString        *password;

@property (nonatomic, strong, readonly) NSString        *email;

@property (nonatomic, strong, readonly) NSString        *phone;

/**
 *  最近一次登录的本地帐号信息LocalAccount对象
 */
@property (nonatomic, strong, readonly) HMLocalAccount    *currentLocalAccount;

/**
 *  最近一次登录的帐号信息VihomeAccount对象
 */
@property (nonatomic, strong, readonly) HMAccount   *currentAccount;

@property (nonatomic, strong ) NSString             *currentUserName;
@property (nonatomic, strong ) NSString             *currentPassword;

/**
 *  判断当前账号是否绑定了zigbee主机
 */
@property (nonatomic, assign) BOOL                  hasZigbeeHost;

/**
 当前家庭小主机数量
 */
@property (nonatomic, assign) NSUInteger zigbeeMiniCount;


/**
 当前家庭大主机数量
 */
@property (nonatomic, assign) NSUInteger zigbeeVicenterCount;


/**
 *  判断当前账号是否绑定了Coco排插等wifi类设备
 */
@property (nonatomic, assign) BOOL                  hasWifiDevice;

/**
 *  应用是否进入后台
 */
@property (nonatomic, assign) BOOL                  isEnterBackground;

/**
 *  是否处于AP配置模式
 */

@property (nonatomic, assign) BOOL                  isInAPConfiguring;

/**
 *  本次远程登录，服务器返回的错误码
 */
@property (nonatomic, assign) KReturnValue          serverLoginValue;
@property (nonatomic, assign) KReturnValue          localLoginValue;

/**
 *  持续socket链接，比如要接收验证码的时候退到后台去查看短信，此时不能断开链接
 *  此值为 YES 时退到后台不会主动断开server socket，为NO时退到后台主动断开链接
 */
@property (nonatomic, assign) BOOL                  persistSocketFlag;


/**
 *  保存mdns搜索到的网关
 */
@property (nonatomic, strong) NSMutableDictionary *gatewayDicList;

/**
 *  帐号列表，LocalAccount对象
 */
@property (nonatomic, strong, readonly) NSArray *accountArr;


/**
 *  只要手动登录成功一次，此值即为YES，并会保存在本地。直到用户名密码错误或者手动退出登录时才会重置为NO
 */
@property (nonatomic, assign) BOOL   isLogin;

/**
 *  是否正在登录读取数据，如果是，则不弹窗提示设备被删除
 */
@property (nonatomic, assign) BOOL   isReading;


// 用户是否手动退出登录，如果用户手动退出登录，但是回调block却没有执行完，则在执行block之前即return
@property (nonatomic, assign) BOOL isManualLogout;


/**
 *  上一次手动退出登录时，是否成功通知server，如果成功通知server，在退出登录状态下，server不会推送APNS通知
 *  否则，在退出登录状态下，服务器也会推送APNS通知。此值会保存在本地 UserDefault 里面
 */
@property (nonatomic, assign) BOOL lastLogoutNotifiedServer;

/**
 *  today widget UserDefault
 */
@property (nonatomic, strong) NSUserDefaults *widgetUserDefault;

/**
*  当前是否是today widget 正在使用SDK
*/
@property (nonatomic, assign)BOOL isWidget;

/**
 当前userId 在当前 FamilyId 下面是否拥有管理员权限
 */
@property (nonatomic, assign) BOOL   isAdministrator;

/**
 当前userId 是否是当前 FamilyId 的创建者
 */
@property (nonatomic, assign) BOOL   isFamilyCreator;

/**
 刚启动时，用户自动登录的情况下，在本次数据更新之前，上一次的家庭数量，如果 > 0，应先显示首页，如果==0则应先显示无家庭的页面
 */
@property (nonatomic,assign,readonly)NSUInteger lastFamilyCount;

/**
 *  App启动判断是否需要自动登录
 *
 *  @return YES:自动登录   NO:不需要自动登录
 */
-(BOOL)isAutoLogin;

/**
 *  App设置是否自动登录
 *
 *  @param isAutoLogin YES:登录成功设置为YES， 用户点击退出登录按钮设置为NO
 */
-(void)setAutoLogin:(BOOL)isAutoLogin;

/**
 *  登录成功调用该接口，本地保存
 *
 *  @param userName 填明文用户名
 *  @param password 填md5值
 */
-(void)addLocalAccountWithUserName:(NSString *)userName password:(NSString *)password userId:(NSString *)userId;

/**
*  登录成功调用该接口，本地保存userId & token
*/
-(void)addLocalAccountWithUserId:(NSString *)userId token:(NSString *)token;

/**
 *  根据用户名(非昵称)删除一个帐号,只删除localAccount表中的数据（如果要删除account表中的数据以后修改TODO）
 */
-(void)deleteLocalAccountWithUserId:(NSString *)userId;

/**
 *  删除与一个帐号有关的存在数据库的所有数据
 */
-(void)deleteAccountWithUserId:(NSString *)userId;

/**
 *  更新用户昵称
 */
-(void)updateNickName:(NSString *)nickName;


/**
 *  用户手动退出登录
 */
-(void)logoutWithCompletion:(SuccessBlock)completion;

/**
 *  忘记密码后重置密码，或者修改密码后更新内存中的密码
 */
-(void)updatePassword:(NSString *)password;

/**
 *  修改邮箱后更新数据库
 */
- (void)updateEmail:(NSString *)email;

/**
 *  修改手机号后更新数据库
 */
- (void)updatePhone:(NSString *)phone;

/**
 *  向服务器发送退出登录请求，如果SuccessBlock返回 YES，表示服务器已确认客户端退出登录，
 *  服务器不会向APNS服务器再推送设备的状态信息。返回 NO，表示服务器未确认客户端退出登录，
 *  仍然会向当前客户端推送设备的状态信息
 */

- (void)sendLogoutRequestWithTimeout:(NSTimeInterval)timeout completion:(SuccessBlock)completion;

// 添加外部任务，在数据同步完成之后自动执行
// 当前实现的业务为，点击通知栏启动后，如果通知为其他家庭的通知，则切换到对应的家庭
-(void)addOutsideTask:(VoidBlock)task;

-(void)performOutsideTasks;

-(BOOL)hasHostCanDisplayInMyCenter;

@end

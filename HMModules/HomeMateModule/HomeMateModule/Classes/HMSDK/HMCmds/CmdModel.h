/*VIHOME CMD*/


/**
 *  数据库表
 */

#import "HMAlarmMessage.h"      // 报警记录表
#import "HMCameraInfo.h"        // 摄像头信息表

#import "HMDevice.h"            // 设备信息表
#import "HMDeviceSettingModel.h" // 设备设置表
#import "HMDeviceJoinIn.h"      // 设备入网信息表
#import "HMDeviceStatus.h"      // 设备状态表
#import "HMFloor.h"             // 楼层表

#import "HMGateway.h"           // 网关表
#import "HMLinkage.h"           // 联动表
#import "HMLinkageOutput.h"
#import "HMLinkageCondition.h"


#import "HMRemoteBind.h"        // 遥控器绑定表
#import "HMRoom.h"              // 房间表
#import "HMScene.h"             // 情景表
#import "HMSceneBind.h"         // 情景绑定表

#import "HMStandardIr.h"        // 标准红外码表
#import "HMStandardIRDevice.h"  // 设备标准红外码表
#import "HMDeviceIr.h"          // 设备红外码表
#import "HMTiming.h"            // 定时任务表
#import "HMAction.h"

#import "HMLocalAccount.h"            // 本地账号表
#import "HMMessagePush.h"             // 推送开关表
#import "HMVersionModel.h"            // 数据库版本号表
#import "HMUserGatewayBind.h"

#import "HMClotheshorseCutdown.h"     // 晾衣架倒计时表
#import "HMClotheshorseStatus.h"      // 晾衣架状态表

#import "HMAuthorizedUnlockModel.h"   // 授权开锁表
#import "HMDoorUserModel.h"           // 门锁权限表
#import "HMDoorLockRecordModel.h"     // 开关门记录表
#import "HMFrequentlyModeModel.h"     // 设备常用模式表
#import "HMCommonDeviceModel.h"       // 常用设备表
#import "HMCountdownModel.h"          // 倒计时表
#import "HMDeviceDesc.h"              // 设备描述表
#import "HMDeviceLanguage.h"          // 设备语言包
#import "HMQrCodeModel.h"             // 二维码对照表
#import "HMStatusRecordModel.h"      // 状态记录表

#import "HMAccreditPersonModel.h"   // 最近联系人 - 本地使用
#import "HMT1AccreditPersonModel.h" // 最近联系人 - t1\9113本地使用
#import "HMEnergySaveDeviceModel.h"   // 节能提醒设备表
#import "HMHubOnlineModel.h"          //主机是否在线，本地使用
#import "HMT1IgnoreAlertRecordModel.h" //t1忽略的报警消息
#import "HMSecurity.h"              // 安防模式表
#import "HMThirdAccountId.h"        //第三方账号授权表
#import "HMKKIr.h"                  //酷控红外码表 kkIr
#import "HMKKDevice.h"              //酷控设备表kkDevice
#import "HMSecurityWarningModel.h"  // 安防提醒表
#import "HMWarningMemberModel.h"    // 安防打电话成员表
#import "HMEnergyUploadDay.h"       // S31 day电量
#import "HMEnergyUploadWeek.h"      // S31 week电量
#import "HMEnergyUploadMonth.h"     // S31 Month电量
#import "HMTimingGroupModel.h"      // 模式定时表
#import "HMChannelCollectionModel.h"// 频道收藏表
#import "HMSensorData.h"            //传感器数据上报表
#import "HMSensorEvent.h"           // 传感器事件上报表

#import "HMCustomPicture.h"           // 自定义图片表
#import "HMCommonScene.h"           // 常用情景表
#import "HMFloorOrderModel.h"         // 本地楼层排序表
#import "HMRoomOrderModel.h"          //本地房间排序表
#import "HMSceneExtModel.h"         // 本地场景排序表
#import "HMLinkageExtModel.h"       // 本地联动排序表
#import "HMDeviceSort.h"        // 本地设备排序表
#import "HMSecurityDeviceSort.h"   // 安防设备置顶排序表
#import "HMFamilyExtModel.h"      // 本地家庭排序表

#import "HMMessageSecurityModel.h"   //安防消息记录表
#import "HMMessageCommonModel.h"     // 普通消息记录表
#import "HMMessageTypeModel.h"       // 消息类型表
#import "HMDistBoxAttributeModel.h"      // 本地配电箱属性表
#import "HMSensorAverageDataModel.h"     // 本地(光照传感器)历史数据表
#import "HMDeviceBrand.h"            //设备品牌表

#import "HMFamily.h"            //家庭表
#import "HMFamilyUsers.h"       //家庭成员表
#import "HMFamilyInvite.h"      //家庭邀请表

#import "HMGroup.h"                  // 组表
#import "HMGroupMember.h"            // 组成员

#import "HMAppNaviTab.h"                // APP导航栏配置表 appNaviTab
#import "HMAppNaviTabLanguage.h"        // APP导航栏多国语言表 appNaviTabLanguage
#import "HMAppProductType.h"            // APP添加设备表 appProductType
#import "HMAppProductTypeLanguage.h"    // APP添加设备多国语言表 appProductTypeLanguage
#import "HMAppSetting.h"            // APP软件参数配置表 appSetting
#import "HMAppSettingLanguage.h"    // APP软件参数配置多国语言表 appSettingLanguage


#import "HMAppMyCenter.h"
#import "HMAppMyCenterLanguage.h"
#import "HMAppService.h"
#import "HMAppServiceLanguage.h"

#import "HMDeviceAuthority.h"       // 新权限表设备
#import "HMDoorUserBind.h"          //t1门锁用户绑定表
#import "HMLocalDoorUserBind.h"          //c1门锁本地用户绑定表
#import "HMFirmwareModel.h"
#import "HMGroupStatus.h"

#import "HMThemeModel.h" // 彩灯主题表
#import "HMCustomChannel.h"         //自定义频道
#import "HMChannel.h"               //频道表
#import "HMLanCommunicationKeyModel.h" // 局域网通信密钥表


#import "HMFirmwareDownloadManager.h" //门锁固件下载管理类

#import "HMAMapTip.h"    //家庭位置搜索记录表
#import "HMDevicePropertyStatus.h" // 设备属性状态表（新）
#import "HMTaskDistribution.h"
#import "HMMusicModel.h"
#import "HMOauth2ClientsModel.h" // 第三方平台信息表

/**
 *  命令
 */

#import "RequestKeyCmd.h"           // 申请通信密钥
#import "RegisterCmd.h"             // 注册用户
#import "LoginCmd.h"                // 登录
#import "QueryStatisticsCmd.h"      // 查询统计信息
#import "QueryDataCmd.h"            // 查询表数据
#import "ClockSyncCmd.h"            // 时钟同步
#import "ControlDeviceCmd.h"        // 设备控制
#import "HeartbeatCmd.h"            // 心跳包
#import "gatewayBindCmd.h"          // 用户绑定主机
#import "DeviceSearchCmd.h"         // 设备搜索
#import "AddFloorCmd.h"             // 添加楼层
#import "ModifyFloorCmd.h"          // 修改楼层
#import "DeleteFloorCmd.h"          // 删除楼层
#import "AddRoomCmd.h"              // 添加房间
#import "ModifyRoomCmd.h"           // 修改房间
#import "DeleteRoomCmd.h"           // 删除房间
#import "AddCameraCmd.h"            // 创建摄像头
#import "ModifyCameraCmd.h"         // 修改摄像头
#import "AddDeviceCmd.h"            // 创建设备
#import "WiFiAddDevice.h"           // 创建WiFi设备
#import "WiFiAddRFDevice.h"         // 创建RF WiFi子设备
#import "ModifyDeviceCmd.h"         // 修改设备信息
#import "DeleteDeviceCmd.h"         // 删除设备
#import "StartLearningCmd.h"        // 开始学习红外码
#import "StopLearningCmd.h"         // 停止学习红外码
#import "DeleteIRCmd.h"             // 删除红外码
#import "AddRemoteBindCmd.h"        // 添加遥控器绑定  NXP 主机2.3及2.3版本以前支持
#import "ModifyRemoteBindCmd.h"     // 修改遥控器绑定  NXP 主机2.3及2.3版本以前支持
#import "DeleteRemoteBindCmd.h"     // 删除遥控器绑定  NXP 主机2.3及2.3版本以前支持
#import "AddRemoteBindServiceCmd.h"     // 添加遥控器绑定 ember 主机2.4及2.4版本以后支持
#import "ModifyRemoteBindServiceCmd.h"  // 修改遥控器绑定 ember 主机2.4及2.4版本以后支持
#import "DeleteRemoteBindServiceCmd.h"  // 删除遥控器绑定 ember 主机2.4及2.4版本以后支持
#import "ResetCmd.h"                 // 恢复出厂设置
#import "CreateUserCmd.h"           // 创建子账户
#import "DeleteUserCmd.h"           // 删除子账户
#import "ModifyPasswordCmd.h"       // 修改用户密码
#import "RootTransferCmd.h"         // 超级权限转移
#import "ModifyHomeNameCmd.h"       // 修改家庭名称
#import "AddFloorRoomCmd.h"         // 同时添加楼层房间接口

#import "DeviceBindCmd.h"           // 客户端绑定主机
#import "GetSmsCmd.h"               // 获取手机验证码
#import "CheckSmsCmd.h"             // 校验短信验证码
#import "RegisterCmd.h"             // 用户注册
#import "LogoffCmd.h"               // 退出登录
#import "HMAuthority.h"             // 权限表
#import "HMAccount.h"               // 账号表
#import "DeleteLinkageServiceCmd.h"
#import "ReturnCmd.h"   // 客户端返回到gateway的命令
#import "AddTimerCmd.h"
#import "ModifyTimerCmd.h"
#import "ActiveTimerCmd.h"
#import "DeleteTimerCmd.h"
#import "AddInfraredKeyCmd.h"
#import "ModifyInfraredKeyCmd.h"
#import "DelInfraredKeyCmd.h"
#import "ResetPasswordCmd.h"//重置密码
#import "NewAddTimerCmd.h"
#import "NewModifyTimerCmd.h"
#import "NewDeleteTimerCmd.h"
#import "NewActiveTimerCmd.h"
#import "SetNicknameCmd.h"//设置用户昵称
#import "GetEmailCodeCmd.h"//获取邮箱验证码
#import "CheckEmailCodeCmd.h"//校验邮箱验证码
#import "ServerModifyDeviceCmd.h"//向服务器修改设备信息
#import "DeviceUnbindCmd.h"//解绑设备
#import "ServerModifyPasswordCmd.h"//向服务器修改登录密码
#import "UserBindCmd.h"//绑定手机号或邮箱
#import "HMMessage.h" // 接收推送消息
#import "HMMessageLast.h" // 最后消息表
#import "TokenReportCmd.h"

#import "InviteFamilyMemberCmd.h" // 邀请家庭成员
#import "DeleteFamilyMemberCmd.h" // 删除家庭成员
#import "FamilyMemberResponseCmd.h" // 家庭成员邀请请求处理
#import "QueryGatewayCmd.h"         // udp 查找网关
#import "SensorPushCmd.h"           // 传感器推送设置

#import "AuthorizedCancelCmd.h"     // 取消授权
#import "SetDoorlockUserNameCmd.h"  // 设置门锁用户名称接口
#import "SetFrequentlyModeCmd.h"    // 设置设备常用模式
#import "AuthorizedUnlockCmd.h"     // 授权开锁

#import "AddCountdownCmd.h"         // 创建倒计时接口
#import "ModifyCountdownCmd.h"      // 修改倒计时接口
#import "DeleteCountdownCmd.h"      // 删除倒计时接口
#import "ActivateCountdownCmd.h"    // 激活/暂停倒计时接口
#import "ResendAuthorizedSmsCmd.h"  // 重发授权短信接口
#import "DeleteVisitorRecordCmd.h"  // 删除开锁记录信息
#import "SecurityCmd.h"             // 布撤防命令
#import "QueryPowerCmd.h"           // 查询实时功率

#import "SetSecurityWarningCmd.h"  // 设置安防提醒
#import "AddTimingGroupCmd.h"       // 添加模式定时
#import "ModifyTimingGroupCmd.h"    // 修复模式定时
#import "ActiveTimingGroupCmd.h"    // 激活模式定时
#import "DeleteTimingGroupCmd.h"    // 删除模式定时
#import "SetSecurityWarningCmd.h"   // 设置安防提醒
#import "QueryUserNameCmd.h"        // 查询用户名接口(大拿)
#import "InviteUserCmd.h"           // 邀请未注册用户
#import "CollectChannelCmd.h"       // 收藏频道
#import "DeleteCollectChannelCmd.h" // 删除频道
#import "CheckUpgradeStatus.h"      // 查询主机升级状态
#import "QueryWiFiDataCmd.h"        // 读取wifi设备所有数据
#import "GetDanaTokenCmd.h"         // 获取大拿token

#import "BrightnessControlCmd.h"    // 指示灯亮度调节接口
#import "ClearAlarmCmd.h"       // 清除报警接口
#import "AlarmLevelChoiceCmd.h"     // 报警浓度等级设置
#import "AlarmMuteCmd.h"    // 报警静音控制接口
#import "QuerySensorAverageCmd.h" //查询传感器最近24小时数据的平均值
#import "QueryShareUsers.h"//查询设备分享用户接口

#import "HMAvgConcentrationHour.h"      //浓度统计小时表(虚拟表，数据从sensorAverageData表获取)
#import "HMAvgConcentrationDay.h"       //浓度统计日表
#import "HMAvgConcentrationWeek.h"      //浓度统计周表
#import "HMAvgConcentrationMonth.h"     //浓度统计月表
#import "RoomControlDeviceCmd.h"        //按房间控制设备
#import "QueryLastMessageCmd.h"         // 查询最新消息
#import "ThirdBindCmd.h"                //拿到用户信息后去绑定账号
#import "GetSecurityCallCountCmd.h"     //获取安防电话剩余数量
#import "QueryClotheshorseStatusCmd.h" //从服务器查询晾衣架最新状态
#import "ClotheshorseControlCmd.h"     // 晾衣架照明控制指令
#import "SetPowerConfigureSortList.h"   // 设置配电箱排序
#import "AccountVerifyCmd.h"            //拿到用户信息后去验证是否已经注册
#import "ThirdAccountRegisterCmd.h"      //拿到用户信息后进行第三方注册
#import "ReadedMsgNumCmd.h"              //给服务器上报已读信息条数
#import "AccountUnbindCmd.h"            //解绑第三方授权账号
#import "QueryStatusRecordCmd.h"        //查询状态记录
#import "BanShutOffPowerOnPhoneCmd.h"   //禁止手机端关闭电源
#import "ClotheshorseCountdownSettingCmd.h" //晾衣架设置
#import "CustomEletricitySavePointCmd.h"  //自定义配电箱电流保护点
#import "HMLevelDelayCmd.h"               //缓亮缓灭命令
#import "HMOffDelayTimeCmd.h"             //延时关闭命令
#import "SearchUnbindDevicesCmd.h"        //查找未绑定设备
#import "SearchAttributeCmd.h"            //查询设备属性
#import "QueryUserMessage.h"                //查询安防消息
#import "AddFamilyCmd.h"                //新增家庭命令
#import "UpdateFamilyCmd.h"               //修改家庭命令
#import "DeleteFamilyCmd.h"             //删除家庭命令
#import "InviteFamilyCmd.h"             //家庭远程邀请
#import "InviteFamilyResponseCmd.h"            //家庭远程邀请处理
#import "QueryFamilyUsers.h"                //查询家庭成员
#import "QueryFamilyCmd.h"                  //查询家庭
#import "AddSceneServiceCmd.h"              //添加情景(服务器)
#import "ModifySceneServiceCmd.h"           //修改情景(服务器)
#import "DeleteSceneServiceCmd.h"           //删除情景(服务器)
#import "AddSceneBindServiceCmd.h"          //添加情景绑定(服务器)
#import "ModifySceneBindServiceCmd.h"       //修改情景绑定(服务器)
#import "DeleteSceneBindServiceCmd.h"       //删除情景绑定(服务器)
#import "EnableSceneServiceCmd.h"           //执行或上报情景联动
#import "DeleteFamilyUserCmd.h"             //删除家庭成员
#import "LeaveFamilyCmd.h"                     //退出家庭
#import "CheckMultiHubsUpgradeStatusCmd.h"     //查询多主机升级状态

#import "AddLinkageServiceCmd.h"            // 添加联动（new）
#import "SetLinkageServiceCmd.h"            // 编辑联动（new）
#import "ActivateLinkageServiceCmd.h"       // 激活联动 (new)
#import "QuerySecurityStatusCmd.h"          // 查询实时的安防状态信息
#import "ModifyFamilyUsersCmd.h"           //修改成员备注
#import "QueryDistBoxVoltageCmd.h"          // 查询配电箱电压
#import "SetDeviceParamCmd.h"               // 设置设备参数
#import "SetDeviceSubTypeCmd.h"               //设置设备子类型
#import "NewBindHostCmd.h"                  // 绑定主机新接口

#import "AddGroupCmd.h"        //创建组
#import "ModifyGroupCmd.h"     //修改组
#import "DeleteGroupCmd.h"     //删除组
#import "SetGroupMemberCmd.h"  //添加组成员

#import "DataToDeviceCmd.h"   //数据透传

#import "JoinFamilyCmd.h"            // 请求加入家庭
#import "JoinFamilyResponseCmd.h"    // 请求加入家庭处理
#import "SearchFamilyInLanCmd.h"     // 局域网搜索家庭
#import "GetHubStatusCmd.h"          // 获取主机在线状态
#import "JoinFamilyAsAdminCmd.h"     // 请求加入家庭(成为管理员)
#import "QueryBindStatusCmd.h"       // 查询主机状态
#import "ModifyFamilyAuthorityCmd.h" // 修改家庭权限
#import "ModifyFamilyAdminAuthorityCmd.h" // 修改家庭管理员权限
#import "QueryRoomAuthorityCmd.h"       // 查询房间权限
#import "ModifyRoomAuthorityCmd.h"      // 修改房间权限
#import "ModifyDeviceAuthorityCmd.h"    // 修改设备权限

#import "QueryAdminFamilyCmd.h"         // 查找家庭管理员帐号
#import "QueryFamilyByFamilyIdCmd.h"       // 通过familyId查询具体的家庭

#import "VoiceControlCmd.h"             // 语音控制命令
#import "VoiceEndCmd.h"                 // 结束语音控制

#import "SetGenaralGateCmd.h"          // 设置配电箱总闸
#import "OrviboLockQueryBindingCmd.h"          // 查询欧瑞博门锁绑定命令
#import "UpdateGatewayPassword.h"     // 更新网关密钥
#import "OrviboLockAddUserCmd.h" // t1门锁添加用户
#import "OrviboLockDeleteUserCmd.h"// t1门锁删除用户
#import "OrviboLockEditUserCmd.h"// t1门锁修改用户
#import "UploadDeviceStatusRecordCmd.h" //上传设备状态
#import "SetAuthorityUnlockCmd.h"//f1设置临时授权
#import "CancelAuthorityUnlockCmd.h"//f1取消临时授权
#import "QueryFirmwareVersionCmd.h"//查询设备固件版本更新状态
#import "SetGenaralGateCmd.h"           // 设置配电箱总闸
#import "QueryFilterSecurityRecordCmd.h" //查询有过滤条件的安防记录
#import "SequenceSyncCmd.h"              // 排序变更上报
#import "RecoverFamilyCmd.h"            // 恢复家庭
#import "QueryRegisterTypeCmd.h"       // 查询账号注册类型
#import "QueryUserGatewayBindCmd.h"     // 查询用户家庭下的设备绑定信息
#import "FirmwareVersionUploadCmd.h" //固件版本号上传
#import "QuerySceneAuthorityCmd.h" // 查询情景权限
#import "ModifySceneAuthorityCmd.h" // 修改情景权限
#import "QueryQrcodeTokenCmd.h" // 查询二维码信息MixPad
#import "ThemeSettingCmd.h" // 主题设置接口
#import "MassAddRoomCmd.h"      // 批量创建房间
#import "HMGetEPCommunity.h"    // EP停车获取小区信息
#import "HMGetEPCarCmd.h"   // EP停车获取车辆信息
#import "QueryLanCommunicationKey.h" // 查询局域网通信密钥
#import "UdpControlCmd.h" // udp 控制命令
#import "HMQueryNotificationAuthorityCmd.h" // 查询自定义通知权限
#import "OTAUpdateCmd.h" //固件升级(wifi设备)
#import "QueryFamilyDevicesFirmwareVersionCmd.h" //查询家庭下设备是否有新版本固件
#import "QueryUpdateProgressCmd.h" //查询固件升级进度
#import "GatewayUpdateCmd.h"  //主机及主机设备升级
#import "HMQueryUserTerminalDevice.h" //查询指定用户的所有终端设备信息
#import "HMQueryUserGeofenceCmd.h"    //查询用家庭围栏信息
#import "HMReportFamilyGeofenceCmd.h" //进出围栏事件上报
#import "HMQueryDeviceDataCmd.h" // 查询设备数据
#import "QueryDevicePropertyStatusCmd.h" // 查询设备实时属性
#import "QueryDataFromMixPadCmd.h" // 向MixPad App查询当前连接的蓝牙音箱mac地址
#import "UploadLockUsersCmd.h" //app上报门锁用户
#import "EnableLinkageServiceCmd.h" //自动化任务触发
#import "HMQuickDeviceModel.h" //查询快捷页面设备

#import "HMCreateGroupCmd.h"//创建组
#import "HMSetGroupCmd.h"//设置组
#import "HMDeleteGroupCmd.h"//删除组
#import "ThirdPlatfromForwardCmd.h" //第三方平台数据准发接口
#import "NewQueryAuthorityCmd.h"//新查询权限接口
#import "SetPowerOnStateCmd.h"//设置设备上电后状态
#import "SMSCodeLoginCmd.h" //短信验证码登录


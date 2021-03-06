#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HMAPDeleteDeviceProtocol.h"
#import "HMDeviceAPInterface.h"
#import "HMAPGetIp.h"
#import "getgateway.h"
#import "route.h"
#import "HMAPConfigCallback.h"
#import "HMAPConfigEnDecoder.h"
#import "HMAPConfigMsg.h"
#import "HMAPDevice.h"
#import "HMAPSocket.h"
#import "HMAPWifiInfo.h"
#import "HMDeviceBind.h"
#import "HMDeviceConfigTimeOutManager.h"
#import "HMDeviceConfig+C1Lock.h"
#import "HMDeviceConfig.h"
#import "HMAPConfigAPI.h"
#import "HMAPI.h"
#import "HMAPLockAPI.h"
#import "HMAppFactoryAPI.h"
#import "HMBaseAPI.h"
#import "HMBluetoothLockAPI.h"
#import "HMC1LockAPI.h"
#import "HMCountdownAPI.h"
#import "HMDeviceAPI.h"
#import "HMFamilyAPI.h"
#import "HMFirmwareDownloadManager.h"
#import "HMFloorAPI.h"
#import "HMHubAPI.h"
#import "HMLinkageAPI.h"
#import "HMLoginAPI.h"
#import "HMMessageAPI.h"
#import "HMSceneAPI.h"
#import "HMSecurityAPI.h"
#import "HMTimingAPI.h"
#import "HMUdpAPI.h"
#import "HMBluetoothCmd.h"
#import "HMBluetoothDataCenter.h"
#import "HMBluetoothEnDecoder.h"
#import "HMBluetoothLockManager.h"
#import "HMBluetoothManager.h"
#import "HMAPConfigBusiness.h"
#import "HMBaseBusiness.h"
#import "HMBusinessHeader.h"
#import "HMCountDownBusiness.h"
#import "HMDeviceBusinss.h"
#import "HMFamilyBusiness.h"
#import "HMFloorBusiness.h"
#import "HMHubBusiness.h"
#import "HMLoginBusiness+Local.h"
#import "HMLoginBusiness+Token.h"
#import "HMLoginBusiness.h"
#import "HMLinkageBusiness.h"
#import "HMMessageBusiness.h"
#import "HMSceneBusiness.h"
#import "HMSecurityBusiness.h"
#import "HMTimingBusiness.h"
#import "HMUdpBusiness.h"
#import "SingletonClass.h"
#import "AccountUnbindCmd.h"
#import "AccountVerifyCmd.h"
#import "ActivateCountdownCmd.h"
#import "ActivateLinkageServiceCmd.h"
#import "ActivateSceneSeviceCmd.h"
#import "ActiveTimerCmd.h"
#import "ActiveTimingGroupCmd.h"
#import "AddCameraCmd.h"
#import "AddCountdownCmd.h"
#import "AddDeviceCmd.h"
#import "AddFamilyCmd.h"
#import "AddFloorCmd.h"
#import "AddFloorRoomCmd.h"
#import "AddGroupCmd.h"
#import "AddInfraredKeyCmd.h"
#import "AddLinkageServiceCmd.h"
#import "AddRemoteBindCmd.h"
#import "AddRemoteBindServiceCmd.h"
#import "AddRoomCmd.h"
#import "AddSceneBindServiceCmd.h"
#import "AddSceneServiceCmd.h"
#import "AddTimerCmd.h"
#import "AddTimingGroupCmd.h"
#import "AlarmLevelChoiceCmd.h"
#import "AlarmMuteCmd.h"
#import "AuthorizedCancelCmd.h"
#import "AuthorizedUnlockCmd.h"
#import "BanShutOffPowerOnPhoneCmd.h"
#import "BaseCmd.h"
#import "BrightnessControlCmd.h"
#import "CancelAuthorityUnlockCmd.h"
#import "CheckEmailCodeCmd.h"
#import "CheckMultiHubsUpgradeStatusCmd.h"
#import "CheckSmsCmd.h"
#import "CheckUpgradeStatus.h"
#import "ClearAlarmCmd.h"
#import "ClockSyncCmd.h"
#import "ClotheshorseControlCmd.h"
#import "ClotheshorseCountdownSettingCmd.h"
#import "CmdModel.h"
#import "CollectChannelCmd.h"
#import "ControlDeviceCmd.h"
#import "CreateUserCmd.h"
#import "CustomEletricitySavePointCmd.h"
#import "DataToDeviceCmd.h"
#import "DeleteCollectChannelCmd.h"
#import "DeleteCountdownCmd.h"
#import "DeleteDeviceCmd.h"
#import "DeleteFamilyCmd.h"
#import "DeleteFamilyMemberCmd.h"
#import "DeleteFamilyUserCmd.h"
#import "DeleteFloorCmd.h"
#import "DeleteGroupCmd.h"
#import "DeleteIRCmd.h"
#import "DeleteLinkageServiceCmd.h"
#import "DeleteRemoteBindCmd.h"
#import "DeleteRemoteBindServiceCmd.h"
#import "DeleteRoomCmd.h"
#import "DeleteSceneBindServiceCmd.h"
#import "DeleteSceneServiceCmd.h"
#import "DeleteTimerCmd.h"
#import "DeleteTimingGroupCmd.h"
#import "DeleteUserCmd.h"
#import "DeleteVisitorRecordCmd.h"
#import "DelInfraredKeyCmd.h"
#import "DeviceBindCmd.h"
#import "DeviceSearchCmd.h"
#import "DeviceUnbindCmd.h"
#import "EnableLinkageServiceCmd.h"
#import "EnableSceneServiceCmd.h"
#import "FamilyMemberResponseCmd.h"
#import "FirmwareVersionUploadCmd.h"
#import "gatewayBindCmd.h"
#import "GatewayUpdateCmd.h"
#import "GetDanaTokenCmd.h"
#import "GetEmailCodeCmd.h"
#import "GetHubStatusCmd.h"
#import "GetSecurityCallCountCmd.h"
#import "GetSmsCmd.h"
#import "HeartbeatCmd.h"
#import "HMCreateGroupCmd.h"
#import "HMDeleteGroupCmd.h"
#import "HMGetEPCarCmd.h"
#import "HMGetEPCommunity.h"
#import "HMLevelDelayCmd.h"
#import "HMOffDelayTimeCmd.h"
#import "HMOneKeyLoginCmd.h"
#import "HMOneKeyLoginPhoneCmd.h"
#import "HMQueryDeviceDataCmd.h"
#import "HMQueryLoginTokenCmd.h"
#import "HMQueryNotificationAuthorityCmd.h"
#import "HMQueryUserGeofenceCmd.h"
#import "HMQueryUserTerminalDevice.h"
#import "HMReportFamilyGeofenceCmd.h"
#import "HMSetGroupCmd.h"
#import "HMTokenLoginCmd.h"
#import "InviteFamilyCmd.h"
#import "InviteFamilyMemberCmd.h"
#import "InviteFamilyResponseCmd.h"
#import "InviteUserCmd.h"
#import "JoinFamilyAsAdminCmd.h"
#import "JoinFamilyCmd.h"
#import "JoinFamilyResponseCmd.h"
#import "LeaveFamilyCmd.h"
#import "LoginCmd.h"
#import "LogoffCmd.h"
#import "MassAddRoomCmd.h"
#import "ModifyCameraCmd.h"
#import "ModifyCountdownCmd.h"
#import "ModifyDeviceAuthorityCmd.h"
#import "ModifyDeviceCmd.h"
#import "ModifyFamilyAdminAuthorityCmd.h"
#import "ModifyFamilyAuthorityCmd.h"
#import "ModifyFamilyUsersCmd.h"
#import "ModifyFloorCmd.h"
#import "ModifyGroupCmd.h"
#import "ModifyHomeNameCmd.h"
#import "ModifyInfraredKeyCmd.h"
#import "ModifyPasswordCmd.h"
#import "ModifyRemoteBindCmd.h"
#import "ModifyRemoteBindServiceCmd.h"
#import "ModifyRoomAuthorityCmd.h"
#import "ModifyRoomCmd.h"
#import "ModifySceneAuthorityCmd.h"
#import "ModifySceneBindServiceCmd.h"
#import "ModifySceneServiceCmd.h"
#import "ModifyTimerCmd.h"
#import "ModifyTimingGroupCmd.h"
#import "NewActiveTimerCmd.h"
#import "NewAddTimerCmd.h"
#import "NewBindHostCmd.h"
#import "NewDeleteTimerCmd.h"
#import "NewModifyTimerCmd.h"
#import "NewQueryAuthorityCmd.h"
#import "OrviboLockAddUserCmd.h"
#import "OrviboLockDeleteUserCmd.h"
#import "OrviboLockEditUserCmd.h"
#import "OrviboLockQueryBindingCmd.h"
#import "OTAUpdateCmd.h"
#import "QueryAdminFamilyCmd.h"
#import "QueryBindStatusCmd.h"
#import "QueryClotheshorseStatusCmd.h"
#import "QueryDataCmd.h"
#import "QueryDataFromMixPadCmd.h"
#import "QueryDevicePropertyStatusCmd.h"
#import "QueryDistBoxVoltageCmd.h"
#import "QueryFamilyByFamilyIdCmd.h"
#import "QueryFamilyCmd.h"
#import "QueryFamilyDevicesFirmwareVersionCmd.h"
#import "QueryFamilyUsers.h"
#import "QueryFilterSecurityRecordCmd.h"
#import "QueryFirmwareVersionCmd.h"
#import "QueryGatewayCmd.h"
#import "QueryLanCommunicationKey.h"
#import "QueryLastMessageCmd.h"
#import "QueryPowerCmd.h"
#import "QueryQrcodeTokenCmd.h"
#import "QueryRegisterTypeCmd.h"
#import "QueryRoomAuthorityCmd.h"
#import "QuerySceneAuthorityCmd.h"
#import "QuerySecurityStatusCmd.h"
#import "QuerySensorAverageCmd.h"
#import "QueryShareUsers.h"
#import "QuerySongListCmd.h"
#import "QueryStatisticsCmd.h"
#import "QueryStatusCmd.h"
#import "QueryStatusRecordCmd.h"
#import "QueryUpdateProgressCmd.h"
#import "QueryUserGatewayBindCmd.h"
#import "QueryUserMessage.h"
#import "QueryUserNameCmd.h"
#import "QueryWeatherCmd.h"
#import "QueryWiFiDataCmd.h"
#import "ReadedMsgNumCmd.h"
#import "RecoverFamilyCmd.h"
#import "RegisterCmd.h"
#import "RequestKeyCmd.h"
#import "ResendAuthorizedSmsCmd.h"
#import "ResetCmd.h"
#import "ResetPasswordCmd.h"
#import "ReturnCmd.h"
#import "RoomControlDeviceCmd.h"
#import "RootTransferCmd.h"
#import "SearchAttributeCmd.h"
#import "SearchFamilyInLanCmd.h"
#import "SearchUnbindDevicesCmd.h"
#import "SecurityCmd.h"
#import "SensorPushCmd.h"
#import "SequenceSyncCmd.h"
#import "ServerModifyDeviceCmd.h"
#import "ServerModifyPasswordCmd.h"
#import "SetAuthorityUnlockCmd.h"
#import "SetDeviceParamCmd.h"
#import "SetDeviceSubTypeCmd.h"
#import "SetDoorlockUserNameCmd.h"
#import "SetFrequentlyModeCmd.h"
#import "SetGenaralGateCmd.h"
#import "SetGroupMemberCmd.h"
#import "SetLinkageServiceCmd.h"
#import "SetNicknameCmd.h"
#import "SetPowerConfigureSortList.h"
#import "SetPowerOnStateCmd.h"
#import "SetSecurityWarningCmd.h"
#import "SMSCodeLoginCmd.h"
#import "StartLearningCmd.h"
#import "StopLearningCmd.h"
#import "ThemeSettingCmd.h"
#import "ThirdAccountRegisterCmd.h"
#import "ThirdBindCmd.h"
#import "ThirdPlatfromForwardCmd.h"
#import "TimerPushCmd.h"
#import "TokenReportCmd.h"
#import "UdpControlCmd.h"
#import "UpdateFamilyCmd.h"
#import "UpdateGatewayPassword.h"
#import "UploadDeviceStatusRecordCmd.h"
#import "UploadLockUsersCmd.h"
#import "UserBindCmd.h"
#import "VoiceControlCmd.h"
#import "VoiceEndCmd.h"
#import "WiFiAddDevice.h"
#import "WiFiAddRFDevice.h"
#import "HMAppFactoryConfig.h"
#import "HMAppFactoryLocalConfig.h"
#import "HMCache.h"
#import "HMDescConfig.h"
#import "HMStorage.h"
#import "RunTimeLanguage.h"
#import "HMConstant.h"
#import "NSData+AES.h"
#import "NSData+CRC32.h"
#import "NSObject+Foreground.h"
#import "NSObject+Observer.h"
#import "NSObject+Save.h"
#import "NSString+SortNumber.h"
#import "UIButton+EnlargeEdge.h"
#import "HMNotifications.h"
#import "HMProtocol.h"
#import "HMTypes.h"
#import "HMUtil.h"
#import "BCCKeychain.h"
#import "LogMacro.h"
#import "AccountProtocol.h"
#import "AccountSingleton+RT.h"
#import "AccountSingleton+Widget.h"
#import "AccountSingleton.h"
#import "HMAccount.h"
#import "HMAccreditPersonModel.h"
#import "HMAction.h"
#import "HMAlarmMessage.h"
#import "HMAMapTip.h"
#import "HMAppMyCenter.h"
#import "HMAppMyCenterLanguage.h"
#import "HMAppNaviTab.h"
#import "HMAppNaviTabLanguage.h"
#import "HMAppProductType.h"
#import "HMAppProductTypeLanguage.h"
#import "HMAppService.h"
#import "HMAppServiceLanguage.h"
#import "HMAppSetting.h"
#import "HMAppSettingLanguage.h"
#import "HMAuthority.h"
#import "HMAuthorizedUnlockModel.h"
#import "HMAvgConcentrationBaseModel.h"
#import "HMAvgConcentrationDay.h"
#import "HMAvgConcentrationHour.h"
#import "HMAvgConcentrationMonth.h"
#import "HMAvgConcentrationWeek.h"
#import "HMBaseModel+Extension.h"
#import "HMBaseModel.h"
#import "HMCameraInfo.h"
#import "HMChannel.h"
#import "HMChannelCollectionModel.h"
#import "HMClotheshorseCutdown.h"
#import "HMClotheshorseStatus.h"
#import "HMCommonDeviceModel.h"
#import "HMCommonScene.h"
#import "HMCountdownModel.h"
#import "HMCustomChannel.h"
#import "HMCustomNotificationAuthority.h"
#import "HMCustomPicture.h"
#import "HMDatabaseManager+Changed.h"
#import "HMDatabaseManager.h"
#import "HMDevice.h"
#import "HMDeviceAuthority.h"
#import "HMDeviceBrand.h"
#import "HMDeviceDesc.h"
#import "HMDeviceIr.h"
#import "HMDeviceJoinIn.h"
#import "HMDeviceLanguage.h"
#import "HMDevicePropertyStatus.h"
#import "HMDeviceSettingModel.h"
#import "HMDeviceSort.h"
#import "HMDeviceStatus.h"
#import "HMDistBoxAttributeModel.h"
#import "HMDoorLockRecordModel.h"
#import "HMDoorUserBind.h"
#import "HMDoorUserModel.h"
#import "HMEnergySaveDeviceModel.h"
#import "HMEnergyUploadBaseModel.h"
#import "HMEnergyUploadDay.h"
#import "HMEnergyUploadMonth.h"
#import "HMEnergyUploadWeek.h"
#import "HMFamily.h"
#import "HMFamilyExtModel.h"
#import "HMFamilyInvite.h"
#import "HMFamilyUsers.h"
#import "HMFirmwareModel.h"
#import "HMFloor.h"
#import "HMFloorOrderModel.h"
#import "HMFrequentlyModeModel.h"
#import "HMGateway.h"
#import "HMGroup.h"
#import "HMGroupMember.h"
#import "HMGroupStatus.h"
#import "HMHubOnlineModel.h"
#import "HMKKDevice.h"
#import "HMKKIr.h"
#import "HMLanCommunicationKeyModel.h"
#import "HMLinkage.h"
#import "HMLinkageCondition.h"
#import "HMLinkageExtModel.h"
#import "HMLinkageOutput.h"
#import "HMLocalAccount.h"
#import "HMLocalDoorUserBind.h"
#import "HMMessage.h"
#import "HMMessageCommonModel.h"
#import "HMMessageLast.h"
#import "HMMessagePush.h"
#import "HMMessageSecurityModel.h"
#import "HMMessageTypeModel.h"
#import "HMMusicModel.h"
#import "HMOauth2ClientsModel.h"
#import "HMProductModel.h"
#import "HMQrCodeModel.h"
#import "HMQuickDeviceModel.h"
#import "HMRemoteBind.h"
#import "HMRoom.h"
#import "HMRoomOrderModel.h"
#import "HMScene.h"
#import "HMSceneBind.h"
#import "HMSceneExtModel.h"
#import "HMSecurity.h"
#import "HMSecurityDeviceSort.h"
#import "HMSecurityWarningModel.h"
#import "HMSensorAverageDataModel.h"
#import "HMSensorData.h"
#import "HMSensorEvent.h"
#import "HMStandardIr.h"
#import "HMStandardIRDevice.h"
#import "HMStatusRecordModel.h"
#import "HMT1AccreditPersonModel.h"
#import "HMT1IgnoreAlertRecordModel.h"
#import "HMThemeModel.h"
#import "HMThirdAccountId.h"
#import "HMTiming.h"
#import "HMTimingGroupModel.h"
#import "HMUserGatewayBind.h"
#import "HMVersionModel.h"
#import "HMWarningMemberModel.h"
#import "Gateway+Foreground.h"
#import "Gateway+HeartBeat.h"
#import "Gateway+Receive.h"
#import "Gateway+RT.h"
#import "Gateway+Send.h"
#import "Gateway+Tcp.h"
#import "Gateway.h"
#import "GlobalSocket.h"
#import "HMNetworkMonitor.h"
#import "HMTaskDistribution.h"
#import "HMTaskManager.h"
#import "NSMutableData+Socket.h"
#import "RemoteGateway+RT.h"
#import "RemoteGateway+WiFi.h"
#import "RemoteGateway.h"
#import "SearchMdns+FindGateway.h"
#import "SearchMdns+UdpSearch.h"
#import "SearchMdns.h"
#import "SocketSend.h"
#import "HMSDK.h"
#import "BLUtility.h"
#import "HMAirConditionUtil.h"
#import "HMCommonChannelUtil.h"
#import "HMVRVAirConditionUtil.h"
#import "RGB_FLOAT_HSL.h"
#import "HomeMateSDK.h"

FOUNDATION_EXPORT double HomeMateModuleVersionNumber;
FOUNDATION_EXPORT const unsigned char HomeMateModuleVersionString[];


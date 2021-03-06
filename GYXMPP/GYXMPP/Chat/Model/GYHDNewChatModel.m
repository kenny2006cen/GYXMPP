//
//  GYHDNewChatModel.m
//  HSConsumer
//
//  Created by shiang on 16/2/26.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDNewChatModel.h"
// ID = 4;
//"MSG_Body" =
//"{\"msg_code\":\"00\",\"msg_content\":\"1\",\"msg_icon\":\"http:\\/\\/192.168.228.97:9099\\/v1\\/tfs\\/T1B8LTByhT1R4cSCrK.png\",\"msg_note\":\"\U5c0f\U4e09\",\"msg_type\":\"2\",\"sub_msg_code\":\"10101\"}";
//"MSG_Card" = "c_06112111025";
//"MSG_DATA" = "";
//"MSG_FromID" = "m_c_06112111025@im.gy.com/mobile_im";
//"MSG_ID" = 1456458048521;
//"MSG_Read" = 0;
//"MSG_RecvTime" = "2016-02-26 03:41:23 +0000";
//"MSG_Self" = 0;
//"MSG_SendTime" = "2016-02-26 03:40:48 +0000";
//"MSG_State" = 1;
//"MSG_ToID" = "m_c_06112110088@im.gy.com";
//"MSG_Type" = 15;
@interface GYHDNewChatModel ()
/**消息数字ID*/
@property(nonatomic, copy, readwrite) NSString *chatMessageID;
/**消息富文本*/
@property(nonatomic, strong, readwrite)
    NSAttributedString *chatContentAttString;
/**消息体*/
@property(nonatomic, copy, readwrite) NSString *chatBody;
/**消息ID*/
@property(nonatomic, copy, readwrite) NSString *chatCard;
/**消息类型*/
@property(nonatomic, copy, readwrite) NSString *chatType;
/**发送者FromID*/
@property(nonatomic, copy, readwrite) NSString *chatFromID;
/**接收者ToID*/
@property(nonatomic, copy, readwrite) NSString *chatToID;
/**是否为自己发送*/
@property(nonatomic, assign, readwrite) BOOL chatIsSelfSend;
@end

@implementation GYHDNewChatModel
+ (instancetype)chatModelWithDictionary:(NSDictionary *)dict {
  return [[self alloc] initWithDictionary:dict];
}
- (instancetype)initWithDictionary:(NSDictionary *)dict;
{
  if (self = [super init]) {
    _chatMessageID = dict[@"MSG_ID"];
    _chatBody = dict[@"MSG_Body"];
    _chatCard = dict[@"MSG_Card"];
    _chatDataString = dict[@"MSG_DataString"];
    _chatFromID = dict[@"MSG_FromID"];
    _chatToID = dict[@"MSG_ToID"];
//    _chatRecvTime = dict[@"MSG_RecvTime"]; modify by jlc from wangbiao
      _chatRecvTime = dict[@"MSG_SendTime"];

    _chatIsSelfSend = [dict[@"MSG_Self"] integerValue];
    _chatSendState = [dict[@"MSG_State"] integerValue];
    [self setup];
  }
  return self;
}
- (void)setup {
    /*
  NSDictionary *bodyDict = [Utils stringToDictionary:self.chatBody];
  switch ([bodyDict[@"msg_code"] integerValue]) {
    case GYHDDataBaseCenterMessageChatText:  //文本消息
    {
      NSMutableString *content = bodyDict[@"msg_content"];
      if (![content isEqualToString:@""] && content != nil) {
        // add by jianglincen
        //接受消息时，去除换行和首尾空白字符

        //              NSString * realStr = [content
        //              stringByTrimmingCharactersInSet:[NSCharacterSet
        //              whitespaceAndNewlineCharacterSet]];
        //              //去除掉首尾的空白字符和换行字符
        NSString *realStr = [content stringByReplacingOccurrencesOfString:@"\r"
                                                               withString:@""];
        realStr = [realStr stringByReplacingOccurrencesOfString:@"\n"
                                                     withString:@""];

        NSMutableDictionary *attDict = [NSMutableDictionary dictionary];
        attDict[NSFontAttributeName] = [UIFont systemFontOfSize:16.0];
        //              NSMutableAttributedString
        //              *messageListContentAttributedStr   =
        //              [[GYHDMessageCenter sharedInstance]
        //              attStringWithString:content imageFrame:CGRectMake(0, -2,
        //              16.0, 16.0)attributes:attDict];
        NSMutableAttributedString *messageListContentAttributedStr =
            [[GYHDMessageCenter sharedInstance]
                attStringWithString:realStr
                         imageFrame:CGRectMake(0, -2, 16.0, 16.0)
                         attributes:attDict];

        _chatContentAttString = messageListContentAttributedStr;
      }
      break;
    }
    default:
      break;
  }
     */
}

@end

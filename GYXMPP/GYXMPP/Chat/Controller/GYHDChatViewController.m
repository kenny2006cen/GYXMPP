//
//  GYHDChatViewController.m
//  HSConsumer
//
//  Created by shiang on 15/12/30.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

#import "GYHDChatViewController.h"
#import "GYHDMessageCenter.h"
#import "GYHDInputView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "GYHDNewChatModel.h"
#import "GYHDLeftChatTextCell.h"
#import "GYHDRightChatTextCell.h"
#import "GYHDLeftChatImageCell.h"
#import "GYHDRightChatImageCell.h"
#import "GYHDLeftChatVideoCell.h"
#import "GYHDRightChatVideoCell.h"
#import "GYHDLeftChatAudioCell.h"
#import "GYHDRightChatAudioCell.h"
#import "GYHDAudioTool.h"
#import "GYHDChatImageShowView.h"
#import "GYHDChatVideoShowView.h"
#import "GYHDCompanyViewController.h"
#import "GYHDConsumerInfoViewController.h"
#import "GYHDCompanyInfoViewController.h"
#import "GYPhotoGroupView.h"

static NSInteger const selectChatCount = 10;
@interface GYHDChatViewController ()<UITableViewDelegate,UITableViewDataSource,GYHDInputViewDelegate,GYHDChatDelegate>{

    UIButton *titleBtn;//顶部自定义头像
}
/**
 * 聊天消息控制器
 */
@property(nonatomic, weak)UITableView *chatTableView;
/**
 * 记录聊天内容的数组
 */
@property(nonatomic, strong)NSMutableArray *chatArrayM;
/**
 * 发送者ID
 */
@property(nonatomic, copy)NSString  *sendMessageID;
/**
 * 接收者ID
 */
@property(nonatomic, copy)NSString  *recvMessageID;
/**
 * 输入条
 */
@property(nonatomic, weak)GYHDInputView *chatInputView;
/**记录左边上次播放的音频的View*/
@property(nonatomic, weak)GYHDLeftChatAudioCell *leftAudioCell;
/**记录右边上次播放的音频的View*/
@property(nonatomic, weak)GYHDRightChatAudioCell *rightAudioCell;
@property(nonatomic ,assign)CGFloat frontY;
@end
#define  KTestString @"e_06112130000_0000"

@implementation GYHDChatViewController

- (NSMutableArray *)chatArrayM {
    if (!_chatArrayM) {
        _chatArrayM = [NSMutableArray array];
    }
    return _chatArrayM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor  = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
       @weakify(self);
    UITableView *chatTableView = [[UITableView alloc] init];
    chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatTableView.delegate = self;
    chatTableView.dataSource = self;
    chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    chatTableView.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [chatTableView registerClass:[GYHDLeftChatTextCell class] forCellReuseIdentifier:@"GYHDLeftChatTextCellID"];
    [chatTableView registerClass:[GYHDRightChatTextCell class] forCellReuseIdentifier:@"GYHDRightChatTextCellID"];
    [chatTableView registerClass:[GYHDLeftChatImageCell class] forCellReuseIdentifier:@"GYHDLeftChatImageCellID"];
    [chatTableView registerClass:[GYHDRightChatImageCell class] forCellReuseIdentifier:@"GYHDRightChatImageCellID"];
    [chatTableView registerClass:[GYHDLeftChatVideoCell class] forCellReuseIdentifier:@"GYHDLeftChatVideoCellID"];
    [chatTableView registerClass:[GYHDRightChatVideoCell class] forCellReuseIdentifier:@"GYHDRightChatVideoCellID"];
    [chatTableView registerClass:[GYHDLeftChatAudioCell class] forCellReuseIdentifier:@"GYHDLeftChatAudioCellID"];
    [chatTableView registerClass:[GYHDRightChatAudioCell class] forCellReuseIdentifier:@"GYHDRightChatAudioCellID"];
    [self.view addSubview:chatTableView];
    _chatTableView = chatTableView;
    [chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(kScreenHeight - 105 -64+15);
    }];

    
    //1. 输入View
    GYHDInputView *chatInputView = [[GYHDInputView alloc] init];
    chatInputView.delegate = self;
 //   [self.view addSubview:chatInputView];
    _chatInputView = chatInputView;

    [chatInputView showToSuperView:self.view];
    [self.chatInputView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];

    //此句会导致键盘弹起状态下,滑动表格时候灰白UIView弹起现象，故而隐藏之!by jianglincen
  //  [kDefaultNotificationCenter addObserver:self selector:@selector(chatInputViewDiss) name:UIKeyboardWillHideNotification object:nil];
    //2. 添加聊天显示视图
   // DDLogCError(@"当前标题=%@",self.title);
    
    //此方法从消费者消息页面进来self.title一直等于852(某一用户的名称),其他页面没有
    [self reSetNavTitleView];
    
}


-(void)reSetNavTitleView{
    
   titleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [titleBtn setFrame:CGRectMake(kScreenWidth/4.0, 0, kScreenWidth/2.0, 44)];
   
    //
    [titleBtn setImage:[UIImage imageNamed:@"msg_user_info"] forState:UIControlStateNormal];
    
    //add by jianglincen iOS7下iphone4图片不显示正确颜色，故而用以下方法暂时解决

    if ([[[UIDevice currentDevice]systemVersion]floatValue]<8&&[UIScreen mainScreen].bounds.size.height==480) {
        
        titleBtn.imageView.backgroundColor=[UIColor colorWithRed:0/255.0 green:143.0/255.0 blue:215.0/255.0 alpha:1.0];
        titleBtn.imageView.layer.cornerRadius=titleBtn.imageView.size.width/2.0;
        titleBtn.imageView.clipsToBounds=YES;
    }
    
    //top left bottom right
    [titleBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 15)];
    
    NSString *title=self.title;
    
    UIColor *titleColor=[UIColor colorWithRed:0/255.0 green:143.0/255.0 blue:215.0/255.0 alpha:1.0];
    
    [titleBtn setTitleColor:titleColor forState:UIControlStateNormal];
    
    [titleBtn setTitle:title forState:UIControlStateNormal];
    
    
    if (self.operatorName&&self.operId) {
    
        [titleBtn setTitle:[NSString stringWithFormat:@"%@(%@)",self.operatorName,self.operId] forState:UIControlStateNormal];
    }
//
//      if (self.operatorName) {
//        
//        [titleBtn setTitle:self.operatorName forState:UIControlStateNormal];
//    }
    
    [titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 0)];
    
    titleBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    //iOS7中图片会变色
    
    [self.navigationController.navigationBar addSubview:titleBtn];
    
    self.title=nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:254.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    NSString *str = @"0";
    if ([str isEqualToString:@"1"]) {
       // self.chatTableView.tableHeaderView = [self headView];
    }
    
    [self showTitleView];
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:YES];
    
    [self hideTitleView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //. 添加通知
    [self addObserver];
    [self setupRefresh];
}
- (void)setMessageCard:(NSString *)messageCard {
    [super setMessageCard:messageCard];
 
    self.sendMessageID = [NSString  stringWithFormat:@"m_e_%@@im.gy.com",globalData.loginModel.custId];
  
    NSDictionary *friendBasicDcit =  [[GYHDMessageCenter sharedInstance] selectUsersInfoWithCustID:messageCard];
  
//    self.recvMessageID = [NSString stringWithFormat:@"m_%@%@@im.gy.com",friendBasicDcit[@"Friend_UserType"],messageCard];
 
      self.recvMessageID = [NSString stringWithFormat:@"%@_%@@im.gy.com",friendBasicDcit[@"Friend_UserType"],messageCard];
    
    //修复由于修改企业消息bug造成的企业操作员之间无法通话的问题
    //如果是企业操作员对话
    if ([friendBasicDcit[@"Friend_UserType"] isEqualToString:@"e_"]) {
        self.recvMessageID = [NSString stringWithFormat:@"m_%@%@@im.gy.com",friendBasicDcit[@"Friend_UserType"],messageCard];
    }
    
    //如果从售后详情页面初次进入联系消费者，是没有Friend_UserType的
    //临时补救一下，待修改
    if ([friendBasicDcit[@"Friend_UserType"] isKindOfClass:[NSNull class]]||!friendBasicDcit[@"Friend_UserType"]) {
        
        self.recvMessageID = [NSString stringWithFormat:@"m_c_%@@im.gy.com",messageCard];
        
    }
}

#pragma mark - 键盘收起的通知
- (void) chatInputViewDiss {

    [self.chatInputView disMiss];

}

/**
 *点击咨询
 */
- (void) setConsumerDictionary:(NSDictionary *)consumerDictionary {
    _consumerDictionary = consumerDictionary;
    self.title = consumerDictionary[@"nickName"];
     NSDictionary *dict =  [[GYHDMessageCenter sharedInstance] selectFriendBaseWithCardString:self.messageCard];

    if ( dict.allKeys.count <= 0) {
        
        NSMutableDictionary *insertOperDict = [NSMutableDictionary dictionary];
        
        insertOperDict[GYHDDataBaseCenterFriendFriendID ] = consumerDictionary[@"accountNo"];
        insertOperDict[GYHDDataBaseCenterFriendCustID]    = self.messageCard;
        insertOperDict[GYHDDataBaseCenterFriendName]      = consumerDictionary[@"nickName"];
        insertOperDict[GYHDDataBaseCenterFriendUserType]  = @"c_";
        insertOperDict[ GYHDDataBaseCenterFriendMessageTop]= @"-1";
        insertOperDict[GYHDDataBaseCenterFriendIcon] = consumerDictionary[@"headPic"];
        insertOperDict[GYHDDataBaseCenterFriendBasic ] = [Utils dictionaryToString:consumerDictionary];
        insertOperDict[GYHDDataBaseCenterFriendDetailed] = [Utils dictionaryToString:consumerDictionary];
//        NSDictionary *dict =  [[GYHDMessageCenter sharedInstance] selectFriendBaseWithCardString:self.messageCard];
        [[GYHDMessageCenter sharedInstance] insertInfoWithDict:insertOperDict TableName:GYHDDataBaseCenterFriendTableName];
    }else {
        NSMutableDictionary *conditionDict = [NSMutableDictionary dictionary];
        conditionDict[GYHDDataBaseCenterFriendCustID] = self.messageCard;
        
        NSMutableDictionary *updateDict = [NSMutableDictionary dictionary];
        updateDict[GYHDDataBaseCenterFriendIcon] = consumerDictionary[@"headPic"];
        updateDict[GYHDDataBaseCenterFriendName] = consumerDictionary[@"nickName"];
        [[GYHDMessageCenter sharedInstance] updateInfoWithDict:updateDict conditionDict:conditionDict TableName:GYHDDataBaseCenterFriendTableName];
    }


}

/**下拉刷新*/
- (void)setupRefresh {

       @weakify(self);
    
    GYRefreshHeader*header = [GYRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadChat];
        [self.chatTableView.mj_header endRefreshing];
    }];
    
    self.chatTableView.mj_header=header;
    [self.chatTableView.mj_header beginRefreshing];
}
/**加载聊天记录*/
- (void)loadChat {
    //1. 查询数据库
    
    if ([self.messageCard isEqualToString:@""]||[self.messageCard isKindOfClass:[NSNull class]]) {
        
        //消息card为空
       // DDLogCError(@"消息card为空,不刷新数据库");
        return [Utils showMassage:@"消息card为空"];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *chatDict in [[GYHDMessageCenter sharedInstance] selectAllChatWithCard:self.messageCard frome:self.chatArrayM.count to:self.chatArrayM.count+selectChatCount]) {
        GYHDNewChatModel *chatMode = [[GYHDNewChatModel alloc] initWithDictionary:chatDict];
        [array addObject:chatMode];
    }
    NSMutableArray *fristArray = [NSMutableArray arrayWithArray:self.chatArrayM];
    [array addObjectsFromArray:fristArray];
    self.chatArrayM = array;
    [self.chatTableView reloadData];
    if (self.chatArrayM.count && self.chatArrayM.count <= selectChatCount) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"center"])
    {
        if (self.chatArrayM.count > 0) {
            CGRect rectInKey =  [self.chatInputView convertRect:self.chatInputView.bounds toView:[self.chatInputView superview]];
            [self.chatTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(0);
                make.height.mas_equalTo(rectInKey.origin.y);
            }];
            [self.chatTableView layoutIfNeeded];
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }

}
- (void)addObserver {
    [[GYHDMessageCenter sharedInstance] addDataBaseChangeNotificationObserver:self selector:@selector(messageCenterDataBaseChagne:)];

}
#pragma mark - chat NSNotification
- (void)messageCenterDataBaseChagne:(NSNotification *)noti {
    
    NSDictionary *dict = noti.object;
    
    
    //NSNotification
    //如果发送消息给我的人不是当前聊天对象,并且MSG_FromID存在.return
    //否则，更新消息状态 modify by jianglincen 感觉结构仍不够严谨

    //"MSG_FromID" = "m_c_0601211099420160509@im.gy.com/mobile_im";
    //
//    if (![self.recvMessageID containsString:dict[@"MSG_FromID"]]&&self.sendMessageID) {
//    
//        return;
//    }
//    else{
//    
    //使用王彪的代码
    if (dict[@"State"] && dict[@"msgID"]) {        //  更新数据
        for (GYHDNewChatModel *model in self.chatArrayM) {
            if ([model.chatMessageID isEqualToString:dict[@"msgID"]]) {
                model.chatSendState = [dict[@"State"] integerValue];
                break;
            }
        }
    }
    
//    if (dict[@"MSG_Body"] &&dict[@"MSG_ToID"]) {
//        GYHDNewChatModel *model = [[GYHDNewChatModel alloc]initWithDictionary:dict];
//        [self.chatArrayM addObject:model];
//    }
//
    // jianglincen 待修改
    if (dict[@"MSG_Body"] && dict[@"MSG_ToID"] && [[self.messageCard substringToIndex:11] isEqualToString:[dict[@"MSG_Card"] substringToIndex:11]]) {

        GYHDNewChatModel *model = [[GYHDNewChatModel alloc] initWithDictionary:dict];
        
        [self.chatArrayM addObject:model];
        
        //修改 self.title为最新昵称
        
        NSDictionary *bodyDic=[Utils stringToDictionary:dict[@"MSG_Body"]];
        
        NSString *friendName = bodyDic[@"msg_note"];//最新昵称
        
        if (friendName) {
            [titleBtn setTitle:friendName forState:UIControlStateNormal];//修改标题
            
            if ([dict[@"MSG_UserState"] isEqualToString:@"e"]&&self.operId) {
                
                    [titleBtn setTitle:[NSString stringWithFormat:@"%@(%@)",friendName,self.operId] forState:UIControlStateNormal];
                
             //    [titleBtn setTitle:[NSString stringWithFormat:@"%@",friendName] forState:UIControlStateNormal];
            }
        }
        
    }
    
    [self.chatTableView reloadData];
    if (self.chatArrayM.count) {
        CGRect rectInTableView = [self.chatTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArrayM.count - 2 inSection:0]];
        rectInTableView = [self.chatTableView convertRect:rectInTableView toView:[self.chatTableView superview]];
        CGRect rectInKey =  [self.chatInputView convertRect:self.chatInputView.bounds toView:[self.chatInputView superview]];
        if (rectInTableView.origin.y < rectInKey.origin.y) { // 判断是不是最后一行
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatArrayM.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
        
  //  }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[GYHDMessageCenter sharedInstance] removeDataBaseChangeNotificationWithObserver:self];
    [[GYHDMessageCenter sharedInstance] clearUnreadMessageWithCardId:self.messageCard];
}


- (void)dealloc {
    [self.chatInputView removeObserver:self forKeyPath:@"center"];
    [kDefaultNotificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    if (titleBtn) {
        [titleBtn removeFromSuperview];
    }
}


#pragma mark --tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatArrayM.count;
}

static NSDateFormatter *chatfmt = nil;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    GYHDNewChatModel *chatModel = self.chatArrayM[indexPath.row];
    
    GYHDNewChatModel *lastChatModel =nil;
   
    if (indexPath.row) {
      lastChatModel = self.chatArrayM[indexPath.row-1];
    }
    
    NSDictionary *bodyDict = [Utils stringToDictionary:chatModel.chatBody];
    
    switch ([bodyDict[@"msg_code"] integerValue]) {
        case GYHDDataBaseCenterMessageChatText:
            if (!chatModel.chatIsSelfSend) {
                GYHDLeftChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDLeftChatTextCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            } else {
                GYHDRightChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDRightChatTextCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                return cell;
            }
            break;
            case GYHDDataBaseCenterMessageChatPicture:
            if (!chatModel.chatIsSelfSend) {
                GYHDLeftChatImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDLeftChatImageCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            } else {
                GYHDRightChatImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDRightChatImageCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            }
            break;
            case GYHDDataBaseCenterMessageChatAudio:
            if (!chatModel.chatIsSelfSend) {
                GYHDLeftChatAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDLeftChatAudioCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
               
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            } else {
                GYHDRightChatAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDRightChatAudioCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            }
            break;
            case GYHDDataBaseCenterMessageChatVideo:
            if (!chatModel.chatIsSelfSend) {
                GYHDLeftChatVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDLeftChatVideoCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                 [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                
                return cell;
            } else {
                GYHDRightChatVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDRightChatVideoCellID" forIndexPath:indexPath];
                cell.delegate = self;
                cell.chatModel = chatModel;
                
                [cell timeWithinTwoMinute:lastChatModel CurrentModel:chatModel];
                return cell;
            }
            break;
        default:
            break;
    }

    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    GYHDNewChatModel *chatModel = self.chatArrayM[indexPath.row];
  
    NSDictionary *bodyDict = [Utils stringToDictionary:chatModel.chatBody];
    
       @weakify(self);
    
    switch ([bodyDict[@"msg_code"] integerValue]) {
        case GYHDDataBaseCenterMessageChatText:
            if (!chatModel.chatIsSelfSend) {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDLeftChatTextCellID" configuration:^(GYHDLeftChatTextCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            } else {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDRightChatTextCellID" configuration:^(GYHDRightChatTextCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            }
            break;
            case GYHDDataBaseCenterMessageChatPicture:
            
            if (!chatModel.chatIsSelfSend) {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDLeftChatImageCellID" configuration:^(GYHDLeftChatTextCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            } else {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDRightChatImageCellID" configuration:^(GYHDRightChatImageCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            }
            break;
            case GYHDDataBaseCenterMessageChatAudio:
            return 100.0f;
            
        case GYHDDataBaseCenterMessageChatVideo:
            if (!chatModel.chatIsSelfSend) {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDLeftChatVideoCellID" configuration:^(GYHDLeftChatVideoCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            } else {
                return [tableView fd_heightForCellWithIdentifier:@"GYHDRightChatVideoCellID" configuration:^(GYHDRightChatVideoCell *cell) {
                    @strongify(self);
                    cell.chatModel = self.chatArrayM[indexPath.row];
                }];
            }
            break;
        default:
            break;
    }
    return 80;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 隐藏键盘
    [self.chatInputView disMiss];
}

#pragma mark -- GYHDKeyboardInptuViewDelegate

- (void)GYHDInputView:(GYHDInputView *)inputView sendDict:(NSDictionary *)dict SendType:(GYHDInputeViewSendType) type {
    NSDictionary *userDict = [[GYHDMessageCenter sharedInstance] selectFriendBaseWithCardString:globalData.loginModel.custId];
    NSMutableDictionary *searchUserInfoDict = userDict[@"searchUserInfo"];//此字典也带有<null>
    NSDictionary *messageDict = [NSDictionary dictionary];
    switch (type) {
        case GYHDInputeViewSendText:
        {
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
            bodyDict[@"msg_note"] = searchUserInfoDict[@"operName"] ? searchUserInfoDict[@"operName"] : userDict[GYHDDataBaseCenterFriendName];
            bodyDict[@"msg_content"] = dict[@"string"];
            bodyDict[@"msg_type"] = @"2";//2为聊天消息
            bodyDict[@"msg_icon"] = searchUserInfoDict[@"headImage"] ? searchUserInfoDict[@"headImage"] : userDict[GYHDDataBaseCenterFriendBasicIcon];
            bodyDict[@"msg_code"] = @"00";//文本
            if ([self.recvMessageID containsString:@"c_"]) {
                //c 为消费者
                bodyDict[@"msg_note"]=globalData.loginModel.vshopName;
                bodyDict[@"msg_icon"]=[NSString stringWithFormat:@"%@%@",globalData.loginModel.picUrl,globalData.loginModel.vshopLogo];
            }
            NSString *bodyString = [Utils dictionaryToString:bodyDict];
            NSString *saveString = @"";
            messageDict = [self sendWithMessageType:GYHDDataBaseCenterMessageTypeChat saveDictString:saveString bodyString:bodyString];
            
            break;
        }
        case GYHDInputeViewSendAudio:
        {
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
            bodyDict[@"msg_code"] = @"13";
            bodyDict[@"msg_type"] = @"2";
            bodyDict[@"msg_icon"] = searchUserInfoDict[@"headImage"] ? searchUserInfoDict[@"headImage"] : userDict[GYHDDataBaseCenterFriendBasicIcon];
             int len = [dict[@"mp3Len"] intValue];
            bodyDict[@"msg_fileSize"] = [NSString stringWithFormat:@"%d",len];
            bodyDict[@"msg_content"] = @"";
            bodyDict[@"sub_msg_code"] = @"10101";
            bodyDict[@"msg_note"] = userDict[GYHDDataBaseCenterFriendBasicNikeName] ? userDict[GYHDDataBaseCenterFriendBasicNikeName] :searchUserInfoDict[@"operName"];
            if ([self.recvMessageID containsString:@"c_"]) {
                
                bodyDict[@"msg_note"]=globalData.loginModel.vshopName;
               bodyDict[@"msg_icon"]=[NSString stringWithFormat:@"%@%@",globalData.loginModel.picUrl,globalData.loginModel.vshopLogo];
            }
            NSString *bodyString = [Utils dictionaryToString:bodyDict];
            NSString *saveString = [Utils dictionaryToString:dict];
            messageDict = [self sendWithMessageType:GYHDDataBaseCenterMessageTypeChat saveDictString:saveString bodyString:bodyString];
            break;
        }
        case GYHDInputeViewSendPhoto:
        {
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
            bodyDict[@"msg_imageNailsUrl"] = @"";
            bodyDict[@"msg_content"] = @"";
            bodyDict[@"msg_imageNails_width"] = @"";
            bodyDict[@"msg_imageNails_height"] = @"";
            bodyDict[@"msg_type"] = @"2";
            bodyDict[@"msg_icon"] = searchUserInfoDict[@"headImage"] ? searchUserInfoDict[@"headImage"] : userDict[GYHDDataBaseCenterFriendBasicIcon];
            bodyDict[@"sub_msg_code"] = @"10101";
            bodyDict[@"msg_note"] = userDict[GYHDDataBaseCenterFriendBasicNikeName] ? userDict[GYHDDataBaseCenterFriendBasicNikeName] :searchUserInfoDict[@"operName"];
            bodyDict[@"msg_code"] = @"10";
            if ([self.recvMessageID containsString:@"c_"]) {
                
                bodyDict[@"msg_note"]=globalData.loginModel.vshopName;
                bodyDict[@"msg_icon"]=[NSString stringWithFormat:@"%@%@",globalData.loginModel.picUrl,globalData.loginModel.vshopLogo];
            }
            NSString *bodyString = [Utils dictionaryToString:bodyDict];
            NSString *saveString = [Utils dictionaryToString:dict];
             messageDict = [self sendWithMessageType:GYHDDataBaseCenterMessageTypeChat saveDictString:saveString bodyString:bodyString];
  
            break;
        }
        case GYHDInputeViewSendVideo:
        {
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
            bodyDict[@"msg_imageNailsUrl"] = @"";
            bodyDict[@"msg_content"] = @"";
            bodyDict[@"msg_imageNails_width"] = @"";
            bodyDict[@"msg_imageNails_height"] = @"";
            bodyDict[@"msg_type"] = @"2";
//            bodyDict[@"msg_icon"] = userDict[GYHDDataBaseCenterFriendBasicIcon];
            bodyDict[@"msg_icon"] = searchUserInfoDict[@"headImage"] ? searchUserInfoDict[@"headImage"] : userDict[GYHDDataBaseCenterFriendBasicIcon];
            bodyDict[@"sub_msg_code"] = @"10101";
            bodyDict[@"msg_note"] = userDict[GYHDDataBaseCenterFriendBasicNikeName] ? userDict[GYHDDataBaseCenterFriendBasicNikeName] :searchUserInfoDict[@"operName"];
            bodyDict[@"msg_code"] = @"14";
            if ([self.recvMessageID containsString:@"c_"]) {
                
                bodyDict[@"msg_note"]=globalData.loginModel.vshopName;
                bodyDict[@"msg_icon"]=[NSString stringWithFormat:@"%@%@",globalData.loginModel.picUrl,globalData.loginModel.vshopLogo];
            }
            NSString *bodyString = [Utils dictionaryToString:bodyDict];
            NSString *saveString = [Utils dictionaryToString:dict];
            messageDict = [self sendWithMessageType:GYHDDataBaseCenterMessageTypeChat saveDictString:saveString bodyString:bodyString];
            break;
        }
        default:
            break;
    }

    [[GYHDMessageCenter sharedInstance] sendMessageWithDictionary:messageDict resend:NO];
    GYHDNewChatModel *model = [[GYHDNewChatModel alloc] initWithDictionary:messageDict];
    [self.chatArrayM addObject:model];
    [self.chatTableView reloadData];
    [[GYHDMessageCenter sharedInstance] replyMessageID:model.chatCard];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.chatArrayM.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (NSDictionary *)sendWithMessageType:(GYHDDataBaseCenterMessageType)type saveDictString:(NSString *)dictString bodyString:(NSString *)bodyString {
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    messageDict[GYHDDataBaseCenterMessageFromID] = self.sendMessageID;
    messageDict[GYHDDataBaseCenterMessageToID] = self.recvMessageID;
    long long t = ([[NSDate date] timeIntervalSince1970] + [globalData getTimeDifference:NO]) * 1000;
    messageDict[GYHDDataBaseCenterMessageID] = [NSString stringWithFormat:@"%lld",t];
    messageDict[GYHDDataBaseCenterMessageCode] = @(type);
    messageDict[GYHDDataBaseCenterMessageCard] = self.messageCard;
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    
    messageDict[GYHDDataBaseCenterMessageSendTime]  = dateString;
    messageDict[GYHDDataBaseCenterMessageRevieTime] = dateString;
    messageDict[GYHDDataBaseCenterMessageIsSelf]    = @(1);
    messageDict[GYHDDataBaseCenterMessageIsRead]    = @(0);
    messageDict[GYHDDataBaseCenterMessageSentState] = @(GYHDDataBaseCenterMessageSentStateSending);
    messageDict[GYHDDataBaseCenterMessageData] =  dictString;
    messageDict[GYHDDataBaseCenterMessageBody] = bodyString;
    NSDictionary *bodyDict = [Utils stringToDictionary:bodyString];
    messageDict[GYHDDataBaseCenterMessageContent] = bodyDict[@"msg_content"];
    if ([self.recvMessageID containsString:@"c"]) {
        messageDict[GYHDDataBaseCenterMessageUserState] = @"c";
    }
    if ([self.recvMessageID containsString:@"e"]) {
       messageDict[GYHDDataBaseCenterMessageUserState] = @"e";
    }
    return messageDict;
}

#pragma mark - GYHDChatDelegate
- (void)GYHDChatView:(UIView *)view longTapType:(GYHDChatTapType)type selectOption:(GYHDChatSelectOption)option chatMessageID:(NSString *)chatMessageID {
    
    switch (option) {
        case GYHDChatSelectDelete:{
          
            for (int i = 0 ; i< self.chatArrayM.count; i++) {
                GYHDNewChatModel *model = self.chatArrayM[i];
                if ([model.chatMessageID isEqualToString:chatMessageID]) {
                    [[GYHDMessageCenter sharedInstance] deleteMessageWithMessage:chatMessageID fieldName:GYHDDataBaseCenterMessageID];
                    [self.chatArrayM removeObjectAtIndex:i];
                    [self.chatTableView reloadData];
                }
            }
            break;
        }
        default:
            break;
    }
}
- (void)GYHDChatView:(UIView *)view tapType:(GYHDChatTapType)type chatModel:(GYHDNewChatModel *)chatModel {

    NSDictionary *DataDict = [Utils stringToDictionary:chatModel.chatDataString];
    NSDictionary *bodyDict = [Utils stringToDictionary:chatModel.chatBody];
    
       @weakify(self);
    
    switch (type) {
        case GYHDChatTapUserIcon: {
            if (chatModel.chatIsSelfSend) {
            GYHDCompanyInfoViewController *companyInfoVC = [[GYHDCompanyInfoViewController alloc]init];
            companyInfoVC.messageCard = globalData.loginModel.custId;
            companyInfoVC.markJump = @"1";
            [self.navigationController pushViewController:companyInfoVC animated:YES];
            }else if (!chatModel.chatIsSelfSend) {
                
                NSString *string = chatModel.chatFromID;
                string = [string substringToIndex:4];
                
                if ([string containsString:@"_e"]) {
                    GYHDCompanyInfoViewController *companyInfoVC = [[GYHDCompanyInfoViewController alloc]init];
                    companyInfoVC.messageCard = chatModel.chatCard;
                    companyInfoVC.markJump = @"1";
                    [self.navigationController pushViewController:companyInfoVC animated:YES];
                }else {
                    GYHDConsumerInfoViewController *consuerInfoVC = [[GYHDConsumerInfoViewController alloc]init];
                    consuerInfoVC.isParentChat=YES;
                    consuerInfoVC.messageCard = chatModel.chatCard;
                    [self.navigationController pushViewController:consuerInfoVC animated:YES];
                }
            }
            break;
        }
        case GYHDChatTapResendButton: {
            [self sendMessageWithModel:chatModel];
            break;
        }
        case GYHDChatTapChatImage: {
            NSURL *url = nil;
            if (DataDict[@"originalName"]) {
                NSString *imagePath = [NSString pathWithComponents:@[[[GYHDMessageCenter sharedInstance] imagefolderNameString],DataDict[@"originalName"]]];
                url = [NSURL fileURLWithPath:imagePath];
            }else {

                url = [NSURL URLWithString:bodyDict[@"msg_content"]];
            }
//            GYHDChatImageShowView *showImageView = [[GYHDChatImageShowView alloc] initWithFrame:self.navigationController.view.bounds];
//            showImageView.url = url;
//            showImageView.delegate = self;
//            [showImageView setImageWithUrl:url];
//           // [showImageView show]; 原来方法在长按时出现的MenuController，会与点击手势添加的window冲突，故而换成以下方法
//           
//            [showImageView showInView:self.navigationController.view];
            GYPhotoGroupItem *item = [[GYPhotoGroupItem alloc]init];
            item.largeImageURL = url;
            item.thumbView = view;
            
            GYPhotoGroupView *v = [[GYPhotoGroupView alloc]initWithGroupItems:@[item]];
            [v presentFromImageView:view toContainer:self.navigationController.view animated:YES completion:nil];
            
            
            
            break;
        }
        case GYHDChatTapChatVideo: {
           // DDLogInfo(@"视频被点击");
            if (!DataDict[@"mp4Name"]) return;
            NSURL *url = nil;
            NSString *mp4Path = [NSString pathWithComponents:@[[[GYHDMessageCenter sharedInstance] mp4folderNameString],DataDict[@"mp4Name"]]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:mp4Path]) {
             
                url = [NSURL fileURLWithPath:mp4Path];
                GYHDChatVideoShowView *showVideoView = [[GYHDChatVideoShowView alloc] init];
                [showVideoView setVideoWithUrl:url];
                [showVideoView show];
            } else {
               [[GYHDMessageCenter sharedInstance] downloadDataWithUrlString:bodyDict[@"msg_content"] RequetResult:^(NSDictionary *resultDict) {
                  
                   NSData *mp4Data = resultDict[@"data"];
                   [mp4Data writeToFile:mp4Path atomically:NO];
                   NSURL *mp4Url = [NSURL fileURLWithPath:mp4Path];
                
                   GYHDChatVideoShowView *showVideoView = [[GYHDChatVideoShowView alloc] init];
                   [showVideoView setVideoWithUrl:mp4Url];
                   [showVideoView show];
               }];
            }
            NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
            saveDict[@"mp4Name"] = DataDict[@"mp4Name"];
            saveDict[@"thumbnailsName"] = DataDict[@"thumbnailsName"];
            saveDict[@"read"] = @"1";
            NSString *saveString = [Utils dictionaryToString:saveDict];
            [[GYHDMessageCenter sharedInstance] updateMessageWithMessageID:chatModel.chatMessageID fieldName:GYHDDataBaseCenterMessageData updateString:saveString];
            chatModel.chatDataString = saveString;
            break;
        }
        case GYHDChatTapChatAudio: {
            NSString *mp3Path = [NSString pathWithComponents:@[[[GYHDMessageCenter sharedInstance] mp3folderNameString],DataDict[@"mp3"]]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
                if ([NSStringFromClass(view.class) isEqualToString:NSStringFromClass([GYHDLeftChatAudioCell class])]) {
       
                 __weak   GYHDLeftChatAudioCell *cell = (GYHDLeftChatAudioCell *)view;
                    if ([cell isEqual:self.leftAudioCell]) {
                        if ([cell isAudioAnimation]) {
                            [cell stopAudioAnimation];
                            [[GYHDAudioTool sharedInstance] stopPlaying];
                        }else {
                            [cell startAudioAnimation];
                            [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                [cell stopAudioAnimation];
                            }];
                        }
                    } else {
                        [cell startAudioAnimation];
                        [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                            [cell stopAudioAnimation];
                        }];
                        [self.leftAudioCell stopAudioAnimation];
                        self.leftAudioCell = cell;
                    }
                    self.leftAudioCell = cell;
                    [self.rightAudioCell stopAudioAnimation];
                } else {
                 __weak   GYHDRightChatAudioCell *cell = (GYHDRightChatAudioCell *)view;
                    if ([cell isEqual:self.rightAudioCell]) {
                        if ([cell isAudioAnimation]) {
                            [cell stopAudioAnimation];
                            [[GYHDAudioTool sharedInstance] stopPlaying ];
                        } else {
                            [cell startAudioAnimation];
                            [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                [cell stopAudioAnimation];
                            }];
                        }
                    }else {
                        [cell startAudioAnimation];
                        [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                            [cell stopAudioAnimation];
                        }];
                        [self.rightAudioCell stopAudioAnimation];
                        self.rightAudioCell = cell;
                    }
                    self.rightAudioCell = cell;
                    [self.leftAudioCell stopAudioAnimation];
                }
            } else {
                [[GYHDMessageCenter sharedInstance] downloadDataWithUrlString:bodyDict[@"msg_content"] RequetResult:^(NSDictionary *resultDict) {
                    @strongify(self);
                    NSData *mp3Data = resultDict[@"data"];
                    [mp3Data writeToFile:mp3Path atomically:NO];
                    if ([NSStringFromClass(view.class) isEqualToString:NSStringFromClass([GYHDLeftChatAudioCell class])]) {
                    __weak    GYHDLeftChatAudioCell *cell = (GYHDLeftChatAudioCell *)view;
                        if ([cell isEqual:self.leftAudioCell]) {
                            if ([cell isAudioAnimation]) {
                                [cell stopAudioAnimation];
                                [[GYHDAudioTool sharedInstance] stopPlaying];
                            }else {
                                [cell startAudioAnimation];
                                [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                    [cell stopAudioAnimation];
                                }];
                            }
                        } else {
                            [cell startAudioAnimation];
                            [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                [cell stopAudioAnimation];
                            }];
                            [self.leftAudioCell stopAudioAnimation];
                            self.leftAudioCell = cell;
                        }
                        self.leftAudioCell = cell;
                        [self.rightAudioCell stopAudioAnimation];
                        
                    } else {
                        GYHDRightChatAudioCell *cell = (GYHDRightChatAudioCell *)view;
                        
                        if ([cell isEqual:self.rightAudioCell]) {
                            
                            if ([cell isAudioAnimation]) {
                                
                                [cell stopAudioAnimation];
                                [[GYHDAudioTool sharedInstance] stopPlaying ];
                            } else {
                                
                                [cell startAudioAnimation];
                                
                                [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                    [cell stopAudioAnimation];
                                }];
                            }
                        }else {
                            
                            [cell startAudioAnimation];
                            
                            [[GYHDAudioTool sharedInstance] playMp3WithFilePath:mp3Path complete:^(GYHDAudioToolPlayerState state) {
                                [cell stopAudioAnimation];
                            }];
                            [self.rightAudioCell stopAudioAnimation];
                            self.rightAudioCell = cell;
                        }
                        self.rightAudioCell = cell;
                        [self.leftAudioCell stopAudioAnimation];
                    }
                }];
                
            }
            
            NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
            saveDict[@"mp3"] = DataDict[@"mp3"];
            saveDict[@"mp3Len"]= DataDict[@"mp3Len"];
            saveDict[@"read"]= @"1";
            NSString *saveString = [Utils dictionaryToString:saveDict];
            [[GYHDMessageCenter sharedInstance] updateMessageWithMessageID:chatModel.chatMessageID fieldName:GYHDDataBaseCenterMessageData updateString:saveString];
            chatModel.chatDataString = saveString;
            break;
        }

        default:
            break;
    }
}

- (void)sendMessageWithModel:(GYHDNewChatModel *)chatModel {
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    messageDict[GYHDDataBaseCenterMessageFromID] = chatModel.chatFromID;
    messageDict[GYHDDataBaseCenterMessageToID] = chatModel.chatToID;
    messageDict[GYHDDataBaseCenterMessageID] = chatModel.chatMessageID;
    messageDict[GYHDDataBaseCenterMessageCode] = chatModel.chatType;
    messageDict[GYHDDataBaseCenterMessageCard] = chatModel.chatCard;
    messageDict[GYHDDataBaseCenterMessageSendTime]  = chatModel.chatRecvTime;
    messageDict[GYHDDataBaseCenterMessageRevieTime] = chatModel.chatRecvTime;
    messageDict[GYHDDataBaseCenterMessageIsSelf]    = @(1);
    messageDict[GYHDDataBaseCenterMessageIsRead]    = @(0);
    messageDict[GYHDDataBaseCenterMessageSentState] = @(GYHDDataBaseCenterMessageSentStateSending);
    chatModel.chatSendState = GYHDDataBaseCenterMessageSentStateSending;
    messageDict[GYHDDataBaseCenterMessageData] =  chatModel.chatDataString;
    messageDict[GYHDDataBaseCenterMessageBody] = chatModel.chatBody;
    messageDict[GYHDDataBaseCenterMessageUserState] = @"e";
    [[GYHDMessageCenter sharedInstance] sendMessageWithDictionary:messageDict resend:YES];
    [[GYHDMessageCenter sharedInstance] updateMessageStateWithMessageID:chatModel.chatMessageID State:GYHDDataBaseCenterMessageSentStateSending];
    [self.chatTableView reloadData];
}

- (void)click:(UIButton *)btn {
    if (btn.tag == 100) {
        GYHDCompanyViewController *companyVC = [[GYHDCompanyViewController alloc] init];
        NSString *markJump = @"1";
        companyVC.markJump = markJump;
        companyVC.title = @"对话转移到";
        [self.navigationController pushViewController:companyVC animated:YES];
    }
}

- (void)goBackAction {
    
    //刷新消费者咨询信息
    if (self.reloadConsumerBlock) {
        self.reloadConsumerBlock();
    }
    
    if (titleBtn) {
        [titleBtn removeFromSuperview];
    }
    
    [[GYHDMessageCenter sharedInstance] msgUnreadCountWithCustId:self.messageCard];
    self.chatTableView.delegate=nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideTitleView{

    if (titleBtn&&titleBtn.hidden==NO) {
        [titleBtn setHidden:YES];
    }
}
-(void)showTitleView{

    if (titleBtn&&titleBtn.hidden==YES) {
        [titleBtn setHidden:NO];
    }
}


@end
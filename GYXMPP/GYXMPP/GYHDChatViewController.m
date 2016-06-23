//
//  GYHDChatViewController.m
//  GYXMPP
//
//  Created by User on 16/6/17.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "GYHDChatViewController.h"
#import "GYMessage.h"
#import "GYXMPP.h"
#import "GYHDLeftChatTextCell.h"
#import "GYHDRightChatTextCell.h"
#import "GYHDLeftChatImageCell.h"
#import "GYHDRightChatImageCell.h"
#import "GYHDLeftChatVideoCell.h"
#import "GYHDRightChatVideoCell.h"
#import "GYHDLeftChatAudioCell.h"
#import "GYHDRightChatAudioCell.h"

#import "GYHDInputView.h"
#import "UITableView+FDTemplateLayoutCell.h"
@interface GYHDChatViewController ()<UITableViewDataSource,UITableViewDelegate,GYHDInputViewDelegate>{

  BOOL  _isScrollToBottom;//是否滚动到底部

}

@property(nonatomic, strong)UITableView *chatTableView;
/**
 * 记录聊天内容的数组
 */
@property(nonatomic, strong)NSMutableArray *chatArrayM;

@property(nonatomic, strong)GYHDInputView *chatInputView;
/**
 * 接收者ID
 */

@property (copy, nonatomic, readonly) NSString *chatter;

@property (strong, nonatomic) UIRefreshControl *control;

@end

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
  
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self configUI];
    
    [self setupRefresh];
    
    self.title = self.friendUserId;
    
    [self loadChat];
}

-(void)configUI{


    _chatTableView = [[UITableView alloc] init];
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.delegate = self;
    _chatTableView.dataSource = self;
    _chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _chatTableView.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
//    _chatTableView.backgroundColor=[UIColor redColor];
    
     [self.view addSubview:_chatTableView];
    
     WSHD(weakSelf);
    
    [_chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(64);
        make.height.mas_equalTo(kScreenHeight - 105+15);
    }];
    
    
     [_chatTableView registerClass:[GYHDLeftChatTextCell class] forCellReuseIdentifier:@"GYHDLeftChatTextCellID"];
     [_chatTableView registerClass:[GYHDRightChatTextCell class] forCellReuseIdentifier:@"GYHDRightChatTextCellID"];
     [_chatTableView registerClass:[GYHDLeftChatImageCell class] forCellReuseIdentifier:@"GYHDLeftChatImageCellID"];
     [_chatTableView registerClass:[GYHDRightChatImageCell class] forCellReuseIdentifier:@"GYHDRightChatImageCellID"];
     [_chatTableView registerClass:[GYHDLeftChatVideoCell class] forCellReuseIdentifier:@"GYHDLeftChatVideoCellID"];
     [_chatTableView registerClass:[GYHDRightChatVideoCell class] forCellReuseIdentifier:@"GYHDRightChatVideoCellID"];
     [_chatTableView registerClass:[GYHDLeftChatAudioCell class] forCellReuseIdentifier:@"GYHDLeftChatAudioCellID"];
     [_chatTableView registerClass:[GYHDRightChatAudioCell class] forCellReuseIdentifier:@"GYHDRightChatAudioCellID"];
     

    _chatInputView= [[GYHDInputView alloc] init];
    _chatInputView.delegate = self;
    
    [_chatInputView showToSuperView:self.view];
    
    [self.chatInputView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)setupRefresh{

    _control=[[UIRefreshControl alloc]init];
    
    [_control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.chatTableView addSubview:_control];
    
  //  [_control beginRefreshing];
    
    //[control beginRefreshing];
    // 3.加载数据
   // [self refreshStateChange:control];
}

-(void)refreshStateChange:(UIRefreshControl *)control{
    [_control beginRefreshing];
    sleep(1);
    [_control endRefreshing];
}

/**加载聊天记录*/
- (void)loadChat {

    NSArray *dataArray =[GYMessage findMessageListWithFriendId:self.friendUserId Page:0];
    
    if (dataArray&&dataArray.count>0) {
        
        [self.chatArrayM addObjectsFromArray:dataArray];
        
        [self.chatTableView reloadData];
        
            }
}

#pragma mark - InputView KVO
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

#pragma mark - GYHDInputViewDelegate
- (void)GYHDInputView:(GYHDInputView *)inputView
             sendDict:(NSDictionary *)dict
             SendType:(GYHDInputeViewSendType)type{


}

#pragma mark - SendMessageMethod
-(void)sendTextMessage:(NSString *)textMessage{
    
      
     [[GYXMPP sharedInstance]sendTextMessageWithString:textMessage ToUser:self.friendUserId];
}

-(void)sendImageMessage:(UIImage *)image{

}

-(void)sendAudioMessage:(GYHDVoiceModel *)voice{

}

-(void)sendVideoMessage:(GYHDVideoModel *)video{


}

-(void)addMessage:(GYMessage *)message{

}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatArrayM.count;
}

    static NSDateFormatter *chatfmt = nil;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.chatArrayM.count>0) {
        
        GYMessage *chatMessage = self.chatArrayM[indexPath.row];
        //当前消息的上一条
        GYMessage *lastMessage = nil;
        
        if (indexPath.row>=1) {
            lastMessage = self.chatArrayM[indexPath.row-1];
        }
        
        switch (chatMessage.msgBodyType){
        
            case MessageBodyType_Text:{
                
                if (!chatMessage.msgIsSelf) {
                    GYHDLeftChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDLeftChatTextCellID" forIndexPath:indexPath];
                //    cell.delegate = self;
                    [cell loadChatMessage:chatMessage];
                    
                   // [cell timeWithinTwoMinute:lastMessage CurrentModel:chatMessage];
                    
                    return cell;
                } else {
                    GYHDRightChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GYHDRightChatTextCellID" forIndexPath:indexPath];
                 //   cell.delegate = self;
                    [cell loadChatMessage:chatMessage];

                    
                  //   [cell timeWithinTwoMinute:lastMessage CurrentModel:chatMessage];
                    
                    return cell;
                }

            
            }break;
            default:
                break;
        
        }
        
    }
    
    else{
    
        return nil;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    WSHD(weakSelf);
    
    GYMessage *chatModel = weakSelf.chatArrayM[indexPath.row];
    
    switch (chatModel.msgBodyType) {
        case MessageBodyType_Text:{
            
            //不是是自己发的
                if (!chatModel.msgIsSelf)
                  {
                   return [tableView fd_heightForCellWithIdentifier:@"GYHDLeftChatTextCellID" configuration:^(GYHDLeftChatTextCell *cell) {
                   
                    cell.chatMessage = chatModel;
                    }];
                  }
                else{
                    
                    CGFloat height = [tableView fd_heightForCellWithIdentifier:@"GYHDRightChatTextCellID" configuration:^(GYHDRightChatTextCell *cell) {
                        
                        cell.chatMessage = chatModel;
                    }];
                    
                    NSLog(@"height = %f",height);
                    
                    return height;

                    }
            
        }break;
        case MessageBodyType_Image:{
        
            return 100;
        }break;
        case MessageBodyType_Voice:{
            return 100;

        }break;
        case MessageBodyType_Video:{
            return 100;

        }break;
        default:
            return 0;
            break;
    }
                           
                   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 隐藏键盘
   // [self.chatInputView disMiss];
}


#pragma mark - dealloc
-(void)dealloc{

     [self.chatInputView removeObserver:self forKeyPath:@"center"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

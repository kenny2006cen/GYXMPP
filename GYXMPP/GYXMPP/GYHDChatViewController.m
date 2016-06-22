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

@interface GYHDChatViewController ()<UITableViewDataSource,UITableViewDelegate>{

    
}

@property(nonatomic, strong)UITableView *chatTableView;
/**
 * 记录聊天内容的数组
 */
@property(nonatomic, strong)NSMutableArray *chatArrayM;

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

    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 隐藏键盘
   // [self.chatInputView disMiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

//
//  ViewController.m
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "MessageListViewController.h"
#import "GYXMPP.h"
#import "MessageListCell.h"
#import "GYMessage.h"
#import "GYHDChatViewController.h"

@interface MessageListViewController ()<UITableViewDataSource,UITableViewDelegate,GYXMPPDelegate>{

}

@property (nonatomic, strong) UITableView *tableView;
/**
 *数据源数组
 */
@property(nonatomic, strong) NSMutableArray *messageArray;


@end

@implementation MessageListViewController

- (NSMutableArray *)messageArray
{
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setUpNav];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 568 - 108)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 68.0f;
    
    [self.view addSubview:_tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [self.tableView registerClass:[MessageListCell class] forCellReuseIdentifier:@"GYHDBusinessCell"];
    
    [[GYXMPP sharedInstance]xmppUserLoginWithUserName:nil PassWord:nil :^(XMPPResultType type) {
        
        if (type==XMPPResultTypeLoginSuccess) {
            
            DDLogInfo(@"登陆成功");
            
            
        }
        else{
            
            
        }
    }];
    
    [self getData];
    
    [GYXMPP sharedInstance].delegate = self;
    
}

-(void)setUpNav{
   
    self.title = @"消息";
    

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button2 setFrame:CGRectMake(100, 100, 100, 100)];
    
    [button2 setTitle:@"发送消息" forState:UIControlStateNormal];
    
    [button2 addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button2];

}


-(void)getData{
    
    if (self.messageArray.count>0) {
        [self.messageArray removeAllObjects];
    }
    
    NSArray *mesArray = [GYMessage findLastGroup];
    
    
    for ( GYMessage *message  in mesArray) {
        
        if (message) {
            [self.messageArray addObject:message];
        }
    }
    
    [self.tableView reloadData];
}

-(void)sendAction{

    GYMessage *message =[[GYMessage alloc]init];
    
    message.msgUserJid =[GYXMPP sharedInstance].userName;
//    message.msgFriendJId =@"m_e_0603211000000270000@im.gy.com";
     message.msgFriendJid =@"111@im.gy.com";
    message.msgType =@1;
    
    NSDictionary *dic =@{@"msg_content":@"测试",
                         @"msg_type":@"2",
                         @"msg_icon":@"",
                         @"msg_note":@"系统操作员",
                         @"msg_code":@"00"};
    
    
    message.msgBody =[self dictionaryToString:dic];
    
    [[GYXMPP sharedInstance]sendMessage:message];
    
}

- (NSString *)dictionaryToString:(NSDictionary *)dic
{
    if (!dic) return nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (error)
    {
        return nil;
    }
    return string;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageListCell *cell = [MessageListCell cellWithTableView:tableView];
    cell.businessModel = self.messageArray[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    if (self.messageArray.count>0) {
        
        GYMessage *message = self.messageArray[indexPath.row];

        GYHDChatViewController *chatCtrol =[[GYHDChatViewController alloc]init];
        
        [self.navigationController pushViewController:chatCtrol animated:YES];
    }
    
}

#pragma mark - GYXMPP Delegate

-(void)xmppSendingMessage:(GYMessage *)message{

   // [self.messageArray addObject:message];
    
    [self getData];
    
    [self.tableView reloadData];
}

@end

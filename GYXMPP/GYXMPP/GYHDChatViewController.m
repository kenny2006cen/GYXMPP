//
//  GYHDChatViewController.m
//  GYXMPP
//
//  Created by User on 16/6/17.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "GYHDChatViewController.h"
//#import <Masonry/Masonry.h>

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
@property(nonatomic, copy)NSString  *recvMessageID;
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
  
    _chatTableView = [[UITableView alloc] init];
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _chatTableView.delegate = self;
    _chatTableView.dataSource = self;
    _chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _chatTableView.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    /*
    [chatTableView registerClass:[GYHDLeftChatTextCell class] forCellReuseIdentifier:@"GYHDLeftChatTextCellID"];
    [chatTableView registerClass:[GYHDRightChatTextCell class] forCellReuseIdentifier:@"GYHDRightChatTextCellID"];
    [chatTableView registerClass:[GYHDLeftChatImageCell class] forCellReuseIdentifier:@"GYHDLeftChatImageCellID"];
    [chatTableView registerClass:[GYHDRightChatImageCell class] forCellReuseIdentifier:@"GYHDRightChatImageCellID"];
    [chatTableView registerClass:[GYHDLeftChatVideoCell class] forCellReuseIdentifier:@"GYHDLeftChatVideoCellID"];
    [chatTableView registerClass:[GYHDRightChatVideoCell class] forCellReuseIdentifier:@"GYHDRightChatVideoCellID"];
    [chatTableView registerClass:[GYHDLeftChatAudioCell class] forCellReuseIdentifier:@"GYHDLeftChatAudioCellID"];
    [chatTableView registerClass:[GYHDRightChatAudioCell class] forCellReuseIdentifier:@"GYHDRightChatAudioCellID"];
     */
    [self.view addSubview:_chatTableView];

    WSHD(weakSelf);
    [_chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(kScreenHeight - 105 -64+15);
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

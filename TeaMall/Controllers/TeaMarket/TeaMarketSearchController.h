//
//  TeaMarketSearchController.h
//  茶叶市场的主界面
//
//  Created by Carl_Huang on 14-8-26.
//  Copyright (c) 2014年 HelloWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeaMarketSearchController : UIViewController 

@property(nonatomic,assign) BOOL isShowSell;
//@property(nonatomic,strong) UITableView *tableView;
//搜索栏
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

//tableView
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
//搜索栏确定按钮
- (IBAction)sure:(id)sender;


@end

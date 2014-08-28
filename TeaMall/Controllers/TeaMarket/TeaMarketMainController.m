//
//  TeaMarketMainController.m
//  茶叶市场的主界面
//
//  Created by Carl_Huang on 14-8-26.
//  Copyright (c) 2014年 HelloWorld. All rights reserved.
//  茶叶超市主界面demo

#import "TeaMarketMainController.h"
#import "ContentCell.h"
#import "TeaMarketSearchController.h"

@interface TeaMarketMainController ()

@end

@implementation TeaMarketMainController



- (void)viewDidLoad
{
    [super viewDidLoad];
    //导航栏标题
    self.title = @"茶叶超市";
    //添加右边的按钮Item
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStyleBordered target:self action:@selector(searchItemClick)];
    self.navigationItem.rightBarButtonItem = searchItem;
}


- (NSString *)tabImageName
{
	return @"茶叶超市-图标（黑）";
}

- (NSString *)tabTitle
{
	return nil;
}


#pragma mark 搜索按钮监听放法，显示搜索控制器
 - (void)searchItemClick
{
    NSLog(@"来搜索");
    TeaMarketSearchController *search = [[TeaMarketSearchController alloc] init];
//    [self presentViewController:search animated:YES completion:nil];
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark - Table view 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //取消cell的选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//    cell.indexPath = indexPath;
    return cell;
}



#pragma mark -返回每组头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"------头部";
    headerLabel.backgroundColor = [UIColor purpleColor];
    return headerLabel;
}



#pragma mark -返回每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.bounds.size.width;
}



@end
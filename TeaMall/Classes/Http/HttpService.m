//
//  HttpService.m
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "HttpService.h"
#import "AllModels.h"
#import <objc/runtime.h>
#define HW @"hw_"       //关键字属性前缀
@implementation HttpService

#pragma mark Life Cycle
- (id)init
{
    if ((self = [super init])) {
        
    }
    return  self;
}

#pragma mark Class Method
+ (HttpService *)sharedInstance
{
    static HttpService * this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

#pragma mark Private Methods
- (NSString *)mergeURL:(NSString *)methodName
{
    NSString * str =[NSString stringWithFormat:@"%@%@",URL_PREFIX,methodName];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

/**
 @desc 返回类的属性列表
 @param 类对应的class
 @return NSArray 属性列表
 */
+ (NSArray *)propertiesName:(Class)cls
{
    if(cls == nil) return nil;
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if(propertyName && [propertyName length] != 0)
        {
            [list addObject:propertyName];
        }
    }
    return list;
}



//将取得的内容转换为模型
- (NSArray *)mapModelsProcess:(id)responseObject withClass:(Class)class
{
    //判断返回值
    if(!responseObject || [responseObject isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
//    NSArray * properties = [[self class] propertiesName:class];
    NSMutableArray * models = [NSMutableArray array];
    for (NSDictionary * info in responseObject) {
        if (info) {
            id model = [self mapModel:info withClass:class];
            if(model)
            {
                [models addObject:model];
            }
        }
        
    }
    
    return (NSArray *)models;
}

- (id)mapModel:(id)reponseObject withClass:(Class)cls
{
    if (!reponseObject || [reponseObject isKindOfClass:[NSNull class]]) {
        return nil;
    }
    id model  = [[cls alloc] init];
    NSArray * properties = [[self class] propertiesName:cls];
    for(NSString * property in properties)
    {
        NSString * tmp = [property stringByReplacingOccurrencesOfString:HW withString:@""];
        id value = [reponseObject valueForKey:tmp];
        if(![value isKindOfClass:[NSNull class]])
        {
            if(![value isKindOfClass:[NSString class]])
            {
                [model setValue:[value stringValue] forKey:property];
            }
            else
            {
                [model setValue:value forKey:property];
            }
        }
    }
    return model;
}

#pragma mark Instance Method
/**
 @desc 用户登录
 */
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{

    [self post:[self mergeURL:User_Login] withParams:params completionBlock:^(id obj) {
        NSString * result = [obj valueForKey:@"status"];
        if([result intValue] == 1)
        {
            NSArray * result = [obj valueForKey:@"result"];
            NSLog(@"%@",result);
            NSDictionary * info = nil;
            if ([result count] > 0) {
                info = [result objectAtIndex:0];
            }
            User * user = [self mapModel:info withClass:[User class]];
            if(success)
            {
                success(user);
            }
        }
        else if ([result intValue] == 0)
        {
            //密码错误
            //用户名不存在
            if(failure)
            {
                failure(nil,result);
            }
            
        }
    } failureBlock:failure];
}

/**
 @desc 用户注册
 */
- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(BOOL isSuccess))success failureBlock:(void (^)(NSError * error,NSString * reponseString))failure
{
    [self post:[self mergeURL:User_Register] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success)
            {
                success(YES);
            }
        }
        else
        {
            if(success)
            {
                success(NO);
            }

        }
    } failureBlock:failure];
}

/**
 @desc 获取市场资讯(顶部滚动)
 */
- (void)getMarketNewsTopWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self getMarketNews:@{@"is_top":@"1"} completionBlock:success failureBlock:failure];
}

/**
 @desc 获取市场资讯(非顶部滚动)
 */
- (void)getMarketNewsWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self getMarketNews:@{@"is_top":@"0"} completionBlock:success failureBlock:failure];
}


/**
 @desc 获取市场资讯
 */
- (void)getMarketNews:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Market_News] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * newsArray = [self mapModelsProcess:result withClass:[MarketNews class]];
            if(success)
            {
                success(newsArray);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有市场资讯!");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 市场行情:获取升价商品
 */
- (void)getAddPriceCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    NSMutableDictionary * info = [NSMutableDictionary dictionaryWithDictionary:params];
    [info setValue:@"1" forKey:@"type"];
    [self getMarketCommodity:info completionBlock:success failureBlock:failure];
}

/**
 @desc 市场行情:获取降价商品
 */
- (void)getReducePriceCommodity:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    NSMutableDictionary * info = [NSMutableDictionary dictionaryWithDictionary:params];
    [info setValue:@"0" forKey:@"type"];
    [self getMarketCommodity:info completionBlock:success failureBlock:failure];
}

/**
 @desc 市场行情
 */
- (void)getMarketCommodity:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Market] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * commodities = [self mapModelsProcess:result withClass:[Commodity class]];
            if(success)
            {
                success(commodities);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有商品!");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 搜索商品
 */
- (void)searchCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Search_Commodity] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * commodities = [self mapModelsProcess:result withClass:[Commodity class]];
            if(success)
            {
                success(commodities);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有商品!");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 获取客服列表
 */
- (void)getCustomerService:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Customer_Service] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * customerServices = [self mapModelsProcess:result withClass:[CustomerService class]];
            if(success)
            {
                success(customerServices);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有客服人员!");
            }
        }
    } failureBlock:failure];
    
}

/**
 @desc 获取用户发布列表
 */
- (void)getPublishList:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Publish] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * publishs = [self mapModelsProcess:result withClass:[Publish class]];
            if(success)
            {
                success(publishs);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有发布!");
            }
        }

    } failureBlock:failure];
}

/**
 @desc 获取个人发布列表
 */
- (void)getUserPublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_User_Publish] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * publishs = [self mapModelsProcess:result withClass:[Publish class]];
            if(success)
            {
                success(publishs);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有发布!");
            }
        }
        
    } failureBlock:failure];
}


/**
 @desc 获取商品
 */
- (void)getCommodity:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Commodity] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * commodities = [self mapModelsProcess:result withClass:[Commodity class]];
            if(success)
            {
                success(commodities);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有商品!");
            }
        }
    } failureBlock:failure];
}


/**
 @desc 获取商品分类
 */
- (void)getCategory:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Category] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * teaCategorys = [self mapModelsProcess:result withClass:[TeaCategory class]];
            if(success)
            {
                success(teaCategorys);
            }
            
        }
        else
        {
            if (failure) {
                failure(nil,@"获取分类失败");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加收藏
 */
//TODO:添加收藏
- (void)addCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Collection] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 删除收藏
 */
//TODO:删除收藏
- (void)deleteCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Delete_Collection] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 删除发布
 */
//TODO:删除发布
- (void)deletePublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Delete_Publish] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
    
}

/**
 @desc 添加发布
 */
//TODO:添加发布
- (void)addPublish:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Publish] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 拍下用户发布
 */
//TODO:拍下用户发布
- (void)bidUserPublish:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Shopping_List] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 获取用户拍下的发布列表
 */
//TODO:获取用户拍下的发布列表
- (void)getBidList:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Shopping_List] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * bids = [self mapModelsProcess:result withClass:[Bid class]];
            if(success) success(bids);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 添加反馈意见
 */
//TODO:添加反馈意见
- (void)addFeedback:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Feedback] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
    
}

/**
 @desc 我的收货地址
 */
//TODO:我的收货地址
- (void)getAddressList:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Address_List] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * addressList = [self mapModelsProcess:result withClass:[Address class]];
            if(success)
            {
                success(addressList);
            }
            
        }
        else
        {
            if (failure) {
                failure(nil,@"获取我的收货地址失败");
            }
        }
    } failureBlock:failure];
}


/**
 @desc 添加收货地址
 */
//TODO:添加收货地址
- (void)addAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Address] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 删除收货地址
 */
//TODO:删除收货地址
- (void)deleteAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Delete_Address] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 更新收货地址
 */
//TODO:更新收货地址
- (void)updateAddress:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Update_Address] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            if(success) success([obj objectForKey:@"result"]);
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }
    } failureBlock:failure];
}

/**
 @desc 我的收藏
 */
//TODO:我的收藏
- (void)getMyCollection:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_My_Collection] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSMutableArray * result = [NSMutableArray array];
            NSArray * goods , * publishs = [NSArray array];
            if([[obj objectForKey:@"goods"] count] > 0)
            {
                NSMutableArray * goodsInfo = [NSMutableArray array];
                for(NSArray * info in [obj objectForKey:@"goods"])
                {
                    [goodsInfo addObject:[info objectAtIndex:0]];
                }
                goods = [self mapModelsProcess:goodsInfo withClass:[Commodity class]];
            }
            
            if([[obj objectForKey:@"publish"] count] > 0)
            {
                NSMutableArray * publishInfo = [NSMutableArray array];
                for(NSArray * info in [obj objectForKey:@"publish"])
                {
                    [publishInfo addObject:[info objectAtIndex:0]];
                }
                publishs = [self mapModelsProcess:publishInfo withClass:[Publish class]];
            }
            
            if(goods != nil || [goods count] > 0)
            {
                [result addObjectsFromArray:goods];
            }
            
            if(publishs != nil && [publishs count] > 0)
            {
                [result addObjectsFromArray:publishs];
            }
            
            if(success)
            {
                success(result);
            }
        }
        else
        {
            if(failure) failure(nil,[obj objectForKey:@"result"]);
        }

    } failureBlock:failure];
}

/**
 @desc 更新用户资料
 */
//TODO:更新用户资料
- (void)updateUserInfo:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Update_Member] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            NSArray * result = [obj valueForKey:@"result"];
            NSDictionary * info = nil;
            if ([result count] > 0) {
                info = [result objectAtIndex:0];
            }
            User * user = [self mapModel:info withClass:[User class]];
            if(success)
            {
                success(user);
            }

        }
        else
        {
            if(failure)
            {
                failure(nil,@"更新失败");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加订单
 */
//TODO:添加订单
- (void)addOrder:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Order] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                success(@"提交成功.");
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"提交订单失败.");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 更新订单
 */
//TODO:更新订单
- (void)updateOrder:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Update_Order] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                success(@"更新订单成功.");
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"更新订单失败.");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加商品评论
 */
//TODO:添加商品评论
- (void)addGoodsComment:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Goods_Comment] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                success(@"添加评论成功.");
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"添加评论失败.");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 获取商品评论列表
 */
- (void)getGoodsComments:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Goods_Comment_List] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                NSArray * comments = [self mapModelsProcess:[obj objectForKey:@"result"] withClass:[GoodsComment class]];
                success(comments);
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"加载数据失败.");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加新闻评论
 */
//TODO:添加新闻评论
- (void)addNewsComment:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_News_Comment] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                success(@"添加评论成功.");
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"添加评论失败.");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 获取新闻的评论
 */
- (void)getNewsComment:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:News_Comment_List] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                NSArray * comments = [self mapModelsProcess:[obj objectForKey:@"result"] withClass:[NewsComment class]];
                success(comments);
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"加载数据失败.");
            }
        }
    } failureBlock:failure];
    
}


/**
 @desc 获取启动图片
 */
//TODO:获取启动图片
- (void)getLaunchImage:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Launch_Image] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                if(obj[@"result"] != nil && [obj[@"result"] count] != 0)
                {
                    LaunchInfo * launchInfo = [self mapModel:obj[@"result"][0] withClass:[LaunchInfo class]];
                    success(launchInfo);

                }
                
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"加载数据失败.");
            }
        }
    } failureBlock:failure];
}


/**
 @desc 获取广告
 */
//TODO:获取广告
- (void)getAdvertiment:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Advertisement] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            if (success) {
                NSArray * advertisements = [self mapModelsProcess:obj[@"result"] withClass:[Advertisement class]];
                if(advertisements != nil && [advertisements count] != 0)
                {
                    success(advertisements);
                }
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"加载数据失败.");
            }
        }
    } failureBlock:failure];
}


/**
 @desc 获取专区
 */

- (void)getZone:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Zone_With_Goods] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *dict in result) {
                CommodityZone *zone = [CommodityZone CommodityZoneWithDict:dict];
                zone.goods_list = [self mapModelsProcess:dict[@"goods_list"] withClass:[Commodity class]];
                [arrayM addObject:zone];
            }
            
            NSArray *zones = arrayM;
            if(success)
            {
                success(zones);
            }
        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有商品!");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 根据专区获取商品
 */

- (void)getGoodsByZone:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Get_Goods_By_Zone] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status integerValue] == 1)
        {
            NSArray * result = [obj objectForKey:@"result"];
            NSArray * commodities = [self mapModelsProcess:result withClass:[Commodity class]];
            if(success)
            {
                success(commodities);
            }

        }
        else if([status integerValue] == 0)
        {
            if(failure)
            {
                failure(nil,@"暂时没有商品!");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加客服
 */
//TODO:添加客服
- (void)addService:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Service] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            NSString * result = [obj valueForKey:@"result"];
            if(success)
            {
                success(result);
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"更新失败");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加真实姓名
 */
//TODO:添加真实姓名
- (void)addUserRealName:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Real_Name] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            NSString * result = [obj valueForKey:@"result"];
            if(success)
            {
                success(result);
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"更新失败");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 添加店铺名称
 */
//TODO:添加店铺名称
- (void)addShopName:(NSDictionary *)params  completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Add_Shop_Name] withParams:params completionBlock:^(id obj) {
        NSString * status = [obj objectForKey:@"status"];
        if([status intValue] == 1)
        {
            NSString * result = [obj valueForKey:@"result"];
            if(success)
            {
                success(result);
            }
        }
        else
        {
            if(failure)
            {
                failure(nil,@"更新失败");
            }
        }
    } failureBlock:failure];
}

/**
 @desc 判断是否第三方登陆
 */
//TODO:判断是否第三方登陆
- (void)isOpenLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Open_Login] withParams:params completionBlock:^(id obj) {
        NSString * result = [obj valueForKey:@"status"];
        if([result intValue] == 1)
        {
            id result = [obj valueForKey:@"result"];
            if ([result isKindOfClass:[NSArray class]]) {
                NSLog(@"%@",result);
                result = (NSArray *)result;
                NSDictionary * info = nil;
                if ([result count] > 0) {
                    info = [result objectAtIndex:0];
                }
                User * user = [self mapModel:info withClass:[User class]];
                if(success)
                {
                    success(user);
                }
            }else{
                success(@"该账号未绑定");
            }
            
        }
        else if ([result intValue] == 0)
        {
            //密码错误
            //用户名不存在
            if(failure)
            {
                failure(nil,result);
            }
        }

    } failureBlock:failure];
}

@end

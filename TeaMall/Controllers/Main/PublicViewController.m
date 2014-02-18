//
//  PublicViewController.m
//  TeaMall
//
//  Created by vedon on 13/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "PublicViewController.h"
#import "PopupTagViewController.h"
#import "PhotoManager.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "HttpService.h"
#import "TeaCategory.h"
#import "User.h"
#import "GTMBase64.h"

@interface PublicViewController ()<UITextFieldDelegate>
{
    //品牌
    NSArray * brandArray;
    
    //数量下拉表
    PopupTagViewController * numberTable;
    
    //牌子下拉表
    PopupTagViewController * brandTable;
    
    //记录拍照的图片数量
    NSInteger currentImageCount;
    
    //保存拍照的图片
    NSMutableArray * takenPhotoArray;
}
@end

@implementation PublicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard:) name:@"HideKeyboard" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    brandArray = @[@"HTC",@"Apple",@"Nokia"@"Sangsun"];
    numberTable = nil;
    brandTable = nil;
    currentImageCount = 0;
    takenPhotoArray  = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc
{
    takenPhotoArray = nil;
}

#pragma mark - Private Methods
- (void)dismissKeyboard:(NSNotification *)notification
{
    [self.view endEditing:YES];
    [self resignFirstResponder];
}



- (IBAction)IwantBuyAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self.wantSellBtn setSelected:NO];
}

- (IBAction)IwantSellAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    [self.wantBuyBtn setSelected:NO];
}

- (IBAction)selectedBrandAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        if (!brandTable) {
            brandTable = [[PopupTagViewController alloc]initWithNibName:@"PopupTagViewController" bundle:nil];
            NSArray * array = @[@"品牌",@"产品",@"交易号",@"升价",@"降价"];
            [brandTable setDataSource:array];
            //设置位置
            CGRect originalRect = brandTable.view.frame;
            originalRect.origin.x = btn.frame.origin.x + btn.frame.size.width/2.0 - originalRect.size.width/2;
            originalRect.origin.y = btn.frame.origin.y + btn.frame.size.height +10;
            [brandTable.view setFrame:originalRect];
            
            [brandTable setBlock:^(NSString * item){
                [btn setSelected:NO];
                [btn setTitle:item forState:UIControlStateNormal];
            }];
            [self addChildViewController:brandTable];
            [self.view addSubview:brandTable.view];
        }else
        {
            [self.view addSubview:brandTable.view];
        }
    }else
    {
        [brandTable.view removeFromSuperview];
    }
}

- (IBAction)selectedNumberAction:(id)sender {
    /*
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        if (!numberTable) {
            numberTable = [[PopupTagViewController alloc]initWithNibName:@"PopupTagViewController" bundle:nil];
            NSArray * array = @[@"品牌",@"产品",@"交易号",@"升价",@"降价"];
            [numberTable setDataSource:array];
            //设置位置
            CGRect originalRect = numberTable.view.frame;
            originalRect.origin.x = btn.frame.origin.x + btn.frame.size.width/2.0 - originalRect.size.width/2;
            originalRect.origin.y = btn.frame.origin.y + btn.frame.size.height +10;
            [numberTable.view setFrame:originalRect];
            
            [numberTable setBlock:^(NSString * item){
                [btn setSelected:NO];
            }];
            [self addChildViewController:numberTable];
            [self.view addSubview:numberTable.view];
        }else
        {
            [self.view addSubview:numberTable.view];
        }
    }else
    {
        [numberTable.view removeFromSuperview];
    }
    */
}

- (IBAction)isCanSanChuAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
}

- (IBAction)takePhotoAction:(id)sender {
    if (currentImageCount <3) {
        AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        __weak PublicViewController * weakSelf = self;
        [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
         {
             UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
             [imageView setFrame:CGRectMake(10+(56+5)*currentImageCount, weakSelf.addImageBtn.frame.origin.y, 56, 56)];
            currentImageCount ++;
             if (currentImageCount == 3) {
                 [weakSelf.addImageBtn setHidden:YES];
             }else
             {
                 weakSelf.addImageBtn.frame = CGRectOffset(weakSelf.addImageBtn.frame, (56+5), 0);
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.imageContanier addSubview:imageView];
             });
             [takenPhotoArray addObject:image];
         }];
        [myDelegate.containerViewController presentViewController:[PhotoManager shareManager].camera animated:YES completion:nil];
    }else
    {
        //达到拍照上限
        [self showAlertViewWithMessage:@"最多只可以上传三张图片"];
    }
    
}

- (IBAction)choosePhotoAction:(id)sender {
    if (currentImageCount <=3) {
        AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        __weak PublicViewController * weakSelf = self;
        [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
         {
             UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
             [imageView setFrame:CGRectMake(10+(56+5)*currentImageCount, weakSelf.addImageBtn.frame.origin.y, 56, 56)];
             currentImageCount ++;
             imageView.tag = currentImageCount;
             if (currentImageCount == 3) {
                 [weakSelf.addImageBtn setHidden:YES];
             }else
             {
                 weakSelf.addImageBtn.frame = CGRectOffset(weakSelf.addImageBtn.frame, (56+5), 0);
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.imageContanier addSubview:imageView];
             });
             [takenPhotoArray addObject:[image imageWithScale:.5]];
         }];
        [myDelegate.containerViewController presentViewController:[PhotoManager shareManager].pickingImageView animated:YES completion:nil];
    }else
    {
        //达到拍照上限
        [self showAlertViewWithMessage:@"最多只可以上传三张图片"];
    }
    
}

- (IBAction)publishAction:(id)sender
{
    if(!_wantBuyBtn.selected && !_wantSellBtn.selected)
    {
        [self showAlertViewWithMessage:@"请选择类型"];
        return ;
    }
    
    NSString * brand = [_brandBtn titleForState:UIControlStateNormal];
    if([brand isEqualToString:@"请选择品牌"])
    {
        [self showAlertViewWithMessage:brand];
        return ;
    }
    
    if([_productName.text length] == 0)
    {
        [self showAlertViewWithMessage:@"请输入产品名称"];
        return ;
    }
    
    if([_productPrice.text length] == 0)
    {
        [self showAlertViewWithMessage:@"请输入产品数量"];
        return ;
    }
    
    if([_productPrice.text length] == 0)
    {
        [self showAlertViewWithMessage:@"请输入产品单价"];
        return ;
    }
    
    User * user = [User userFromLocal];
    if(user == nil)
    {
        [self showAlertViewWithMessage:@"请先登录"];
        return ;
    }
    NSString * is_buy ;
    if(_wantSellBtn.selected)
    {
        is_buy = @"0";
    }
    
    if(_wantBuyBtn.selected)
    {
        is_buy = @"1";
    }
    
    NSString * cate_id = @"1";
    NSString * user_id = user.hw_id;
    NSString * name = _productName.text;
    NSString * amount = _productNumber.text;
    NSString * price = _productPrice.text;
    NSString * business_number = [self generateTradeNO];
    NSString * is_distribute = @"0";
    if(_sanchuBtn.selected)
    {
        is_distribute = @"1";
    }
    
    NSDictionary * temp = @{@"user_id":user_id,@"cate_id":cate_id,@"name":name,@"amount":amount,@"price":price,@"business_number":business_number,@"is_buy":is_buy,@"is_distribute":is_distribute};
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:temp];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([takenPhotoArray count] > 0)
    {
        hud.labelText = @"正在处理图片";
        UIImage * image_1 = [takenPhotoArray objectAtIndex:0];
        [params setObject:[self encodeImage:image_1] forKey:@"image_1"];
        if([takenPhotoArray count] >= 2)
        {
            UIImage * image_2 = [takenPhotoArray objectAtIndex:1];
            [params setObject:[self encodeImage:image_2] forKey:@"image_2"];
        }
        
        if([takenPhotoArray count] >= 3)
        {
            UIImage * image_3 = [takenPhotoArray objectAtIndex:2];
            [params setObject:[self encodeImage:image_3] forKey:@"image_3"];
        }
    }
    
    //NSLog(@"%@",params);
    
    hud.labelText = @"提交中...";
    [[HttpService sharedInstance] addPublish:params completionBlock:^(id object) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"发布成功";
        [hud hide:YES afterDelay:1.0];
        _wantBuyBtn.selected = NO;
        _wantSellBtn.selected = NO;
        _sanchuBtn.selected = NO;
        _productName.text = nil;
        _productNumber.text = nil;
        _productPrice.text = nil;
        [_brandBtn setTitle:@"请选择品牌" forState:UIControlStateNormal];
        for(int i = 1; i <= 3; i++)
        {
            [[_imageContanier viewWithTag:i] removeFromSuperview];
        }
        _addImageBtn.hidden = NO;
        _addImageBtn.frame = CGRectMake(12, 13, 56, 56);
        [takenPhotoArray removeAllObjects];
    } failureBlock:^(NSError *error, NSString *responseString) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"发布失败,请重试";
        [hud hide:YES afterDelay:1.0];
    }];
    
}


- (NSString *)encodeImage:(UIImage *)image
{
    NSAssert(image != nil, @"The image is nil.");
    NSData * data = UIImagePNGRepresentation(image);
    NSString * base64String = [GTMBase64 encodeBase64Data:data];
    return base64String;
}


/*
 *随机生成15位订单号,外部商户根据自己情况生成订单号
 */
- (NSString *)generateTradeNO
{
	const int N = 15;
	
	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *result = [[NSMutableString alloc] init];
	srand(time(0));
	for (int i = 0; i < N; i++)
	{
		unsigned index = rand() % [sourceString length];
		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
		[result appendString:s];
	}
	return result;
}


#pragma mark - UITextViewDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end

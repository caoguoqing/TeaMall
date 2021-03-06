//
//  LoginViewController.h
//  TeaMall
//
//  Created by Carl_Huang on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface LoginViewController : CommonViewController<UITextFieldDelegate>
- (IBAction)gotoMainView:(id)sender;
@property (nonatomic,assign) BOOL isNeedGoBack;
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *passWord;
- (IBAction)loginAction:(id)sender;

- (IBAction)openLogin:(UIButton *)sender;



@end

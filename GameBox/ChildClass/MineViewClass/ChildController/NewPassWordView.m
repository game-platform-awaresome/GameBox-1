//
//  ReSetPassWordView.m
//  GameBox
//
//  Created by 石燚 on 2017/4/12.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "NewPassWordView.h"
#import "LoginViewController.h"
#import "UserModel.h"

//@class LoginViewController;

@interface NewPassWordView ()<UITextFieldDelegate>

//新密码
@property (nonatomic, strong) UITextField *passWord;

//确认密码
@property (nonatomic, strong) UITextField *affimPassWord;

//完成按钮
@property (nonatomic, strong) UIButton *completeBtn;

@end

@implementation NewPassWordView

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.passWord.text = @"";
    self.affimPassWord.text = @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUserInterface];
}

- (void)initUserInterface {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"新密码";
    [self.view addSubview:self.passWord];
    [self.view addSubview:self.affimPassWord];
    [self.view addSubview:self.completeBtn];
}

#pragma mark - responds
- (void)respondsToCompleteBtn {
    //密码太短
    if (self.passWord.text.length < 6 || self.affimPassWord.text.length < 6) {
        [UserModel showAlertWithMessage:@"密码长度太短" dismiss:nil];
        return;
    }
    
    if (![self.passWord.text isEqualToString:self.affimPassWord.text]) {
        [UserModel showAlertWithMessage:@"两次密码不相同" dismiss:nil];
        return;
    }
    
    syLog(@"%@",self.userToken);
    
    [UserModel userForgetPasswordWithUserID:self.userId Password:self.passWord.text RePassword:self.affimPassWord.text Token:self.userToken Completion:^(NSDictionary * _Nullable content, BOOL success) {
        
        if (success) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [UserModel showAlertWithMessage:@"修改成功" dismiss:nil];
        } else {
            [UserModel showAlertWithMessage:@"修改失败" dismiss:nil];
        }
        
        syLog(@"%@",content);
        
    }];
    
}

#pragma mark - textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passWord) {
        [textField resignFirstResponder];
        [self.affimPassWord becomeFirstResponder];
    } else if (textField == self.affimPassWord) {
        [self respondsToCompleteBtn];
    }
    
    return YES;
}

//限制用户名和密码长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.passWord) {
        if (range.length == 1 && string.length == 0) {
            return YES;
        } else if (self.passWord.text.length >= 16) {
            self.passWord.text = [textField.text substringToIndex:16];
            return NO;
        }
    } else if (textField == self.affimPassWord) {
        if (range.length == 1 && string.length == 0) {
            return YES;
        } else if (self.affimPassWord.text.length >= 16) {
            self.affimPassWord.text = [textField.text substringToIndex:16];
            return NO;
        }
    }
    return YES;
}

#pragma mark - getter
- (UITextField *)passWord {
    if (!_passWord) {
        _passWord = [[UITextField alloc]init];
        _passWord.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _passWord.center = CGPointMake(kSCREEN_WIDTH / 2, 120);
        
        _passWord.delegate = self;
        _passWord.borderStyle = UITextBorderStyleRoundedRect;
        _passWord.placeholder = @"请输入新密码";
        _passWord.secureTextEntry = YES;
        _passWord.delegate = self;
        _passWord.returnKeyType = UIReturnKeyNext;
    }
    return _passWord;
}

- (UITextField *)affimPassWord {
    if (!_affimPassWord) {
        _affimPassWord = [[UITextField alloc]init];
        _affimPassWord.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _affimPassWord.center = CGPointMake(kSCREEN_WIDTH / 2, 185);
        
        _affimPassWord.borderStyle = UITextBorderStyleRoundedRect;
        _affimPassWord.placeholder = @"确认密码";
        _affimPassWord.secureTextEntry = YES;
        _affimPassWord.delegate = self;
        _affimPassWord.returnKeyType = UIReturnKeyDone;
    }
    return _affimPassWord;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _completeBtn.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _completeBtn.center = CGPointMake(kSCREEN_WIDTH / 2, 250);
        [_completeBtn setTitle:@"完成" forState:(UIControlStateNormal)];
        [_completeBtn setBackgroundColor:[UIColor orangeColor]];
        _completeBtn.layer.cornerRadius = 4;
        _completeBtn.layer.masksToBounds = YES;
        [_completeBtn addTarget:self action:@selector(respondsToCompleteBtn) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _completeBtn;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

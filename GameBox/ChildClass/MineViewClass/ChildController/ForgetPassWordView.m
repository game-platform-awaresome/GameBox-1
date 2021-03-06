//
//  ForgetPassWordView.m
//  GameBox
//
//  Created by 石燚 on 2017/4/12.
//  Copyright © 2017年 SingYi. All rights reserved.
//

#import "ForgetPassWordView.h"
#import "NewPassWordView.h"
#import "UserModel.h"


@interface ForgetPassWordView ()<UITextFieldDelegate>

//手机号
@property (nonatomic, strong) UITextField *phoneNumber;

//验证码
@property (nonatomic, strong) UITextField *securityCode;

//发送验证码按钮
@property (nonatomic, strong) UIButton *sendCodeBtn;

//下一步
@property (nonatomic, strong) UIButton *next;

@property (nonatomic, strong) NewPassWordView *newPassWordView;

/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;
//当前的时间;
@property (nonatomic, assign) NSInteger currnetTime;

@end

@implementation ForgetPassWordView

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInterface];
}

- (void)initUserInterface {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"找回密码";
    
    [self.view addSubview:self.phoneNumber];
    [self.view addSubview:self.securityCode];
    [self.view addSubview:self.next];
}

#pragma mark - responds
/** 下一步 */
- (void)respondsToNext {
    NSString *MOBILE = @"^1(3[0-9]|4[0-9]|5[0-9]|8[0-9]|7[0-9])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //手机号有误
    if (![regextestmobile evaluateWithObject:self.phoneNumber.text]) {
        [UserModel showAlertWithMessage:@"手机号码有误" dismiss:nil];
        return;
    }
    
    [UserModel userCheckMessageWithPhoneNumber:self.phoneNumber.text MessageCode:self.securityCode.text Completion:^(NSDictionary * _Nullable content, BOOL success) {
        
        if (success && REQUESTSUCCESS) {
            self.newPassWordView.userId = content[@"data"][@"id"];
            self.newPassWordView.userToken = content[@"data"][@"token"];
            [self.navigationController pushViewController:self.newPassWordView animated:YES];
        } else {
            if (content) {
                [UserModel showAlertWithMessage:REQUESTMSG dismiss:nil];
            } else {
                [UserModel showAlertWithMessage:@"网络不知道飞哪里去了~" dismiss:nil];
            }
        }
        
    }];
}

/** 发送验证码 */
- (void)respondsToSendCodeBtn {
    NSString *MOBILE = @"^1(3[0-9]|4[0-9]|5[0-9]|8[0-9]|7[0-9])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //手机号有误
    if (![regextestmobile evaluateWithObject:self.phoneNumber.text]) {
        [UserModel showAlertWithMessage:@"手机号码有误" dismiss:nil];
        return;
    }
    
    [ControllerManager starLoadingAnimation];
    [UserModel userSendMessageWithPhoneNumber:self.phoneNumber.text IsVerify:@"1" Completion:^(NSDictionary * _Nullable content, BOOL success) {
        _currnetTime = 59;
        [ControllerManager stopLoadingAnimation];
        if (success && REQUESTSUCCESS) {
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTime) userInfo:nil repeats:YES];
        } else {
            if (content) {
                [UserModel showAlertWithMessage:REQUESTMSG dismiss:nil];
            } else {
                [UserModel showAlertWithMessage:@"网络不知道飞哪里去了~" dismiss:nil];
            }
        }
    }];
}

- (void)refreshTime {
    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds",_currnetTime] forState:(UIControlStateNormal)];
    [self.sendCodeBtn setUserInteractionEnabled:NO];
    if (_currnetTime <= 0) {
        [self stopTimer];
        [self.sendCodeBtn setUserInteractionEnabled:YES];
        [self.sendCodeBtn setTitle:@"发送" forState:(UIControlStateNormal)];
    }
    _currnetTime--;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark - textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.phoneNumber) {
        [textField resignFirstResponder];
        [self.securityCode becomeFirstResponder];
    } else if (textField == self.securityCode) {
        [self respondsToNext];
    }
    
    return YES;
}

//限制用户名和密码长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.phoneNumber) {
        if (range.length == 1 && string.length == 0) {
            return YES;
        } else if (self.phoneNumber.text.length >= 11) {
            self.phoneNumber.text = [textField.text substringToIndex:11];
            return NO;
        }
    } else if (textField == self.securityCode) {
        if (range.length == 1 && string.length == 0) {
            return YES;
        } else if (self.securityCode.text.length >= 6) {
            self.securityCode.text = [textField.text substringToIndex:6];
            return NO;
        }
    }
    return YES;
}

#pragma mark - getter
- (UITextField *)phoneNumber {
    if (!_phoneNumber) {
        _phoneNumber = [[UITextField alloc]init];
        _phoneNumber.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _phoneNumber.center = CGPointMake(kSCREEN_WIDTH / 2, 120);

        _phoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _phoneNumber.placeholder = @"请输入手机号码";
        _phoneNumber.delegate = self;
        _phoneNumber.returnKeyType = UIReturnKeyNext;
        _phoneNumber.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    return _phoneNumber;
}

- (UITextField *)securityCode {
    if (!_securityCode) {
        _securityCode = [[UITextField alloc]init];
        _securityCode.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _securityCode.center = CGPointMake(kSCREEN_WIDTH / 2, 185);
        
        _securityCode.rightView = self.sendCodeBtn;
        _securityCode.rightViewMode = UITextFieldViewModeAlways;
        
        _securityCode.borderStyle = UITextBorderStyleRoundedRect;
        _securityCode.placeholder = @"请输入验证码";
        _securityCode.delegate = self;
        
        _securityCode.returnKeyType = UIReturnKeyNext;
        _securityCode.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    return _securityCode;
}

- (UIButton *)sendCodeBtn {
    if (!_sendCodeBtn) {
        _sendCodeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _sendCodeBtn.frame = CGRectMake(0, 0, kSCREEN_WIDTH * 0.2, 44);
        [_sendCodeBtn setTitle:@"发送" forState:(UIControlStateNormal)];
        [_sendCodeBtn setBackgroundColor:[UIColor orangeColor]];
        _sendCodeBtn.layer.cornerRadius = 4;
        _sendCodeBtn.layer.masksToBounds = YES;
        [_sendCodeBtn addTarget:self action:@selector(respondsToSendCodeBtn) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _sendCodeBtn;
}

- (UIButton *)next {
    if (!_next) {
        _next = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _next.bounds = CGRectMake(0, 0, kSCREEN_WIDTH * 0.8, 44);
        _next.center = CGPointMake(kSCREEN_WIDTH / 2, 250);
        [_next setTitle:@"下一步" forState:(UIControlStateNormal)];
        [_next setBackgroundColor:[UIColor orangeColor]];
        _next.layer.cornerRadius = 4;
        _next.layer.masksToBounds = YES;
        [_next addTarget:self action:@selector(respondsToNext) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _next;
}

- (NewPassWordView *)newPassWordView {
    if (!_newPassWordView) {
        _newPassWordView = [NewPassWordView new];
    }
    return _newPassWordView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

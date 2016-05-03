//
//  LCPViewController.m
//  LycamPlusMsgSDK
//
//  Created by no777 on 04/18/2016.
//  Copyright (c) 2016 no777. All rights reserved.
//
#define myLogLevel DDLogLevelVerbose

#import "LCPViewController.h"

@interface LCPViewController (){

}

@property (strong, nonatomic) LCPMessageManager *manager;
@property (strong, nonatomic) UITextField *textField;

@property (nonatomic, retain) UITextView *textView;
@end


@implementation LCPViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 20.0f, 200.0, 30.0f)];
    [_textField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    
    _textField.placeholder = @"输入文字"; //默认显示的字
    
//    _textField.secureTextEntry = YES; //密码
    
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    
    _textField.delegate = self;
    [self.view addSubview:_textField];
    
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50.0f, 320, 400)] ; //初始化大小并自动释放
    
    self.textView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
    
    self.textView.font = [UIFont fontWithName:@"Arial" size:18.0];//设置字体名字和字体大小
    
    self.textView.delegate = self;//设置它的委托方法
    
    self.textView.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    
    
    
//    self.textView.text = @"Now is the time for all good developers to come to serve their country.\n\nNow is the time for all good developers to come to serve their country.";//设置它显示的内容
    
    self.textView.returnKeyType = UIReturnKeyDefault;//返回键的类型
    
    self.textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    
    self.textView.scrollEnabled = YES;//是否可以拖动
    
    
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    
    
    
    [self.view addSubview: self.textView];//加入到整个页面中
    

    NSDictionary * config = @{kLCPMSGAppName:@"testapp",
                              kLCPMSGServerHost:@"mqtt.lycam.tv",
                              kLCPMSGServerPort:@(1883),
                              kLCPMSGTls:@(NO)
                              };
    
    _manager = [[ LCPMessageManager alloc]  initWithToken:@"8CBP9OCqE4Ht7L4PjlMfO65LVVrMzIn4OGTBDTdzg1tSrjgu619Irlp9l2VuSD51" withConfig:config];
    _manager.delegate = self;
    [_manager connect];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    NSDictionary * msg = @{
                           @"type":@"chat",
                           @"msg": @{
                                   @"title":@"wowo",
                                   @"body":self.textField.text
                                   }
                           };
    [self.manager send:msg withChannel:@"channel1"];
    self.textField.text = @"";
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) managerConnecting:(LCPMessageManager *)manager{
}
-(void) managerConnected:(LCPMessageManager *)manager{
    NSLog(@"connected");
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text,@"connected!" ];
    [_manager subscribeChannel:@"channel1"];
//    NSDictionary * msg = @{
//                           @"type":@"chat",
//                           @"msg": @{
//                                   @"title":@"wowo",
//                                   @"body":@"测试"
//                                   }
//                           };
//    [self.manager send:msg];
}
-(void) manager:(LCPMessageManager *)manager receiveMessage:(NSDictionary * )msg withTopic:(NSString *)topic withRetained:(BOOL)retained{
    NSLog(@"receiveMessage:%@ <-%@",msg,topic);
    NSDictionary * _m = [msg objectForKey:@"msg"];
    NSString * body = [_m objectForKey:@"body"];
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text,body ];
// 初始化AlertView
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
//                                                    message: body
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"OtherBtn",nil];
//    [alert show];
    
}
-(void) manager:(LCPMessageManager *)manager error:(NSError *)error{
    self.textView.text = [NSString stringWithFormat:@"%@error:%d %@\n", self.textView.text, error.code,[error localizedDescription] ];

}
@end

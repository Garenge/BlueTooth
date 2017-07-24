//
//  SetFilterStringVC.m
//  demo_blueTooth
//
//  Created by LZP on 2017/7/22.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import "SetFilterStringVC.h"
#import "UIViewController+DIYViewController.h"

@interface SetFilterStringVC ()
@property (weak, nonatomic) IBOutlet UITextField *fliterTF;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation SetFilterStringVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sureBtn.layer.cornerRadius = 5;
    self.sureBtn.layer.borderWidth = 1;
    self.sureBtn.layer.borderColor = [UIColor grayColor].CGColor;
    self.sureBtn.layer.masksToBounds = YES;
    
    self.fliterTF.placeholder = self.preFilteration;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sureBtnClick:(UIButton *)sender {
    if(self.fliterTF.text.length > 0) {
        // 弹窗警告

        [self alertControllerWithTitle:@"提示" message:@"添加过滤规则成功" preferredStyle:UIAlertControllerStyleAlert YESTitle:@"确定" YESAction:^{
            self.setFilerBlock(self.fliterTF.text);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self alertControllerWithTitle:@"提示" message:@"确定将清除过滤规则" preferredStyle:UIAlertControllerStyleAlert YESTitle:@"确定" YESAction:^{
            self.setFilerBlock(@"");
            [self alertControllerWithTitle:@"提示" message:@"填写成功" preferredStyle:UIAlertControllerStyleAlert YESTitle:@"确定" YESAction:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } NOTitle:@"取消" NoAction:^{
            
        }];
        
    }
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

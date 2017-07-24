//
//  UIViewController+DIYViewController.m
//  Angel
//
//  Created by LZP on 2017/7/2.
//  Copyright © 2017年 garenge. All rights reserved.
//

#import "UIViewController+DIYViewController.h"

@implementation UIViewController (DIYViewController)

- (void)alertControllerWithTitle:(NSString *)title
                         message:(NSString *)message
                  preferredStyle:(UIAlertControllerStyle)controllerStyle
                        YESTitle:(NSString *)yesTitle
                       YESAction:(void (^)())yesAction
                         NOTitle:(NSString *)noTitle
                        NoAction:(void (^)())noAction {
    
    [self alertControllerWithTitle:title
                           message:message
                    preferredStyle:controllerStyle
                            Title1:yesTitle
                      ActionStyle1:UIAlertActionStyleDefault
                           Action1:yesAction
                            Title2:noTitle
                      ActionStyle2:UIAlertActionStyleCancel
                           Action2:noAction];
}

- (void)alertControllerWithTitle:(NSString *)title
                         message:(NSString *)message
                  preferredStyle:(UIAlertControllerStyle)controllerStyle
                          Title1:(NSString *)title1
                    ActionStyle1:(UIAlertActionStyle)actionStyle1
                         Action1:(void (^)())action1
                          Title2:(NSString *)title2
                    ActionStyle2:(UIAlertActionStyle)actionStyle2
                         Action2:(void (^)())action2 {
    
    // 简单应用
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:controllerStyle];
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:title1
                                                        style:actionStyle1
                                                      handler:^(UIAlertAction * _Nonnull action) {
        action1();
    }];
    UIAlertAction *actionTwo = [UIAlertAction actionWithTitle:title2
                                                        style:actionStyle2
                                                      handler:^(UIAlertAction *action) {
        action2();
    }];
    [alert addAction:actionOne];
    [alert addAction:actionTwo];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)alertControllerWithTitle:(NSString *)title
                         message:(NSString *)message
                  preferredStyle:(UIAlertControllerStyle)controllerStyle
                        YESTitle:(NSString *)yesTitle
                       YESAction:(void (^)())yesAction {
    
    [self alertControllerWithTitle:title
                           message:message
                    preferredStyle:controllerStyle
                            Title1:yesTitle
                      ActionStyle1:UIAlertActionStyleDefault
                           Action1:yesAction];
}

- (void)alertControllerWithTitle:(NSString *)title
                         message:(NSString *)message
                  preferredStyle:(UIAlertControllerStyle)controllerStyle
                          Title1:(NSString *)title1
                    ActionStyle1:(UIAlertActionStyle)actionStyle1
                         Action1:(void (^)())action1 {
    // 简单应用
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:controllerStyle];
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:title1
                                                        style:actionStyle1
                                                      handler:^(UIAlertAction * _Nonnull action) {
        action1();
    }];
    [alert addAction:actionOne];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

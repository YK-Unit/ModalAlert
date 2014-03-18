//
//  ModalAlert.h
//  ModalAlertDemo
//
//  Created by zhang zhiyu on 14-3-17.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

/*
 Base on Erica Sadun's ModalAlert(https://github.com/erica/iphone-3.0-cookbook-/tree/master/C10-Alerts/02-Modal%20Alert)
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface ModalAlert : NSObject
+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons;
+ (void) say: (id)formatstring,...;
+ (BOOL) confirm: (id)formatstring,...;
+ (BOOL) ask: (id)formatstring,...;
+ (NSString *) ask: (NSString *) question withKeyborType:(UIKeyboardType)type withTextPrompt: (NSString *) prompt;
+ (NSArray *) ask:(NSString *)question withKeyborType:(UIKeyboardType)type withTextPrompt:(NSString *)prompt  withAnotherKeyborType:(UIKeyboardType)anotherType withAnotherTextPrompt:(NSString *)anotherPrompt;
+ (NSArray *) askUserNameAndPassword:(NSString *)question withNameKeyborType:(UIKeyboardType)nameType withNameTextPrompt:(NSString *)namePrompt  withPasswordKeyborType:(UIKeyboardType)passwordType withPasswordTextPrompt:(NSString *)passwordPrompt;

@end

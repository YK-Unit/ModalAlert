//
//  ViewController.m
//  ModalAlertDemo
//
//  Created by zhang zhiyu on 14-3-18.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "ViewController.h"
#import "ModalAlert.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickButton:(id)sender {
    UIButton *bt = (UIButton *)sender;
    switch (bt.tag) {
        case 100:
            [ModalAlert say:@"This is a Demo for ModalAlert"];
            break;
        case 101:
        {
            BOOL flag = [ModalAlert confirm:@"Do you know this phone number %d?",110];
            NSLog(@"flag:%d",flag);
        }
            break;
        case 102:
        {
            BOOL flag = [ModalAlert ask:@"Is today's date %@?",[NSDate date]];
            NSLog(@"flag:%d",flag);
        }
            break;
        case 103:
        {
            NSInteger i = [ModalAlert ask:@"Which color do you like?" withCancel:@"None" withButtons:[NSArray arrayWithObjects:@"Blue",@"Red",nil]];
            NSLog(@"the index is:%d",i);
        }
            break;
        case 104:
        {
            NSString *str = [ModalAlert ask:@"What's your phone number?" withKeyborType:UIKeyboardTypePhonePad withTextPrompt:@"phone number"];
            NSLog(@"the string is:%@",str);
        }
            break;
        case 105:
        {
            NSArray *array = [ModalAlert ask:@"Set your address" withKeyborType:UIKeyboardTypeDefault withTextPrompt:@"Address" withAnotherKeyborType:UIKeyboardTypeNumberPad withAnotherTextPrompt:@"ZIP Code"];
            NSLog(@"the array is:%@",array);
        }
            break;
        case 106:
        {
            NSArray *array = [ModalAlert askUserNameAndPassword:@"Login" withNameKeyborType:UIKeyboardTypeEmailAddress withNameTextPrompt:@"username" withPasswordKeyborType:UIKeyboardTypeDefault withPasswordTextPrompt:@"password"];
            NSLog(@"the array is:%@",array);
        }
            break;
        default:
            break;
    }
}
@end

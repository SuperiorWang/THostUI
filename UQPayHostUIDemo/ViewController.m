//
//  ViewController.m
//  UQPayHostUIDemo
//
//  Created by uqpay on 2019/7/4.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "ViewController.h"
#import <UQPayHostUI/UQPayHostUI.h>

@interface ViewController ()<UQHostUIViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong )UQHostUIViewController *viewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textField.text = @"b119e08119b54a69a99b1683df6d383c";
}

- (IBAction)openUI:(id)sender {
    
    self.viewController = [[UQHostUIViewController alloc]initWithModel:LOCALTYPE];
    self.viewController.token = self.textField.text;
    self.viewController.delegate = self;
    [self presentViewController:self.viewController animated:true completion:NULL];
}

- (void)UQHostResult:(UQHostResult *)model {
    NSLog(@"panTail = %@", model.panTail);
    NSLog(@"uuid = %@",model.uuid);
    NSLog(@"ussuer = %@", model.issuer);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

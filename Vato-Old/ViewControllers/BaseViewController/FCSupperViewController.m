//
//  FCSupperViewController.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSupperViewController.h"

@interface FCSupperViewController ()

@end

@implementation FCSupperViewController

- (instancetype) initView {
    self = [super init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) closePressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    
    return NO;
}

@end

//
//  AboutViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/2/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "AboutViewController.h"
#import "KYDrawerController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IndicatorUtils show];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)menuClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
}

@end

//
//  FCViewController.m
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCViewController.h"
#import "FacecarNavigationViewController.h"

@interface FCViewController ()

@end

@implementation FCViewController

@synthesize title;

- (instancetype) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (instancetype) initViewController {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void) initViewWithNavi {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isPushedView) {
        self.icBtnLeft = @"back";
    }
    else {
        self.icBtnLeft = @"close-w";
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:self.icBtnLeft]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(btnLeftClicked:)];
    UIImage *image = [self.icBtnRight length] > 0 ? [UIImage imageNamed:self.icBtnRight] : nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(btnRightClicked:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = self.title;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) btnLeftClicked: (id) sender {
    
}

- (void) btnRightClicked: (id) sender {
    
}

@end

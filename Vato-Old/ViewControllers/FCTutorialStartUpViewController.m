//
//  FCTutorialStartUpViewController.m
//  FaceCar
//
//  Created by facecar on 11/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTutorialStartUpViewController.h"
#import "UIView+Border.h"

@interface FCTutorialStartUpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation FCTutorialStartUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imgBg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tut-%ld", (long)self.currentPage]]];
    
    NSString* title;
    if (self.currentPage == 0) {
        title = @"Bạn cần đến đâu ?\nHoặc chỉ cần một chạm bạn sẽ có ngay chuyến đi với lộ trình thực tế";
    }
    else if (self.currentPage == 1) {
        title = @"Biết trước thông tin với chuyến đi cố định";
    }
    else if (self.currentPage == 2) {
        title = @"Làm chủ cước phí chuyến đi với tính năng đề nghị giá và hoa hồng đặt xe dùm";
    }
    else if (self.currentPage == 3) {
        title = @"Theo dõi chuyến đi an toàn và tiện ích cùng VATO";
    }
    else {
        title = @"Kết thúc hành trình mỹ mãn và lựa cho mình những lái xe riêng dễ thương";
    }
    
    self.lblTitle.text = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  InviteViewController.m
//  FaceCar
//
//  Created by facecar on 3/28/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "InviteViewController.h"
#import "FCWarningNofifycationView.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCFindView.h"
#import "APICall.h"

@interface InviteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBody;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;
@property (weak, nonatomic) IBOutlet FCButton *btnShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consBtnHeightShare;

@end

@implementation InviteViewController {
    FCMInvite* _invite;
    FCFindView* _findPhoneView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self getInviteContent];
}

- (void) btnLeftClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (void) setupView {
    [self setTitle:localizedFor(@"Giới thiệu bạn bè")];
    
//    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure * appconfigure) {
//        long long accCreated = (long long)_homeviewModel.client.created;
//        BOOL dontallow = _homeviewModel.client.friendCode > 0 ||
//        (accCreated > 0 && appconfigure.time_prevent_invite > 0 && accCreated < appconfigure.time_prevent_invite);
//        self.btnShare.hidden = dontallow;
//        self.consBtnHeightShare.constant =  dontallow ? 0 : self.consBtnHeightShare.constant;
//    }];
}

- (void) reloadData {
    _lblTitle.text = _invite.title;
    _lblBody.text = _invite.body;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_invite.icon_ref]];
    _lblCode.text = _homeviewModel.client.user.phone;
    [_btnMoreInfo setHidden:_invite.href.length == 0];
}

- (void) showErrorNotify {
    FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] initView];
    view.bgColor = [UIColor whiteColor];
    view.messColor = [UIColor darkGrayColor];
    [view show:self.view
         image:[UIImage imageNamed:@"notify-1"]
         title:localizedFor(@"Thông báo")
       message:localizedFor(@"Hiện tại chương trình giới thiệu khách hàng và lái xe tạm dừng để thay đổi chương trình mới. VATO sẽ thông báo ngay khi có chương trình. Trân trọng cảm ơn!")
      buttonOK:localizedFor(@"OK")
  buttonCancel:nil
      callback:^(NSInteger buttonIndex) {
          [self.navigationController dismissViewControllerAnimated:TRUE
                                                        completion:nil];
      }];
    [self.navigationController.view addSubview:view];
}

- (void) getInviteContent {
    [[FirebaseHelper shareInstance] getInviteContent:^(FCMInvite * invite) {
        if (invite && invite.enable) {
            _invite = invite;
            [self reloadData];
        }
        else {
            [self showErrorNotify];
        }
    }];
}

- (void)apiVerifyCode: (NSString*) code {
    [IndicatorUtils show];
    [[APICall shareInstance] apiVerifyRefferalCode:code withComplete:^(NSString * res, BOOL success) {
        
        [IndicatorUtils dissmiss];
        
        if (success) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeSuccess
                                     autoHide:YES
                                      message:localizedFor(@"Chúc mừng bạn nhập mã thành công")
                                   closeClick:nil
                                  bannerClick:nil];
        }
        
        [_findPhoneView removeView];
    }];
}

- (IBAction)shareCodeClicked:(id)sender {
    NSString *title = [NSString stringWithFormat:@"%@ %@ \n%@",[_homeviewModel.client.user getDisplayName], _invite.message, _invite.campaign_url];
    NSArray* dataToShare = @[title];
    
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (IBAction)enterInviteCode:(id)sender {
    _findPhoneView = [[FCFindView alloc] initView:self];
    [_findPhoneView setupView];
    [_findPhoneView.lblTitle setText:localizedFor(@"Nhập mã giới thiệu")];
    [_findPhoneView.lblError setText:localizedFor(@"Mã giới thiệu không hợp lệ.")];
    [self.navigationController.view addSubview:_findPhoneView];
    
    [RACObserve(_findPhoneView, userInfo) subscribeNext:^(FCUserInfo* user) {
        if (user) {
            if ([user.phoneNumber isEqualToString:_homeviewModel.client.user.phone]) {
                _findPhoneView.lblError.text = localizedFor(@"Rất tiếc, bạn không thể nhập mã của chính mình.");
                _findPhoneView.lblError.hidden = NO;
            }
            else {
                [self apiVerifyCode:user.phoneNumber];
            }
        }
    }];
}

- (IBAction)moreInfoClicked:(id)sender {
    FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:_invite.href]];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

@end

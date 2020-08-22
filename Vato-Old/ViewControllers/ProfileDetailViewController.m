//
//  ProfileViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//
#import <GoogleSignIn/GoogleSignIn.h>
#import "ProfileDetailViewController.h"
#import "KYDrawerController.h"
#import "UIView+Border.h"
#import "FCPhotoPicker.h"
#import "FacecarNavigationViewController.h"
#import "FCPassCodeView.h"
#import "FCProfileLevel2ViewController.h"
#import "APIHelper.h"
#import "FBEncryptorAES.h"
#import "UserDataHelper.h"
#import "FCPhoneInputView.h"
#import "FCRegisterStationView.h"
#import "FCPasscodeViewController.h"
#import "APICall.h"
#import "FCUpdateViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#define kClientID @""
#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

#define kClientID @""


#define ERROR_CANNOT_LINK_MSG @"Xảy ra lỗi khi liên kết với tài khoản này. Bạn vui lòng thử lại với tài khoản khác"

#define kSectionInfo            0
#define kSectionChangePIN       1
// #define kSectionSocialConnect   2
#define kSectionLogout          2
NSString * const profileUpdatedNotification = @"profileUpdatedNotification";
NSString * const profileUpdatedAvatarNotification = @"profileUpdatedAvatarNotification";
@interface AppDelegate(Login)
@property (nonatomic, strong) LoggedOutWrapper *wrapper;
@end

@interface ProfileDetailViewController () < UITextFieldDelegate, GIDSignInDelegate>
@property (strong, nonatomic) FCClient* client;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (strong, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UIButton *fbConnection;
@property (weak, nonatomic) IBOutlet UIButton *googleConnection;
@property (weak, nonatomic) IBOutlet UIImageView *fbAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *ggAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePIN;
@property (assign, nonatomic) BOOL prefersBottomBarHidden;
@property (strong, nonatomic) FCSetting* settings;
@property (weak, nonatomic) FCPassCodeView* changeCodeView;
@property (strong, nonatomic) VatoVerifyPasscodeObjC *verifyObjc;

@end

@implementation ProfileDetailViewController {
    
    NSString* lastestPhone;
    UIImage* newAvatarImage;
    UIImage* newLienceImage;
    NSMutableArray* _listViewChangePIN;
    NSMutableArray* _listViewResetPIN;
    BOOL _havePIN;
    FCPassCodeView* newPassView;
    FCPassCodeView* changeCodeView;
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed {
    super.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
}

- (BOOL)hidesBottomBarWhenPushed {
    if (self.navigationController.viewControllers.lastObject != self) {
        return _prefersBottomBarHidden;
    } else {
        return NO;
    }
}

- (void)dealloc
{
    DLog("")
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.verifyObjc = [VatoVerifyPasscodeObjC new];
    self.prefersBottomBarHidden = YES;
    if ([self tabBarController]) {
        self.navigationItem.leftBarButtonItems = nil;
        self.title = localizedFor(@"Tài khoản");
    } else {
        self.title = localizedFor(@"Thông tin cá nhân");
    }
    
    self.navigationController.navigationBar.hidden = NO;
    
    [self.avatar circleView:ORANGE_COLOR];
    [self.fbAvatar circleView:[UIColor clearColor]];
    [self.ggAvatar circleView:[UIColor clearColor]];
    [self.fbConnection borderViewWithColor:[UIColor clearColor] andRadius:5];
    [self.googleConnection borderViewWithColor:[UIColor grayColor] andRadius:5];
    self.fbAvatar.hidden = TRUE;
    self.ggAvatar.hidden = TRUE;
    self.phone.userInteractionEnabled = NO;
    
    self.client = [[UserDataHelper shareInstance] getCurrentUser];
    lastestPhone = self.client.user.phone;
    
    //    [self.avatar setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.client.user.avatarUrl]] placeholderImage:[UIImage imageNamed:@"avatar-holder"] success:nil failure:nil];
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.client.user.avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
    
    
    self.phone.text = self.client.user.phone;
    self.name.text = [self.client.user getDisplayName];
    self.lblFullName.text = self.client.user.fullName;
    
    // update connectionview
    [self checkingConnectionWithProviders];
    
    [self showEmail];
    
    [self checkPIN];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.view endEditing:TRUE];
}

- (void) showEmail {
    if (self.client.user.email.length > 0) {
        self.email.text = self.client.user.email;
    }
    else {
        AppLog([FIRAuth auth].currentUser.uid)
        
        [self.email setText:localizedFor(@"Cập nhật")];
        self.email.textColor = [UIColor grayColor];
        if ([FIRAuth auth].currentUser.email.length > 0) {
            [self.email setText:[FIRAuth auth].currentUser.email];
            self.email.textColor = [UIColor blackColor];
        }
        else {
            for (id <FIRUserInfo> info in [FIRAuth auth].currentUser.providerData) {
                if ([info.providerID isEqual:FIRGoogleAuthProviderID]) {
                    NSString* email = info.email;
                    if (email) {
                        [[FirebaseHelper shareInstance] updateUserEmail:email complete:nil];
                        [self.email setText:email];
                        self.email.textColor = [UIColor blackColor];
                        break;
                    }
                }
            }
        }
    }
}

- (void) checkPIN {
    @weakify(self);
    [self havePIN:^(BOOL have) {
        @strongify(self);
        _havePIN = have;
        if (have) {
            self.lblTitlePIN.text = localizedFor(@"Đổi mật khẩu thanh toán");
        }
        else {
            self.lblTitlePIN.text = localizedFor(@"Tạo mật khẩu thanh toán");
        }
    }];
}

- (void) signout {
    __weak typeof(self) weakSelf = self;
    UIViewController *controller = self.tabBarController ?: self;
    [AlertVC showAlertObjcOn:controller
                       title:localizedFor(@"Thoát ứng dụng")
                     message:localizedFor(@"Bạn thực sự muốn thoát khỏi ứng dụng?")
                    actionOk:localizedFor(@"Đồng ý")
                actionCancel:localizedFor(@"Đóng")
                  callbackOK:^{
        [weakSelf logout];
    }
              callbackCancel:^{
    }];
}


- (void) logout {
    [[TicketLocalStore shared] resetDataLocalTicket];
    [[APICall shareInstance] apiSigOut];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    // fb
    [[FBSDKLoginManager new] logOut];
    
    [[GIDSignIn sharedInstance] signOut];
    
    NSError* err;
    [[FIRAuth auth] signOut:&err];
    
    AppLog(@"User had been logged out.")
    if (err) {
        AppError(err)
    }
    
    [[UserDataHelper shareInstance] clearUserData];
    if (_delegate && [_delegate respondsToSelector:@selector(profileSignOut)]) {
        [_delegate profileSignOut];
    }else {
        // load login
        AppDelegate *delegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
        @weakify(delegate);
        [self dismissViewControllerAnimated:NO completion:^{
            @strongify(delegate);
            LoggedOutWrapper *wrapper = delegate.wrapper;
            UIViewController* startview = [wrapper presentLoggedOut];
            UIViewController *rootVC = delegate.window.rootViewController;
            void(^moveToLogin)(void) = ^{
                [UIView transitionFromView:delegate.window.rootViewController.view toView:startview.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
                    if (finished) {
                        delegate.window.rootViewController = startview;
                    }
                }];
            };
            UIViewController *presentVC = [rootVC presentedViewController];
            if (presentVC) {
                [presentVC dismissViewControllerAnimated:NO completion:moveToLogin];
            } else {
                moveToLogin();
            }
        }];
    }
}

- (void) havePIN: (void (^) (BOOL can)) block {
    //    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_CHECK_TRANF_CASH
                            params:nil//@{@"id":@([[UserDataHelper shareInstance] getCurrentUser].userId)}
                          complete:^(FCResponse *response, NSError *error) {
        //                              [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK) {
            BOOL c = [(NSNumber*)response.data boolValue];
            block(c);
        }
        else {
            block(NO);
        }
    }];
}


#pragma mark - Action Handler
- (IBAction)backPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}


- (void) checkingConnectionWithProviders {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
    }
    
    
    
    [self.googleConnection setTitle:localizedFor(@"Liên kết với Google") forState:UIControlStateNormal];
    [self.fbConnection setTitle:localizedFor(@"Liên kết với Facebook") forState:UIControlStateNormal];
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([[provider providerID] isEqual:FIRGoogleAuthProviderID]) {
            [self.googleConnection setTitle:localizedFor(@"Đã liên kết với Google") forState:UIControlStateNormal];
            [self.ggAvatar sd_setImageWithURL:[provider photoURL]];
            self.ggAvatar.hidden = NO;
            self.googleConnection.userInteractionEnabled = NO;
            
            if (self.client.user.email.length == 0) {
                [[FirebaseHelper shareInstance] updateUserEmail:provider.email complete:nil];
            }
        }
        if ([[provider providerID] isEqual:FIRFacebookAuthProviderID]) {
            [self.fbConnection setTitle:localizedFor(@"Đã liên kết với Facebook") forState:UIControlStateNormal];
            [self.fbAvatar sd_setImageWithURL:[provider photoURL]];
            self.fbAvatar.hidden = NO;
            self.fbConnection.userInteractionEnabled = NO;
            
            if (self.client.user.avatarUrl.length == 0) {
                [[FirebaseHelper shareInstance] updateAvatarUrl:[provider photoURL].absoluteString];
            }
        }
    }
}

- (IBAction) googleConnectClicked:(id)sender {
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        AppLog([FIRAuth auth].currentUser.uid)
        
        // link
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential* credential = [[FirebaseHelper shareInstance] getGoogleCredential:authentication.idToken accessToken:authentication.accessToken];
        [self linkAaccount:credential toCurrUser:[FIRAuth auth].currentUser];
    }
    else {
        [[FCNotifyBannerView banner] show:nil
                                  forType:FCNotifyBannerTypeError
                                 autoHide:YES
                                  message:localizedFor(@"Xảy ra lỗi không xác thực được tài khoản Google")
                               closeClick:nil
                              bannerClick:nil];
    }
}

- (IBAction) facebookConnectClicked:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    @weakify(self);
    [login logInWithPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            
        } else if (result.isCancelled) {
            
        } else {
            AppLog([FIRAuth auth].currentUser.uid)
            
            FIRAuthCredential* credential = [[FirebaseHelper shareInstance] getfacebookCredential];
            [self linkAaccount:credential toCurrUser:[FIRAuth auth].currentUser];
        }
    }];
}

- (void) loadUpdateProfile {
    FCProfileLevel2ViewController* des = (FCProfileLevel2ViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCProfileLevel2ViewController" inStoryboard:STORYBOARD_PROFILE];
    [self.navigationController pushViewController:des animated:YES];
}

- (void) loadUpdateAvatar {
    FCPhotoPicker* vc = [[FCPhotoPicker alloc] initWithType:RSKImageCropModeCircle];
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:nav animated:NO completion:nil];
    @weakify(self);
    [RACObserve(vc, imageRes) subscribeNext:^(UIImage* image) {
        @strongify(self);
        if (image) {
            AppLog([FIRAuth auth].currentUser.uid)
            
            [self.avatar setImage:image];
            [IndicatorUtils show];
            
            NSString* path = [NSString stringWithFormat:@"profile/%@/Avatar_%ld.png", [FIRAuth auth].currentUser.uid, (long)[self getCurrentTimeStamp]];
            
            [[FirebaseHelper shareInstance] uploadImage:image withPath: path handler:^(NSURL * _Nullable url) {
                [IndicatorUtils dissmiss];
                
                DLog(@"[Upload image] : %@",url.absoluteString);
                [[FirebaseHelper shareInstance] updateAvatarUrl:url.absoluteString];
                
                [[APICall shareInstance] apiUpdateProfile:nil
                                                 nickname:nil
                                                 fullname:nil
                                                   avatar:url.absoluteString handler:^(NSError *error) {
                    if (!error) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:profileUpdatedAvatarNotification object:url.absoluteString];
                        });
                    } else {
                        
                    }
                }];
            }];
        }
    }];
}

- (IBAction)nickNameClicked:(id)sender {
    FCUpdateViewController* vc = [[FCUpdateViewController alloc] init];
    vc.type = UpdateViewTypeNickName;
    vc.currentValue = self.client.user.nickname;
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
    @weakify(self);
    [RACObserve(vc, result) subscribeNext:^(NSString* name) {
        @strongify(self);
        if (name.length > 0) {
            self.name.text = name;
            self.name.textColor = [UIColor blackColor];
            self.client.user.nickname = name;
            
            [[APICall shareInstance] apiUpdateProfile:nil
                                             nickname:name
                                             fullname:nil
                                               avatar:nil
                                              handler:nil];
        }
    }];
}

- (void) emailClicked {
    FCUpdateViewController* vc = [[FCUpdateViewController alloc] init];
    vc.type = UpdateViewTypeEmail;
    vc.currentValue = self.client.user.email;
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
    @weakify(self);
    [RACObserve(vc, result) subscribeNext:^(NSString* email) {
        @strongify(self);
        if (email.length > 0) {
            self.email.text = email;
            self.email.textColor = [UIColor blackColor];
            
            [[APICall shareInstance] apiUpdateProfile:email
                                             nickname:nil
                                             fullname:nil
                                               avatar:nil
                                              handler:nil];
        }
    }];
}

- (void) fullnameClicked {
    FCUpdateViewController* vc = [[FCUpdateViewController alloc] init];
    vc.type = UpdateViewTypeFullName;
    vc.currentValue = self.client.user.fullName;
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
    @weakify(self);
    [RACObserve(vc, result) subscribeNext:^(NSString* fullname) {
        @strongify(self);
        if (fullname.length > 0) {
            self.lblFullName.text = fullname;
            self.lblFullName.textColor = [UIColor blackColor];
            
            [[APICall shareInstance] apiUpdateProfile:nil
                                             nickname:nil
                                             fullname:fullname
                                               avatar:nil
                                              handler:nil];
        }
    }];
}

#pragma mark - Link account with google and facebook

- (void) linkAaccount: (FIRAuthCredential*) credential toCurrUser: (FIRUser*) currUser {
    [IndicatorUtils show];
    @weakify(self);
    [currUser linkAndRetrieveDataWithCredential:credential
                                     completion:^(FIRAuthDataResult* authResult, NSError* error) {
        @strongify(self);
        // link success
        if (!error) {
            [self checkingConnectionWithProviders];
            [IndicatorUtils dissmiss];
        }
        else {
            // unlink
            [self unlinkAccount:credential handler:^(NSError *error) {
                if (!error) {
                    [self linkAaccount:credential toCurrUser:currUser];
                }
                else {
                    [IndicatorUtils dissmiss];
                    
                    [[FCNotifyBannerView banner] show:nil
                                              forType:FCNotifyBannerTypeError
                                             autoHide:YES
                                              message:ERROR_CANNOT_LINK_MSG
                                           closeClick:nil
                                          bannerClick:nil];
                }
            }];
        }
    }];
}

- (void) unlinkAccount:(FIRAuthCredential*) credential handler:(void (^)(NSError * error)) completed {
    [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                             completion:^(FIRAuthDataResult* authResult, NSError* error) {
        if (!error) {
            [authResult.user unlinkFromProvider:credential.provider completion:^(FIRUser* user, NSError* error) {
                completed(error);
            }];
        }
        else {
            completed(error);
        }
    }];
}

#pragma mark - Tableview Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    return 30;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionLogout) {
        UILabel *label = (UILabel*)[cell.contentView viewWithTag:1000];
        if (label) {
            label.text = localizedFor(@"Đăng xuất");
        }
    } else {
        cell.textLabel.text = localizedFor(cell.textLabel.text);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return localizedFor(@"Mật khẩu thanh toán dùng để xác thực mỗi khi thực hiện chuyển và rút tiền");
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == kSectionInfo) {
        // avatar
        if (indexPath.row == 0) {
            //            if (self.client.user.avatarUrl.length == 0) {
            [self loadUpdateAvatar];
            //            }
        }
        // email
        else if (indexPath.row == 1) {
            //            [self fullnameClicked];
        }
        // email
        else if (indexPath.row == 3) {
            [self emailClicked];
        }
    }
    else if (indexPath.section == kSectionChangePIN) {
        if (!_havePIN) {
            [self loadCreatePINView];
        }
        else {
            [self loadChangePINView];
        }
    }
    else if (indexPath.section == kSectionLogout) {
        [self signout];
    }
}

#pragma mark - Change Phone
- (BOOL) canChangePhone {
    FIRUser* user = [FIRAuth auth].currentUser;
    if (!user) {
        AppLogCurrentUser()
        return NO;
    }
    
    for (id<FIRUserInfo> provider in user.providerData) {
        if ([[provider providerID] isEqual:FIRPhoneAuthProviderID]) {
            return YES;
            break;
        }
    }
    
    return NO;
}

- (void) changePhone {
    FCLoginViewModel* loginViewModel = [[FCLoginViewModel alloc] init];
    loginViewModel.loginType = FCLoginTypeChangePhone;
    FCPhoneInputView* phoneView = [[FCPhoneInputView alloc] intView];
    phoneView.viewController = self.navigationController;
    phoneView.loginViewModel = loginViewModel;
    [self.navigationController.view addSubview:phoneView];
    [phoneView show];
    
    [RACObserve(loginViewModel, resultCode) subscribeNext:^(NSNumber* resultcode) {
        if (resultcode) {
            NSInteger code = [resultcode integerValue];
            if (code == FCLoginResultCodeVerifySMSCodeSuccess) {
                AppLog(@"User is trying to update phone credential.")
                
                [[FIRAuth auth].currentUser updatePhoneNumberCredential:[loginViewModel getPhoneCredential]
                                                             completion:^(NSError* error) {
                    
                    DLog(@"updatePhoneNumber: %@", error);
                    
                    if (!error) {
                        [self apiVerifyChangePhone: loginViewModel.phoneNumber
                                         phoneView:phoneView];
                    }
                    else {
                        AppError(error)
                        //                                                                     [phoneView.smsCodeView showError:error];
                    }
                }];
            }
        }
    }];
}

- (void) apiVerifyChangePhone: (NSString*) phone phoneView: (FCPhoneInputView*) phoneView {
    [[APIHelper shareInstance] post:API_CHANGE_PHONE_NUMBER
                               body:@{@"phone": phone}
                           complete:^(FCResponse *response, NSError *error) {
        if (response.status == APIStatusOK) {
            [[FirebaseHelper shareInstance] updateUserPhone:phone];
            
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeSuccess
                                     autoHide:YES
                                      message:localizedFor(@"Chúc mừng bạn đã đổi số điện thoại thành công!")
                                   closeClick:nil
                                  bannerClick:nil];
            
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
        }
    }];
}

#pragma mark - Create PIN
- (void) loadCreatePINView {
    @weakify(self);
    [_verifyObjc passcodeOn:self type:VatoObjCVerifyTypeNew forgot:nil handler:^(NSString * _Nullable p, BOOL verified) {
        @strongify(self);
        [self onCreatePinSuccess];
    }];
}

- (void) onCreatePinSuccess {
    [self checkPIN];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_CREATE_PIN_COMPLETED
                                                  object:nil];
}


#pragma mark - Change PIN
- (void) loadChangePINView {
    //    @weakify(self);
    //    [_verifyObjc passcodeOn:self type:VatoObjCVerifyTypeChangePin forgot:^(NSString * _Nonnull phone) {
    //        @strongify(self);
    //        [self loadEnterScurityCode];
    //    } handler:^(NSString * _Nullable p, BOOL verified) {
    //        @strongify(self);
    //        [self onCreatePinSuccess];
    //    }];
    if (!_listViewChangePIN) {
        _listViewChangePIN = [[NSMutableArray alloc] init];
    }
    else {
        [_listViewChangePIN removeAllObjects];
    }
    //    [self loadChangePINNewView];
    changeCodeView = [[FCPassCodeView alloc] initView:self];
    [changeCodeView setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:changeCodeView];
    [_listViewChangePIN addObject:changeCodeView];
    
    // confirm new pass
    [RACObserve(changeCodeView, passcode) subscribeNext:^(NSString* oldPass) {
        if (oldPass.length > 0) {
            [changeCodeView hideKeyboard];
            [self loadCreateNewPIN:oldPass];
        }
    }];
    
    [[changeCodeView.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
}

- (void) loadCreateNewPIN: (NSString*) oldPass {
    newPassView = [[FCPassCodeView alloc] initView:self];
    [newPassView setupView:PasscodeTypeBack];
    newPassView.lblTitle.text = @"Nhập mật khẩu mới";
    [self.navigationController.view addSubview:newPassView];
    [_listViewChangePIN addObject:newPassView];
    newPassView.tag = 101;
    // confirm new pass
    [RACObserve(newPassView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length == 6) {
            [self loadConfirmPin:oldPass newPass:newPass];
        }
    }];
    
    [[newPassView.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
    
    [[newPassView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewChangePIN removeObject:newPassView];
            for (FCPassCodeView* view in _listViewChangePIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}
- (void) loadConfirmPin: (NSString*) oldPass
                newPass: (NSString*) newPass {
    FCPassCodeView* newPassViewConfirm = [[FCPassCodeView alloc] initView:self];
    //    if ([self isPhone6x]) {
    //        CGRect frameRect = newPassViewConfirm.frame;
    //        frameRect.size.height = newPassView.frame.size.height - 60;
    //        newPassViewConfirm.frame = frameRect;
    //    }
    newPassViewConfirm.tag = 100;
    [newPassViewConfirm setupView:PasscodeTypeBack];
    newPassViewConfirm.lblTitle.text = @"Xác nhận mật khẩu mới";
    [self.navigationController.view addSubview:newPassViewConfirm];
    [_listViewChangePIN addObject:newPassViewConfirm];
    
    // confirm new pass
    [RACObserve(newPassViewConfirm, passcode) subscribeNext:^(NSString* newPassConfirm) {
        if (newPassConfirm.length == 6 && newPass == newPassConfirm) {
            [self apiChangePasscode:oldPass
                                new:newPass
                              token:nil
                            handler:^(BOOL success) {
                if (success) {
                    [self clearChangePINView];
                } else {
                    [self cleanNewPass];
                }
            }];
        } else if (newPassConfirm.length == 6 && newPass != newPassConfirm) {
            //            [self showMessageBanner:@"Mật khẩu mới không khớp"
            //                             status:NO];
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:localizedFor(@"Mật khẩu mới không khớp")
                                   closeClick:nil
                                  bannerClick:nil];
            [newPassViewConfirm removeFromSuperview];
            [newPassView removePasscode];
            [newPassView showKeyboard];
        }
    }];
    
    [[newPassViewConfirm.btnFogotPass rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self loadEnterScurityCode];
            [self clearChangePINView];
        }
    }];
    
    [[newPassViewConfirm.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewChangePIN removeObject:newPassViewConfirm];
            for (FCPassCodeView* view in _listViewChangePIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (void) clearChangePINView {
    if (_listViewChangePIN.count > 0) {
        for (UIView* view in _listViewChangePIN) {
            [view removeFromSuperview];
        }
    }
}
- (void) cleanNewPass {
    if (_listViewChangePIN.count > 0) {
        for (UIView* view in _listViewChangePIN) {
            if([view isKindOfClass:[FCPassCodeView class]]){
                if(view.tag == 100 || view.tag == 101){
                    [view removeFromSuperview];
                }
            }
        }
    }
    [changeCodeView removePasscode];
    [changeCodeView showKeyboard];
}


- (void) apiChangePasscode: (NSString*) oldPass
                       new: (NSString*) newPass
                     token: (NSString*) token
                   handler: (void (^)(BOOL success)) block {
    NSDictionary* body;
    if (oldPass.length > 0) {
        body = @{@"oldPin" : oldPass,
                 @"newPin" : newPass};
    }
    else if (token.length > 0) {
        body = @{@"resetToken" : token,
                 @"newPin" : newPass};
    }
    if (!body) {
        return;
    }
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_CHANGE_PIN
                               body:body
                           complete:^(FCResponse *response, NSError *error) {
        [IndicatorUtils dissmiss];
        BOOL ok = [(NSNumber*)response.data boolValue];
        if (response.status == APIStatusOK && ok) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeSuccess
                                     autoHide:YES
                                      message:localizedFor(@"Bạn đã thay đổi mật khẩu thanh toán thành công.")
                                   closeClick:nil
                                  bannerClick:nil];
            block(TRUE);
        }
        else {
            block(NO);
        }
    }];
}

#pragma mark - Reset PIN
- (void) apiRequireResetPIN {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_RESET_PIN
                               body:nil
                           complete:^(FCResponse *response, NSError *error) {
        [IndicatorUtils dissmiss];
        
        BOOL b = [(NSNumber*) response.data boolValue];
        if (response.status == APIStatusOK && b) {
            [self callPhone:PHONE_CENTER];
            [self showScurityCodeView];
        }
        else {
            [AlertVC showAlertObjcOn:self
                               title:localizedFor(@"Thông báo")
                             message:localizedFor(@"Hiện tại chưa thực hiện được yêu cầu thay đổi mật khẩu của bạn. Vui lòng quay lại sau.")
                            actionOk:localizedFor(@"Đồng ý")
                        actionCancel:nil
                          callbackOK:^{
            }
                      callbackCancel:^{
            }];
        }
    }];
}

- (void) loadEnterScurityCode {
    __weak typeof(self) weakSelf = self;
    [AlertVC showAlertObjcOn:self
                       title:localizedFor(@"Thông báo")
                     message:localizedFor(@"Bạn cần phải nhập mã bảo mật từ hệ thống để tạo lại mật khẩu. Gọi đến tổng đài để nhận mã bảo mật ngay?")
                    actionOk:localizedFor(@"Gọi ngay")
                actionCancel:localizedFor(@"Huỷ")
                  callbackOK:^{
        [weakSelf apiRequireResetPIN];
    }
              callbackCancel:^{
    }];
}

- (void) showScurityCodeView {
    if (_listViewResetPIN) {
        [_listViewResetPIN removeAllObjects];
    }
    else {
        _listViewResetPIN = [[NSMutableArray alloc] init];
    }
    
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = localizedFor(@"Nhập mã bảo mật từ hệ thống");
    passcodeView.lblError.text = localizedFor(@"Nhập mã nhân viên tổng đài cung cấp.");
    passcodeView.lblError.hidden = NO;
    passcodeView.passcodeView.length = 8;
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* secirityCode) {
        if (secirityCode.length > 0) {
            [self loadNewPIN:secirityCode];
        }
    }];
}

- (void) loadNewPIN: (NSString*) secirityCode {
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = localizedFor(@"Nhập mật khẩu mới");
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeBack];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length > 0) {
            [self loadReEnterNewPIN:secirityCode pin:newPass];
        }
    }];
    
    [[passcodeView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewResetPIN removeObject:passcodeView];
            for (FCPassCodeView* view in _listViewResetPIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (void) loadReEnterNewPIN: (NSString*) secirityCode pin: (NSString*) newPin {
    FCPassCodeView* passcodeView = [[FCPassCodeView alloc] initView:self];
    passcodeView.lblTitle.text = localizedFor(@"Xác thực mật khẩu");
    passcodeView.btnFogotPass.hidden = YES;
    passcodeView.lblFogotPass.hidden = YES;
    [passcodeView setupView:PasscodeTypeBack];
    [self.navigationController.view addSubview:passcodeView];
    [_listViewResetPIN addObject:passcodeView];
    
    // confirm new pass
    [RACObserve(passcodeView, passcode) subscribeNext:^(NSString* newPass) {
        if (newPass.length > 0) {
            if ([newPass isEqualToString:newPin]) {
                [self apiChangePasscode:nil
                                    new:newPin
                                  token:secirityCode
                                handler:^(BOOL success) {
                    if (success) {
                        [self clearResetPINView];
                    }
                }];
                [passcodeView removeFromSuperview];
            }
            else {
                passcodeView.lblError.text = localizedFor(@"Mật khẩu mới không chính xác.");
                passcodeView.lblError.hidden = NO;
            }
        }
    }];
    
    [[passcodeView.btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [_listViewResetPIN removeObject:passcodeView];
            for (FCPassCodeView* view in _listViewResetPIN) {
                [view.textField becomeFirstResponder];
            }
        }
    }];
}

- (void) clearResetPINView {
    if (_listViewResetPIN.count > 0) {
        for (UIView* view in _listViewResetPIN) {
            [view removeFromSuperview];
        }
    }
}


@end

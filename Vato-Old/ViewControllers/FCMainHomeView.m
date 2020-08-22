//
//  FCMainHomeViewController.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCMainHomeView.h"
#import "FCMainFooterView.h"
#import "FCChoosePlaceView.h"
#import "FCConfirmBookViewController.h"
#import "FCHomeSubMenuView.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "GoogleMapsHelper.h"
#import "UserDataHelper.h"
#import "FCNewWebViewController.h"
#import "FCWalletViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCBookViewModel.h"

#define kFooterHeight 310

static NSString *const menuCellIdentifier = @"rotationCell";

@interface FCMainHomeView () <YALContextMenuTableViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet FCGGMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet FCMainFooterView *mainFooterView;
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;
@property (weak, nonatomic) IBOutlet FCLabel *lblCashInfo;
@property (weak, nonatomic) IBOutlet FCHomeSubMenuView *subMenuView;
@property (weak, nonatomic) IBOutlet UILabel *lblBtnBook;
@property (weak, nonatomic) IBOutlet UIView *btnBookView;
@property (weak, nonatomic) IBOutlet FCButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIView *giftInfoView;

// payment method
@property (weak, nonatomic) IBOutlet UIImageView *iconPaymentMethod;
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePaymentMethod;
@property (weak, nonatomic) IBOutlet UIView *paymentOptionView;
@property (weak, nonatomic) IBOutlet UIImageView *iconPaymentOptionDropdown;

@property (strong, nonatomic) FCMapViewModel* mapViewModel;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;
@end

@implementation FCMainHomeView {
    NSMutableArray *_menuTitles;
    NSMutableArray *_menuIcons;
    BOOL _allowBooking;
    BOOL _validPrice;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self show];
}

- (void) initView {
    self.mainFooterView.homeViewModel = self.homeViewModel;
    self.subMenuView.homeViewModel = self.homeViewModel;
    [self.subMenuView addItems:@[@(FCHomeSubMenuFavDriver), @(FCHomeSubMenuTaxi)]];
    [self.googleMapView moveCameraTo:[[CLLocation alloc] initWithLatitude:self.homeViewModel.bookViewModel.start.location.lat
                                                                longitude:self.homeViewModel.bookViewModel.start.location.lon]];
    
    // menu view
    [self initiateMenuOptions];
    
    
    // loading service changed
    [RACObserve(self.homeViewModel.bookViewModel, serviceSelected) subscribeNext:^(FCMCarType* x) {
        if (x) {
            self.lblBtnBook.text = [NSString stringWithFormat:@"XÁC NHẬN ĐẶT %@", [x.name uppercaseString]];
            [self updateCashInfo:x];
        }
    }];
    
    
    // enable button book
    if(self.homeViewModel.bookViewModel.end) {
        [self.progressView show];
        [RACObserve(self.homeViewModel.bookViewModel, priceDict) subscribeNext:^(NSMutableDictionary* x) {
            _validPrice = x && x.count > 0;
            [self enableButtonBook];
            if (x.count > 0) {
                [self.progressView dismiss];
            }
        }];
    }
    else {
        _validPrice = YES;
        [self enableButtonBook];
    }
    
    // loading for waitting service
    [self.progressView show];
    [RACObserve(self.homeViewModel, listProduct) subscribeNext:^(NSMutableArray* x) {
        if (x.count > 0) {
            [self.progressView dismiss];
        }
    }];
    
    // payment method
    [RACObserve(self.homeViewModel.client, paymentMethod) subscribeNext:^(NSNumber* x) {
        PaymentMethod paymentMethod = [x integerValue];
        [self updatePaymentMethodView:paymentMethod];
    }];
    
    // notify center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hide)
                                                 name:NOTIFICATION_COMPLETE_BOOKING
                                               object:nil];
    
    // payment option view
    [self setupPaymentOptionView];
}

- (void) updateCashInfo: (FCMCarType*) cartype {
    FCFareModifier* fareModifier = [self.homeViewModel.bookViewModel getMofdifierForService:cartype.id];
    if (fareModifier && fareModifier.additionRatio > 0) {
        self.giftInfoView.hidden = NO;
        self.lblCashInfo.hidden = NO;
        FCClientConfig* message = [self getMessagePriceIncrease];
        if (message) {
            self.lblCashInfo.text = [NSString stringWithFormat:[message.name stringByReplacingOccurrencesOfString:@"%" withString:@"%ld%%"], (long)(fareModifier.additionRatio*100)];
        }
        else {
            self.lblCashInfo.text = [NSString stringWithFormat:@"Đang tăng giá %ld%%", (long)(fareModifier.additionRatio*100)];
        }
        
        self.lblCashInfo.backgroundColor = [UIColor clearColor];
        self.lblCashInfo.textColor = [UIColor blackColor];
    }
    else {
        self.giftInfoView.hidden = YES;
        self.lblCashInfo.hidden = YES;
    }
}

- (FCClientConfig*) getMessagePriceIncrease {
    NSArray* configs = [FirebaseHelper shareInstance].appConfigure.client_config;
    for (FCClientConfig* c in configs) {
        if (c.type == ClientConfigTypeIncreasePriceMessage && c.active) {
            return c;
        }
    }
    return nil;
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
    
    [self initView];
    [self configMaps];
    
}

- (void) show {
    [self setAlpha:0.0f];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         [self layoutSubviews];
                     }];
}

- (void) hide {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_RESUME_APP
                                                  object:nil];
    self.hideView = YES;
    
    [self animationHide:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) enableButtonBook {
    BOOL allow = _validPrice  && _allowBooking;
    self.btnBookView.userInteractionEnabled = allow;
    if (allow) {
        self.btnBookView.backgroundColor = [UIColor orangeColor];
    }
    else {
        self.btnBookView.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Payment Option View
- (void) setupPaymentOptionView {
    FCClientConfig* config = [self getPaymentOptionConfig];
    if (!config) {
        [self.homeViewModel updatePaymentMethod: PaymentMethodCash];
    }
    
    self.iconPaymentOptionDropdown.hidden = !config;
    self.paymentOptionView.userInteractionEnabled = config != nil;
}

- (FCClientConfig*) getPaymentOptionConfig {
    for (FCClientConfig* config in [FirebaseHelper shareInstance].appConfigure.client_config) {
        if (config.type == ClientConfigTypePaymentOption && config.active) {
            return config;
        }
    }
    return nil;
}

- (void) updatePaymentMethodView: (PaymentMethod) paymentMethod {
    if (paymentMethod == PaymentMethodCash) {
        self.iconPaymentMethod.image = [UIImage imageNamed:@"cash"];
        self.lblTitlePaymentMethod.text = @"Thanh toán bằng Tiền mặt";
    }
    else if (paymentMethod == PaymentMethodVATOPay) {
        self.iconPaymentMethod.image = [UIImage imageNamed:@"wallet"];
        self.lblTitlePaymentMethod.text = @"Thanh toán bằng VATOPay";
    }
}

#pragma mark - Checking Balance for VATO Pay
- (void) checkBalance {
    [self.progressView show];
    self.mainFooterView.userInteractionEnabled = NO;
    [self.homeViewModel checkOverBalance:^(BOOL enoughMoney) {
        [self.progressView dismiss];
        self.mainFooterView.userInteractionEnabled = YES;
        if (enoughMoney) {
            [self.homeViewModel loadConfirmBookingView];
        }
        else {
            [self confirmTopupToWallet:^(PaymentMethod method) {
                if (method == PaymentMethodCash) {
                    [self.homeViewModel loadConfirmBookingView];
                }
                else {
                    [self checkBalance];
                }
            }];
        }
    }];
}

- (FCLinkConfigure*) getLinkTopup {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.type == LinkConfigureTypeTopup && link.active) {
            return link;
        }
    }
    
    return nil;
}

- (BOOL) canTopupToWallet {
    return [self getLinkTopup] != nil;
}

- (void) confirmTopupToWallet:(void (^) (PaymentMethod)) completed {
    if ([self canTopupToWallet]) {
        [UIAlertController showAlertInViewController:self.viewController
                                           withTitle:@"Số dư trong VATOPay không đủ"
                                             message:@"Số tiền còn lại trong VATOPay không đủ để thanh toán cho chuyến đi này."
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"Nạp tiền ngay ", @"Thanh toán tiền mặt"]
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                if (buttonIndex == 3) {
                                                    [self.homeViewModel updatePaymentMethod: PaymentMethodCash];
                                                    completed(PaymentMethodCash);
                                                }
                                                else if (buttonIndex == 2) {
                                                    [self showWalletView];
                                                }
                                            }];
    }
    else {
        [UIAlertController showAlertInViewController:self.viewController
                                           withTitle:@"Số dư trong VATOPay không đủ"
                                             message:@"Tài khoản của bạn không đủ số dư để sử dụng dịch vụ. Bạn vui lòng sử dụng tiền mặt để tiếp tục."
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"Đồng ý"
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                [self.homeViewModel updatePaymentMethod: PaymentMethodCash];
                                                completed(PaymentMethodCash);
                                            }];
    }
}

- (void) showWalletView {
//    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
//        FCLinkConfigure* link = [self getLinkTopup];
//        NSString* newUrl = [NSString stringWithFormat:@"%@?deviceId=%@&accessToken=%@",link.url, [self getDeviceId], token];
//        FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
//        [self.viewController presentViewController:vc
//                           animated:YES
//                         completion:^{
//                             [vc loadWebview:newUrl];
//                         }];
//    }];
    
    FCWalletViewController* vc = [[FCWalletViewController alloc] initView:self.homeViewModel];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self.viewController presentViewController:navController animated:YES completion:^{
        
    }];
}


#pragma mark - Maps
- (void) configMaps {
    self.googleMapView.myLocationEnabled = NO;
    
    // location button
    [self.googleMapView setBtnLocationPosition:CGPointMake([UIScreen mainScreen].bounds.size.width - 1.5*kBtnLocationSize, self.frame.size.height - self.footerView.frame.size.height - 1.5*kBtnLocationSize)];
    [self.googleMapView addLocationButton:self.btnLocation];

    // move map to start
    self.mapViewModel = [[FCMapViewModel alloc] init:self.googleMapView];
    self.mapViewModel.homeViewModel = self.homeViewModel;
    [self reloadMaps];
    
    [RACObserve(self.mapViewModel, router) subscribeNext:^(FCRouter* x) {
        self.homeViewModel.bookViewModel.distance = x.distance;
        self.homeViewModel.bookViewModel.duration = x.duration;
        
        [self checkingAllowBooking:x.distance];
        
        [self.homeViewModel.bookViewModel getPrices];
        [self.homeViewModel.bookViewModel setPolyline:x.polylineEncode];
    }];
}

- (void) checkingAllowBooking: (NSInteger) estimateDistance {
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure * appconfigure) {
        _allowBooking = appconfigure.booking_configure.distance_allow == 0 || // ko co config
        (estimateDistance/1000) < appconfigure.booking_configure.distance_allow;
        [self enableButtonBook];
        if (!_allowBooking) {
            [[FCNotifyBannerView banner] show:self
                                      forType:FCNotifyBannerTypeError
                                     autoHide:NO
                                      message:appconfigure.booking_configure.message
                                   closeClick:nil
                                  bannerClick:nil];
            
        }
    }];
}

- (void) reloadMaps {
    FCPlace* start = self.homeViewModel.bookViewModel.start;
    FCPlace* end = self.homeViewModel.bookViewModel.end;
    [self addMarkerStart: start];
    [self addMarkerEnd: end];
    
    if (!end) {
        [self.googleMapView moveCameraTo:[[CLLocation alloc] initWithLatitude:start.location.lat
                                                                    longitude:start.location.lon]];
    }
}


- (void) addMarkerStart: (FCPlace*) start {
    GMSMarker* marker = [self.mapViewModel addStartMarker:start];
    [(FCMapMarker*) marker.iconView setMarkerStyle:FCMarkerStyleStartInBook];
    
    __weak FCMainHomeView* weakself = self;
    [self.mapViewModel setStartMarkerClickedCallback:^(void) {
        [weakself loadSearchPlaceView: FCPlaceSearchTypeEditStart];
    }];
}

- (void) addMarkerEnd: (FCPlace*) end {
    if (end) {
        GMSMarker* marker = [self.mapViewModel addEndMarker:end];
        FCMapMarker* icView = (FCMapMarker*) marker.iconView;
        [icView setMarkerStyle:FCMarkerStyleEndInBook];
        [icView.lblEndInbook setText:end.name];
        
        __weak FCMainHomeView* weakself = self;
        [self.mapViewModel setEndMarkerClickedCallback:^(void) {
            [weakself loadSearchPlaceView: FCPlaceSearchTypeEditEnd];
        }];
    }
}

- (void) loadSearchPlaceView: (FCPlaceSearchType) type {
    [self.homeViewModel loadSearchPlaceView:type
                                     inView:self
                                      block:^(BOOL cancelView, BOOL completedView) {
                                          if (completedView) {
                                              [self reloadMaps];
                                          }
                                      }];
}

#pragma mark - Action Handler
- (IBAction)backClicked:(id)sender {
    [self hide];
}

- (IBAction)confirmBookClicked:(id)sender {
    if (self.homeViewModel.bookViewModel.serviceSelected.id == 12) {
        [self.homeViewModel loadConfirmShipInfoView];
    }
    else if (self.homeViewModel.bookViewModel.paymentMethod == PaymentMethodVATOPay) {
        [self checkBalance];
    }
    else {
        [self.homeViewModel loadConfirmBookingView];
    }
}

- (IBAction)menuClicked:(id)sender {
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.1f;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromBottomToTop;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self
                           withEdgeInsets:UIEdgeInsetsMake(0, 0, -kFooterHeight, 0)
                                 animated:YES];
}

- (void) animationShow:(void (^) (BOOL)) block {
    NSInteger footerHeight = kFooterHeight;
    
    // footer
    CGRect footerFrame = self.footerView.frame;
    footerFrame.origin.y += footerHeight;
    self.footerView.frame = footerFrame;
    
    
    // maps
    CGRect mapFrame = self.googleMapView.frame;
    mapFrame.size.height += footerHeight;
    self.googleMapView.frame = mapFrame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGRect newFooterFrame = self.footerView.frame;
                         newFooterFrame.origin.y -= footerHeight;
                         self.footerView.frame = newFooterFrame;
                         
                         CGRect newMapFrame = self.googleMapView.frame;
                         newMapFrame.size.height -= footerHeight;
                         self.googleMapView.frame = newMapFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         if (block) {
                             block(finished);
                         }
                     }];
}

- (IBAction)cashClicked:(id)sender {
//    if (self.homeViewModel.countGift == 0) {
//        return;
//    }
//    
//    [self.homeViewModel loadListPromotionView:NO];
}

- (IBAction)paymentMethodClicked:(id)sender {
    [self.homeViewModel loadPaymentMethodOptionView];
}


- (void) animationHide:(void (^) (BOOL)) block {
    NSInteger footerHeight = kFooterHeight;
    
    // maps
    CGRect mapFrame = self.googleMapView.frame;
    mapFrame.size.height += footerHeight;
    self.googleMapView.frame = mapFrame;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0f;
                         
                         // footer
                         CGRect footerFrame = self.footerView.frame;
                         footerFrame.origin.y += footerHeight;
                         self.footerView.frame = footerFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         if (block) {
                             block(finished);
                         }
                     }];
}

- (void) favoriteDriverClicked {
    BOOL fav = self.homeViewModel.bookViewModel.favDriver;
    fav = !fav;
    self.homeViewModel.bookViewModel.favDriver = fav;
    
    
    // update layout
    if (!fav) {
        [_menuTitles replaceObjectAtIndex:1 withObject: @"Lái xe riêng của bạn"];
        [_menuIcons replaceObjectAtIndex:1 withObject: [UIImage imageNamed:@"fav-driver"]];
    }
    else {
        [_menuTitles replaceObjectAtIndex:1 withObject:@"Tất cả lái xe"];
        [_menuIcons replaceObjectAtIndex:1 withObject: [UIImage imageNamed:@"fav-driver-b"]];
    }
}

- (void) taxiClicked {
    CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [self.homeViewModel loadListTaxiView:center];
}

#pragma mark - Menus
#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)initiateMenuOptions {
    _menuTitles = [[NSMutableArray alloc] initWithArray:@[@"",
//                        @"Hãng Taxi",
                        @"Lái xe riêng của bạn"]];
    
    _menuIcons = [[NSMutableArray alloc] initWithArray:@[[UIImage imageNamed:@"close-g"],
//                       [UIImage imageNamed:@"taxi"],
                       [UIImage imageNamed:@"fav-driver"]]];
}


- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
    
//    if (indexPath.row == 1) {
//        [self taxiClicked];
//    }
//    else
    if (indexPath.row == 1) {
        [self favoriteDriverClicked];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [_menuTitles objectAtIndex:indexPath.row];
        cell.menuImageView.image = [_menuIcons objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end

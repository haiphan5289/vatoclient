//
//  FCTripInfoView.m
//  FaceCar
//
//  Created by facecar on 12/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripInfoView.h"
#import "CXSwipeGestureRecognizer.h"
#import "UserDataHelper.h"
#import "TripMapsViewController.h"
#import "FCEvaluteView.h"
#import "FCBookingService.h"

#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

@interface FCBookInfo () <CXSwipeGestureRecognizerDelegate>

@end

@implementation FCTripInfoView {
    UIAlertController* _popupView;
    NSInteger _requestIndex;
    AlertVC *alertConfirmCancelTrip;
    AlertVC *alertNewTrip;
}

- (id) initTripShowType:(TripShowType) type {
    self = [super init];
    if (self) {
        if (type == TripShowTypeTaxi) {
            self =   [[[NSBundle mainBundle] loadNibNamed:@"FCTripInfoViewTaxi"
                                                    owner:self
                                                  options:nil] firstObject];
        } else if (type == TripShowTypeExpress) {
            self =   [[[NSBundle mainBundle] loadNibNamed:@"FCTripInfoViewExpress"
                                                    owner:self
                                                  options:nil] firstObject];
        } else {
            self =   [[[NSBundle mainBundle] loadNibNamed:@"FCTripInfoView"
                                                    owner:self
                                                  options:nil] firstObject];
        }
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.imgDriverAvatar circleView:ORANGE_COLOR];
    
    [self.imgDriverAvatar setContentMode:UIViewContentModeScaleAspectFill];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    [self layoutIfNeeded];
    [self layoutSubviews];


    [_btnCancel setTitle:localizedFor(@"Huỷ chuyến") forState:UIControlStateNormal];
    [_btnNewBook setTitle:localizedFor(@"Chuyến mới") forState:UIControlStateNormal];
    _lblYourTrip.text = localizedFor(@"Lộ trình của bạn");
    _lblNoteForDriver.text = localizedFor(@"Lưu ý cho lái xe");
    _lblTitlePriceStatus.text = localizedFor(@"Thanh toán");
    _feeServiceText.text = localizedFor(@"Phí Dịch Vụ");
    
    [self.btnPhone setTitle:localizedFor(@"Gọi tài xế") forState:(UIControlStateNormal)];
    [self.btnChat setTitle:localizedFor(@"Nhắn tin") forState:(UIControlStateNormal)];
}

- (void) hideCancelButton {
    self.btnCancel.hidden = YES;
}

- (void) isShowNewTripButton:(BOOL)isShow {
    self.btnNewBook.hidden = !isShow;
}

- (void) initForRequestBooking {
    self.lblCarName.hidden = YES;
    self.btnPhone.hidden = YES;
    self.btnNewBook.hidden = YES;
    self.btnChat.hidden = YES;
    self.lblDriverName.hidden = YES;
    self.lblRequestConnecting.hidden = NO;
    self.consDriverInfoHeight.constant = 100;
    self.progressRequestView.hidden = NO;
    self.currentType = FCTripInfoViewTypeBookingRequest;
    [self layoutIfNeeded];
    [self layoutSubviews];
    [self.btnCancel setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(enableCancel) userInfo:nil repeats:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dismissButton.hidden = self.frame.origin.y;
    self.dockView.hidden = !self.dismissButton.hidden;
    
}

- (void) enableCancel {
    [self.btnCancel setEnabled:TRUE];
}

- (void) loadRequestView:(FCBooking *)book {
    [self.progressRequestView dismiss];
    [self setBookData:book];
    [self startProgressForRequest];
}

- (void) startProgressForRequest {
//    [self.progressRequestView setProgress:0];
//    self.progressRequestView.hidden = NO;
//    [UIView animateWithDuration:28.0f
//                     animations:^{
//                         [self.progressRequestView layoutIfNeeded];
//                     }
//                     completion:^(BOOL finished){
//                         if (finished) NSLog(@"animation finished");
//                         [self.progressRequestView setProgress:1];
//                         self.progressRequestView.hidden = YES;
//                     }];
    [self.progressRequestView show];
}

- (void) setBookData:(FCBooking*) book {
    
    _bookData = book;
//    [self.imgDriverAvatar circleView:ORANGE_COLOR];
    @weakify(self);
    [[FirebaseHelper shareInstance] getDriver:book.info.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          @strongify(self);
                                          if (self.currentType == FCTripInfoViewTypeBookingRequest) {
//                                              [self.lblRequestConnecting setText:[NSString stringWithFormat:@"Đang liên hệ với lái xe '%@'", driver.user.fullName]];
                                              [self showDriverInfoRequestBooking:driver];
                                          }
                                          else {
                                              [self.imgDriverAvatar setImageWithUrl:driver.user.avatarUrl];
                                              [self.lblDriverName setText:driver.user.fullName];
                                          }
                                          
                                          [self.lblCarName setText:[NSString stringWithFormat:@"%@・%@", driver.vehicle.marketName, driver.vehicle.plate]];
                                      }];
    
    [self.lblStart setText:book.info.startName];
    self.senderName.text = book.info.senderName;
    self.receiverName.text = self.lblDurationInfo.text = [NSString stringWithFormat:@"%@・%0.1fkm",book.info.receiverName, book.info.distance/1000.0f];
    
    if (book.info.tripType == BookTypeOneTouch) {
        self.lblEnd.text = localizedFor(@"Điểm đến theo yêu cầu của bạn");
        self.lblEnd.textColor = [UIColor grayColor];
        self.lblPrice.text = localizedFor(@"Tính theo lộ trình thực tế");
        self.lblPrice.textColor = [UIColor blackColor];
    }
    else {
        self.lblEnd.text = book.info.endName;
    }
    
    [self loadPriceInfo:book
              bookModel:nil];
}

- (void) showDriverInfoRequestBooking: (FCDriver*) driver {
    if (_requestIndex == 0) {
        [self.lblRequestConnecting setText:localizedFor(@"Đang tìm lái xe tốt nhất cho bạn ...")];
    }
    else {
        NSArray* names = [driver.user.fullName componentsSeparatedByString:@" "];
        NSString* firstName = driver.user.fullName;
        if (names.count > 0) {
            firstName = [names objectAtIndex:names.count-1];
        }
        
        UIColor *color = [UIColor blackColor];
        if (_requestIndex%4 == 1) {
            color = UIColorFromRGB(0x417505);
        }
        else if (_requestIndex%4 == 2) {
            color = UIColorFromRGB(0xF5A623);
        }
        else if (_requestIndex%4 == 3) {
            color = UIColorFromRGB(0xD0021B);
        }

        NSString *string = [NSString stringWithFormat:@"%@... (%@)", localizedFor(@"Đang liên hệ với lái xe"), firstName];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange range = [string rangeOfString:firstName];
        [text addAttribute:NSForegroundColorAttributeName
                     value:color
                     range:range];
        
        [text addAttribute:NSFontAttributeName
                     value:[UIFont boldSystemFontOfSize:15]
                     range:range];
        self.lblRequestConnecting.attributedText = text;
    }
    
    [self.imgDriverAvatar setImage:[UIImage imageNamed:@"splashscreen_logo_vato"]];
    _requestIndex ++;
}

- (NSInteger) loadInvoiceInfo: (FCBooking*) book
                    bookModel: (FCBookViewModel*) bookViewModel {
    
    // dismiss view listener
    __weak FCTripInfoView* weakself = self;
    [self setInteractionListener:^(BOOL isHide, BOOL isShow) {
        if (isHide) {
            [weakself closeInfoClicked:nil];
        }
    }];
    
    self.lblDurationInfo.hidden = NO;
    
    self.lblDurationInfo.text = [NSString stringWithFormat:@"%0.1fkm - %d phút", book.info.distance/1000.0f, book.info.duration/60];
    if (book.info.endName > 0) {
        self.lblEnd.textColor = [UIColor blackColor];
        self.lblEnd.text = book.info.endName;
    }
    else {
        self.lblEnd.textColor = [UIColor grayColor];
        self.lblEnd.text = localizedFor(@"Chưa xác định");
    }
    
    [self loadPriceInfo:book
              bookModel:bookViewModel];
    
    return FCTripInfoViewTypeInvoice;
}

- (void) loadPriceInfo: (FCBooking*) book
             bookModel: (FCBookViewModel*) bookViewModel {
    
    NSInteger bookPrice = [book.info getBookPrice];
    NSInteger promoVal = book.info.fareClientSupport + book.info.promotionValue;
    
    
    // price pay
    if (bookPrice > 0) {
        NSInteger clientPay = MAX (bookPrice + book.info.additionPrice - promoVal, 0);
        
        // fee service
        CGFloat feeService = [[FireStoreConfigDataManager shared] getPercentFeeWithPaymentMethod:book.info.payment];
        long feeServiceValue = (feeService * clientPay)/100;
        _feeServiceValue.text =  [self formatPrice:feeServiceValue];
        
    
        self.lblTitlePriceStatus.text = localizedFor(@"Thanh toán");
        self.lblPrice.textColor = [UIColor blackColor];
        self.lblPrice.text = [self formatPrice:(clientPay + feeServiceValue)];
    }
    if (book.info.payment == PaymentMethodCash) {
        [self.paymentLabel setTitle: [localizedFor(@"Tiền mặt") uppercaseString] forState:(UIControlStateNormal)];
        [self.paymentLabel setBackgroundColor:[UIColor colorWithRed:99/255.f green:114/255.f blue:128/255.f alpha:1.f]];
    } else if (book.info.payment == PaymentMethodVATOPay) {
        [self.paymentLabel setTitle: [localizedFor(@"VATOPAY") uppercaseString] forState:(UIControlStateNormal)];
        [self.paymentLabel setBackgroundColor:[UIColor colorWithRed:239/255.f green:82/255.f blue:34/255.f alpha:1.f]];
    } else {
        [self.paymentLabel setTitle: [localizedFor(@"Thẻ") uppercaseString] forState:(UIControlStateNormal)];
        [self.paymentLabel setBackgroundColor:[UIColor colorWithRed:239/255.f green:82/255.f blue:34/255.f alpha:1.f]];
    }
    [self.taxiBrandLabel setTitle:book.info.taxiBrandName.uppercaseString forState:(UIControlStateNormal)];

    // note
    self.lblNote.text = book.info.note;
    self.hightViewNoteConstraint.constant = (book.info.note.length == 0) ? 0 : 78;
}

#pragma mark - Chat handler
- (void) showChatBadge: (NSInteger) badge {
    if (badge > 0) {
        [self.btnChat setImage:[UIImage imageNamed:@"iconBookingMessage"] forState:(UIControlStateNormal)];
    } else {
        [self.btnChat setImage:[UIImage imageNamed:@"iconBookingNoMessage"] forState:(UIControlStateNormal)];
    }
}

- (void) hideAnyPopup:(void (^)(void))complete {
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    if (alertConfirmCancelTrip != nil) {
        dispatch_group_enter(serviceGroup);
        [alertConfirmCancelTrip hideAlertWithAnimation:true complete:^{
            alertConfirmCancelTrip = nil;
            dispatch_group_leave(serviceGroup);
        }];
    }
    if (alertNewTrip != nil) {
        dispatch_group_enter(serviceGroup);
        [alertNewTrip hideAlertWithAnimation:true complete:^{
            alertNewTrip = nil;
            dispatch_group_leave(serviceGroup);
        }];
    }
    if (_popupView) {
        dispatch_group_enter(serviceGroup);
        [_popupView dismissViewControllerAnimated:YES
                                       completion: ^{
             _popupView = nil;
             dispatch_group_leave(serviceGroup);
         }];
    }
    
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        if (complete) {
            complete ();
        }
    });
}

#pragma mark - Action handler
- (IBAction)contactClicked:(id)sender {
    @weakify(self);
    [[FirebaseHelper shareInstance] getDriver:_bookData.info.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          @strongify(self);
                                         [self callPhone:driver.user.phone];
                                      }];
}

- (IBAction)onChatClicked:(id)sender {
    [(TripMapsViewController*)self.viewController showChatView];
}

- (IBAction)didtouchDismiss:(id)sender {
    FCBookingService *_bookingService = [FCBookingService shareInstance];
    if (![_bookingService isFinishedTrip]) {
        CGRect frame = self.frame;
        frame.origin.y = [[UIScreen mainScreen] bounds].size.height - kFooterHeight;
        [self setTargetFrame:frame];
        [self setTargetAlpha:0.0f];
    }
    else {
        [self showRatingView];
    }
}

// cancel book
- (IBAction)cancelClicked:(id)sender {
    __weak typeof(self) weakSelf = self;
    
    ReasonCancelVC *vc = [[ReasonCancelVC alloc] init];
    [vc setDidSelectConfirm:^(NSDictionary<NSString *,id> *result) {
        if (![self isNetworkAvailable]) {
            [AlertVC presentNetworkDownFor:self.viewController];
            return;
        }
        [[UserDataHelper shareInstance] removeLastestTripbook];
        NSLog(@"%@", result);
        if (weakSelf.currentType == FCTripInfoViewTypeBookingRequest) {
            [[FCBookingService shareInstance] updateBookReasonCancel:result];
            [[FCBookingService shareInstance] updateLastestBookingInfo:self.bookData];
            [[FCBookingService shareInstance] updateBookStatus:BookStatusClientCancelInBook];
            [weakSelf.delegate onBookCanceled];
        }
        else {
            [[FCBookingService shareInstance] updateBookReasonCancel:result];
            [[FCBookingService shareInstance] updateLastestBookingInfo:self.bookData];
            [[FCBookingService shareInstance] updateBookStatus:BookStatusClientCancelIntrip];
            [(TripMapsViewController*)weakSelf.viewController dismissChat];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CANCEL_BOOKING
                                                                object:nil];
            
            // notify
            if ([weakSelf.delegate respondsToSelector:@selector(onBookCanceled)]) {
                [weakSelf.delegate onBookCanceled];
            }
            
            TripMapsViewController *vc = (TripMapsViewController*)weakSelf.viewController;
            if (vc.fromDelivery) {
                [weakSelf.viewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [weakSelf dismissTripView];
            }
        }

    }];
    
    [self.viewController presentViewController:vc animated:YES completion:nil];
}


- (IBAction)newTripClicked:(id)sender {
    __weak typeof(self) weakSelf = self;
    alertNewTrip = [AlertVC showAlertObjcOn:self.viewController
                       title:localizedFor(@"Đặt chuyến xe mới")
                     message:localizedFor(@"Chuyến đi hiện tại sẽ được lưu vào mục Lịch sử chuyến đi. Tiếp tục đặt chuyến mới?")
                    actionOk:localizedFor(@"Đồng ý")
                actionCancel:localizedFor(@"Bỏ qua")
                  callbackOK:^{
                      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_BOOKING
                                                                          object:nil];
                      
                      [(TripMapsViewController*)weakSelf.viewController dismissChat];
                      [weakSelf dismissTripView];
                      
                      // delegate
                      if ([weakSelf.delegate respondsToSelector:@selector(newTrip)]) {
                          [weakSelf.delegate newTrip];
                      }
                      alertNewTrip = nil;
                  }
              callbackCancel:^{
                  alertNewTrip = nil;
              }];
}

- (IBAction)blockClicked:(id)sender {
    @weakify(self);
    
    [[APIHelper shareInstance] post:API_ADD_TO_BLACK_LIST
                               body:@{@"userId":@(_bookData.info.driverUserId)}
                           complete:^(FCResponse *response, NSError *error) {
                               @strongify(self);
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self blockDriver];
                               }
                           }];
    
    [self showRatingView];
}

- (void) blockDriver {
    [[FirebaseHelper shareInstance] getDriver:_bookData.info.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          FCFavorite* fav = [[FCFavorite alloc] init];
                                          fav.userId = _bookData.info.driverUserId;
                                          fav.isFavorite = NO;
                                          fav.userFirebaseId = _bookData.info.driverFirebaseId;
                                          fav.userName = driver.user.fullName;
                                          fav.userAvatar = driver.user.avatarUrl;
                                          fav.userPhone = driver.user.phone;
                                          
                                          [[FirebaseHelper shareInstance] requestAddFavorite:fav
                                                                         withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
                                                                             [[FCNotifyBannerView banner] show:nil
                                                                                                        forType:FCNotifyBannerTypeSuccess
                                                                                                      autoHide:YES
                                                                                                       message:[NSString stringWithFormat:localizedFor(@"Đã thêm '%@' vào danh sách Danh sách chặn của bạn."), driver.user.fullName]
                                                                                                    closeClick:nil
                                                                                                   bannerClick:nil];
                                                                         }];
                                      }];
    
}

- (IBAction)closeInfoClicked:(id)sender {
    [self showRatingView];
}

- (void) showRatingView {
    FCEvaluteView* ratingView = [[FCEvaluteView alloc] init];
    ratingView.booking = _bookData;
    [ratingView reloadData];
    [((UIViewController*)self.viewController).view addSubview:ratingView];
    [ratingView show];
    
    __weak typeof(self) weakSelf = self;
    [ratingView setActionCallback:^(NSInteger index) { // 0: cancel, 1: done
        if (index == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_BOOKING
                                                                object:nil];
            [weakSelf dismissTripView];
            /*
            [AlertVC showAlertObjcOn:weakSelf.viewController
                               title:localizedFor(@"Thông báo")
                             message:localizedFor(@"Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi. Xin cảm ơn!")
                            actionOk:localizedFor(@"Quay về màn hình chính")
                        actionCancel:nil
                          callbackOK:^{
                              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_BOOKING
                                                                                  object:nil];
                              [weakSelf dismissTripView];
                          }
                      callbackCancel:^{
                      }];
             */
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_BOOKING
                                                                object:nil];
            [weakSelf dismissTripView];
        }
        
    }];
}

- (void) dismissTripView {
    [[UserDataHelper shareInstance] removeLastestTripbook];
    if ([self.delegate respondsToSelector:@selector(onBookCanceled)]) {
        [self.delegate didCompleteTrip];
    }
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

- (void)dealloc {
    
}

- (void)changeMethodToHardCash {
}

- (void)updateStatus {
    FCBookingService *_bookingService = [FCBookingService shareInstance];
    self.lblRequestConnecting.text = [_bookingService getStatusStr];
    self.subTextStatus.text = [_bookingService getSubStatusStr];
}
@end

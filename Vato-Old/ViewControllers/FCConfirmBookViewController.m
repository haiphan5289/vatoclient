//
//  FCConfirmBookViewController.m
//  FaceCar
//
//  Created by facecar on 12/9/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCConfirmBookViewController.h"
#import "JVFloatLabeledTextField.h"
#import "UILabel+Helper.h"
#import <VeeContactPicker/VeeContactPickerViewController.h>
#import <VeeContactPicker/VeeContactPickerOptions.h>
#import "FCFareService.h"
#import "FCBookViewModel.h"

typedef enum : NSUInteger {
    CFSectionTitle = 0,
    CFSectionPhone = 1,
    CFSectionPrice = 2,
    CFSectionTip = 3,
    CFSectionRoute = 4,
    CFSectionAction = 5
} CFSection;

@interface FCConfirmBookViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfPrice;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfTip;
@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UIView *endInfoView;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTip;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceError;
@property (weak, nonatomic) IBOutlet UILabel *lblOldPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnAgree;

@property (weak, nonatomic) IBOutlet UIView *priceOptionView;
@property (weak, nonatomic) IBOutlet FCLabel *lblPriceOptionOne;
@property (weak, nonatomic) IBOutlet FCLabel *lblPriceOptionTwo;
@property (weak, nonatomic) IBOutlet FCLabel *lblPriceOptionThree;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPriceOptionHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consPriceAdditionalY;
@property (weak, nonatomic) IBOutlet UILabel *lblMessageInPeakHours;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneErrorMessage;

@property (strong, nonatomic) VeeContactPickerViewController *contactPickerViewController;
@end

@implementation FCConfirmBookViewController {
    FCBookInfo* _booking;
    NSInteger _priceAddition1Temp;
    NSInteger _priceAddition1;
    NSInteger _priceAddition2;
    NSInteger _priceAddition3;
    BOOL _firstTimeChangePrice;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _booking = [self.homeViewModel.bookViewModel crateBookingData];
    _firstTimeChangePrice = YES;
    self.tfPhoneNumber.delegate = self;
    
    // get fare modifier
    FCFareModifier* fareModifier = [self.homeViewModel.bookViewModel getMofdifierForService:_booking.serviceId];
    [self loadData:fareModifier];
    
    [self bindingContactPhone];
    
    __block RACDisposable* handler = [RACObserve(self.homeViewModel.bookViewModel, stationEvent) subscribeNext:^(FCGift* x) {
        if (x) {
            [self loadStationTip: x];
            [handler dispose];
        }
    }];
    
    RAC(self.btnAgree, enabled) = [RACSignal combineLatest:@[RACObserve(self.lblPriceError, hidden)]
                                                    reduce:^(NSNumber* error){
                                                        return @([error boolValue]);
                                                    }];
    
    [self setupPriceAdditional];
    [self checkAllowChangePrice: [_booking getBookPrice]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) setupPriceAdditional {
    
    // only show if fixed trip
    [self showPriceAdditional:_booking.tripType == BookTypeFixed];
    
    // check to show message in peak hours
    if ([[FirebaseHelper shareInstance] isInPeakHours]) {
        NSString* message = [FirebaseHelper shareInstance].appConfigure.booking_configure.message_in_peak_hours;
        if (message.length > 0) {
            self.consPriceAdditionalY.constant = -15.0f;
            self.lblMessageInPeakHours.text = message;
        }
    }
    
    // check price additional configure
    [[FirebaseHelper shareInstance] getPriceAdditional:^(NSMutableArray* list) {
        if (list.count > 0) {
            @try {
                _priceAddition1 = ((FCPriceAddition*)[list objectAtIndex:0]).price;
                _priceAddition2 = ((FCPriceAddition*)[list objectAtIndex:1]).price;
                _priceAddition3 = ((FCPriceAddition*)[list objectAtIndex:2]).price;
            }
            @catch (NSException* e) {
            }
        }
        
        [self showPriceAdditional:list.count > 0];
    }];
}

- (void) showPriceAdditional: (BOOL) show {
    if (show) {
        if (_firstTimeChangePrice && _priceAddition1 > 0) {
            _firstTimeChangePrice = FALSE;
            NSInteger bookPrice = [_booking getBookPrice];
            NSInteger clientPay = MAX(bookPrice + _booking.additionPrice - _booking.fareClientSupport, 0);
            NSInteger amount = clientPay % _priceAddition1;
            if (amount == 0) {
                _priceAddition1Temp = _priceAddition1;
                [self.lblPriceOptionOne setText:[NSString stringWithFormat:@"+%@",[self formatPrice:_priceAddition1
                                                                                      withSeperator:@"."]]];
            }
            else {
                _priceAddition1Temp = _priceAddition1-amount;
                [self.lblPriceOptionOne setText:[NSString stringWithFormat:@"+%@",[self formatPrice:_priceAddition1Temp
                                                                                      withSeperator:@"."]]];
            }
        }
        else {
            _priceAddition1Temp = _priceAddition1;
            [self.lblPriceOptionOne setText:[NSString stringWithFormat:@"+%@",[self formatPrice:_priceAddition1
                                                                                  withSeperator:@"."]]];
        }
        
        [self.lblPriceOptionTwo setText:[NSString stringWithFormat:@"+%@",[self formatPrice:_priceAddition2
                                                                              withSeperator:@"."]]];
        [self.lblPriceOptionThree setText:[NSString stringWithFormat:@"+%@",[self formatPrice:_priceAddition3
                                                                                withSeperator:@"."]]];
    }
    else {
        self.consPriceOptionHeight.constant = 0;
        self.priceOptionView.hidden = YES;
        self.btnRefresh.hidden = YES;
    }
}

- (void) loadData: (FCFareModifier*) modifier {
    if (modifier) {
        NSArray* fare = [FCFareService getFareAddition:_booking.price additionFare:_booking.additionPrice modifier:modifier];
        NSInteger newPrice = [[fare objectAtIndex:0] integerValue];
        NSInteger driverSupport = [[fare objectAtIndex:1] integerValue];
        NSInteger clientSupport = [[fare objectAtIndex:2] integerValue];
        
        _booking.farePrice = newPrice;
        _booking.modifierId = modifier.id;
        _booking.fareClientSupport = clientSupport;
        _booking.fareDriverSupport = driverSupport;
    }
    
    [self loadData];
}

- (void) loadData {
    self.tfPhoneNumber.text = _booking.contactPhone;
    self.lblStart.text = _booking.startName;
    
    if (_booking.tripType == BookTypeFixed) {
        NSInteger bookPrice = [_booking getBookPrice];
        NSInteger clientPay = MAX(bookPrice + _booking.additionPrice - _booking.fareClientSupport, 0);
        self.tfPrice.text = [self formatPrice:clientPay withSeperator:@"."];
        if (_booking.fareClientSupport > 0) {
            self.lblOldPrice.text = [self formatPrice:bookPrice withSeperator:@"."];
            [self.lblOldPrice crossLable];
        }
        else {
            self.lblOldPrice.hidden = YES;
        }
        
        self.lblEnd.text = _booking.endName;
        [self priceDidChanged];
    }
    else {
        self.lblOldPrice.hidden = YES;
        self.lblPriceError.hidden = YES;
        self.tfPrice.text = @"Tính theo lộ trình thực tế";
        self.tfPrice.textColor = [UIColor blackColor];
        self.lblEnd.text = @"Điểm đến theo yêu cầu của bạn!";
        self.lblEnd.textColor = [UIColor grayColor];
    }
    
    [self.tableView reloadData];
}

- (void) loadStationTip:(FCGift*) stationEvent {
    if (self.homeViewModel.bookViewModel.booking.info.tripType == BookTypeOneTouch) {
        self.tfTip.text = @"Được trả khi chuyến đi kết thúc.";
    }
}

- (void) bindingContactPhone {
    // case enter text
    RAC(_booking, contactPhone) = self.tfPhoneNumber.rac_textSignal;
    
    // case choose from list contact
    [RACObserve(self.tfPhoneNumber, text) subscribeNext:^(id x) {
        _booking.contactPhone = x;
        self.homeViewModel.bookViewModel.contactPhone = x;
    }];
}

- (void) priceDidChanged {
    NSInteger price = [self getPrice:self.tfPrice.text];
    NSInteger bookPrice = [_booking getBookPrice];
    if (price < bookPrice - _booking.fareClientSupport) {
        self.lblPriceError.hidden = NO;
    }
    else {
        self.lblPriceError.hidden = YES;
        _booking.additionPrice = MAX(price + _booking.fareClientSupport - bookPrice, 0);
//        self.homeViewModel.bookViewModel.additonPrice = _booking.additionPrice; // cache
    }
    
    [self.tfPrice setText:[self formatPrice:price withSeperator:@"."]];
    [self checkAllowChangePrice: price];
}

- (void) checkAllowChangePrice: (NSInteger) currPrice {
    NSInteger multi = [FirebaseHelper shareInstance].appConfigure.booking_configure.price_maximum_multi;
    if (multi > 0 && currPrice >= _booking.price * multi) {
        [self enablePriceOption1: currPrice + _priceAddition1Temp <= _booking.price * multi];
        [self enablePriceOption2: currPrice + _priceAddition2 <= _booking.price * multi];
        [self enablePriceOption3: currPrice + _priceAddition3 <= _booking.price * multi];
    }
    else {
        if (self.homeViewModel.bookViewModel.paymentMethod == PaymentMethodVATOPay) {
            NSInteger cash = self.homeViewModel.client.user.cash;
            [self enablePriceOption1: currPrice + _priceAddition1Temp <= cash];
            [self enablePriceOption2: currPrice + _priceAddition2 <= cash];
            [self enablePriceOption3: currPrice + _priceAddition3 <= cash];
        }
        else {
            [self enablePriceChange:YES];
        }
    }
}

- (void) enablePriceChange: (BOOL) enable {
    [self enablePriceOption1:enable];
    [self enablePriceOption2:enable];
    [self enablePriceOption3:enable];
}

- (void) enablePriceOption1: (BOOL) enable {
    self.lblPriceOptionOne.userInteractionEnabled = enable;
    if (enable) {
        self.lblPriceOptionOne.alpha = 1.0f;
    }
    else {
        self.lblPriceOptionOne.alpha = 0.5f;
    }
}

- (void) enablePriceOption2: (BOOL) enable {
    self.lblPriceOptionTwo.userInteractionEnabled = enable;
    if (enable) {
        self.lblPriceOptionTwo.alpha = 1.0f;
    }
    else {
        self.lblPriceOptionTwo.alpha = 0.5f;
    }
}

- (void) enablePriceOption3: (BOOL) enable {
    self.lblPriceOptionThree.userInteractionEnabled = enable;
    if (enable) {
        self.lblPriceOptionThree.alpha = 1.0f;
    }
    else {
        self.lblPriceOptionThree.alpha = 0.5f;
    }
}

- (void) closeView {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Handler

- (IBAction)closeClicked:(id)sender {
    [self closeView];
}

- (IBAction)cancelClicked:(id)sender {
    [self closeView];
}

- (IBAction)agreeClicked:(id)sender {
    [self closeView];
    
    [self.homeViewModel loadBookingRequestView:nil];

    
}

- (NSInteger) roundUp5 : (NSInteger) price {
    return (price/5000)*5000;
}

- (IBAction)priceOptionOneClicked:(id)sender {
    NSInteger price = [self getPrice:self.tfPrice.text];
//    price = [self roundUp5:price];
    self.tfPrice.text = [self formatPrice:price + _priceAddition1Temp
                            withSeperator:@"."];
    [self priceDidChanged];
    
    [self showPriceAdditional:YES]; // reload
}

- (IBAction)priceOptionTwoClicked:(id)sender {
    NSInteger price = [self getPrice:self.tfPrice.text];
//    price = [self roundUp5:price];
    self.tfPrice.text = [self formatPrice:price + _priceAddition2
                            withSeperator:@"."];
    [self priceDidChanged];
}

- (IBAction)priceOptionThreeClicked:(id)sender {
    NSInteger price = [self getPrice:self.tfPrice.text];
//    price = [self roundUp5:price];
    self.tfPrice.text = [self formatPrice:price + _priceAddition3
                            withSeperator:@"."];
    [self priceDidChanged];
}

- (IBAction)refreshPrice:(id)sender {
    NSInteger bookPrice = [_booking getBookPrice];
    self.tfPrice.text = [self formatPrice:MAX(bookPrice - _booking.fareClientSupport, 0)
                            withSeperator:@"."];
    [self priceDidChanged];
    
    // reload addition price
    _firstTimeChangePrice = YES;
    [self showPriceAdditional:YES];
}

- (IBAction)contactClicked:(id)sender {
    VeeContactPickerOptions *veeContactPickerOptions = [[VeeContactPickerOptions alloc] initWithDefaultOptions];
    veeContactPickerOptions.showInitialsPlaceholder = NO;
    veeContactPickerOptions.contactThumbnailImagePlaceholder = [UIImage imageNamed:@"avatar-holder"];
    _contactPickerViewController = [[VeeContactPickerViewController alloc] initWithOptions:veeContactPickerOptions];
    [self presentViewController:_contactPickerViewController
                       animated:YES
                     completion:nil];
    
    __weak FCConfirmBookViewController *weakSelf = self;
    [_contactPickerViewController setContactSelectionHandler:^(id<VeeContactProt> contact) {
        @try {
            NSString* resultPhone = contact.phoneNumbers.firstObject;
            [weakSelf.tfPhoneNumber setText:resultPhone];
        }
        @catch (NSException* e) {
        }
        
        [weakSelf.contactPickerViewController dismissViewControllerAnimated:YES
                                                                 completion:nil];
    }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 11) {
        self.tfPhoneNumber.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        self.lblPhoneErrorMessage.hidden = NO;
        self.btnAgree.enabled = NO;
        return NO;
    }
    if ((textField.text.length == 10 || textField.text.length == 11) && ![self validatePhone:textField.text]) {
        self.lblPhoneErrorMessage.hidden = NO;
        self.btnAgree.enabled = NO;
        return NO;
    }
    self.lblPhoneErrorMessage.hidden = YES;
    self.btnAgree.enabled = YES;
    return YES;
}

#pragma mark - TableView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == CFSectionTitle) {
        return 2;
    }
    
    if (!self.homeViewModel.bookViewModel.stationEvent) {
        if (section == CFSectionTip) {
            return 0;
        }
    }
    
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.homeViewModel.bookViewModel.stationEvent) {
        if (section == CFSectionTip) {
            return 0.1f;
        }
    }
    
    return 10.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

@end

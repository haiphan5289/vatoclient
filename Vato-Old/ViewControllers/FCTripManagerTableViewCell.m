//
//  FCTripManagerTableViewCell.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripManagerTableViewCell.h"
#import "UIView+Border.h"

@implementation FCTripManagerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.imgAvatar circleView:ORANGE_COLOR];
    [self.lblStatus borderViewWithColor:[UIColor clearColor] andRadius:5];
    [self.bgView borderViewWithColor:[UIColor clearColor] andRadius:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) loadData:(FCTripHistory *)trip {
    if (trip.startName.length > 0) {
        self.lblStart.textColor = [UIColor blackColor];
        self.lblStart.text = trip.startName;
    }
    else {
        self.lblStart.textColor = [UIColor grayColor];
        self.lblStart.text = localizedFor(@"Không xác định");
    }
    
    if (trip.endName.length > 0) {
        self.lblEnd.textColor = [UIColor blackColor];
        self.lblEnd.text = trip.endName;
    }
    else {
        self.lblEnd.textColor = [UIColor grayColor];
        self.lblEnd.text = localizedFor(@"Không xác định");
    }
    NSString *title;
    switch (trip.payment) {
        case PaymentMethodVATOPay:
            title = @"  VATOPAY  ";
            break;
        case PaymentMethodCash:
            title = [NSString stringWithFormat:@"  %@  ", [localizedFor(@"Tiền mặt") uppercaseString]] ;
            break;
        default:
            title = [NSString stringWithFormat:@"  %@  ", [localizedFor(@"Thẻ") uppercaseString]] ;
            break;
    }
    if (trip.payment == PaymentMethodVATOPay) {
        self.lblPaymentOption.backgroundColor = ORANGE_COLOR;
        self.lblPaymentOption.textColor = [UIColor whiteColor];
    }
    else {
        self.lblPaymentOption.backgroundColor = LIGHT_GRAY;
        self.lblPaymentOption.textColor = [UIColor blackColor];
    }
    
    self.lblPaymentOption.text = title;
    
    if (trip.promotionCode.length > 0) {
        self.lblPromotion.hidden = NO;
    }
    else {
        self.lblPromotion.hidden = YES;
    }
    
    self.lblPrice.text = [self formatPrice:MAX(MAX(trip.price, trip.farePrice) + trip.additionPrice - trip.promotionValue, trip.additionPrice)];
    
    NSString *time = [NSString stringWithFormat:@"%@ • %@",trip.tripCode ?: @"" ,[self getTimeString:trip.createdAt] ?: @""];
    
    self.lblTime.text = time;
    

//    [[FirebaseHelper shareInstance] getDriver:trip.driverFirebaseId
//                                      handler:^(FCDriver * driver) {
//                                          [self.imgAvatar setImageWithURL:[NSURL URLWithString:driver.user.avatarUrl]
//                                                         placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
//                                          self.lblName.text = driver.user.fullName;
//                                          self.lblPhone.text = [NSString stringWithFormat:@"%@ \u2022 %@", driver.vehicle.marketName, driver.vehicle.plate];
////                                          @try {
////                                              NSString* phone = [driver.user.phone stringByReplacingCharactersInRange:NSMakeRange(driver.user.phone.length-3, 3) withString:@"xxx"];
////                                              self.lblPhone.text = phone;
////                                          }
////                                          @catch (NSException* e) {
////                                          }
//                                      }];
    
    NSString *status = @"";
    switch (trip.statusDetail) {
        case BookStatusClientCreateBook:
        case BookStatusDriverAccepted:
        case BookStatusClientAgreed:
        case BookStatusStarted:
        case BookStatusDeliveryReceivePackageSuccess:
            status = localizedFor(@"Trong chuyến đi");
            self.lblStatus.textColor = DARK_GREEN;
            break;
            
        case BookStatusCompleted:
            status = localizedFor(@"Hoàn thành");
            self.lblStatus.textColor = DARK_GREEN;
            break;
            
        case BookStatusClientTimeout:
        case BookStatusClientCancelInBook:
        case BookStatusClientCancelIntrip:
            status = localizedFor(@"Khách hủy");
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
            
        case BookStatusAdminCancel:
            status = localizedFor(@"Admin hủy");
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
            
        case BookStatusDriverCancelIntrip:
        case BookStatusDriverCancelInBook:
            status = localizedFor(@"Tài xế hủy");
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
            
        case BookStatusDriverMissing:
            status = localizedFor(@"TX để trôi");
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
        case BookStatuDeliveryFail:
            status = localizedFor(@"Thất bại");
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
        default:
            status = @"";
            self.lblStatus.textColor = [UIColor orangeColor];
            break;
    }
    self.lblStatus.text = [status uppercaseString];
}

@end

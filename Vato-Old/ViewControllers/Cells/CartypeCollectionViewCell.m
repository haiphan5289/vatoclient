//
//  CartypeCollectionViewCell.m
//  FaceCar
//
//  Created by vudang on 12/5/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "CartypeCollectionViewCell.h"
#import "UILabel+Helper.h"
#import "FCFareModifier.h"
#import "FCFareService.h"
#import "FCBookViewModel.h"

@interface CartypeCollectionViewCell ()
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *icon;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *name;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *mask;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *promoPrice;
@property (weak, nonatomic) IBOutlet UIImageView *iconGift;
@property (weak, nonatomic) IBOutlet UIImageView *iconStar;
@end

@implementation CartypeCollectionViewCell {
    NSInteger _saleprice;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.mask layoutIfNeeded];
    self.mask.layer.cornerRadius = self.mask.bounds.size.height/2;
    self.mask.clipsToBounds = TRUE;
    
    self.mask.backgroundColor = [UIColor clearColor];
}

- (void) loadData {
    self.name.text = self.cartype.name;
    [self setSelectedCar:NO];
    
    // for change
    [RACObserve(self.homeViewModel.bookViewModel, priceDict) subscribeNext:^(id x) {
        if (x) {
            [self onLoadPriceView:x];
        }
        else {
            [self onResetPriceView:x];
        }
    }];
    
    [self onLoadPriceView:nil];
}

- (void) onLoadPriceView: (id) sender {
    self.promoPrice.hidden = YES;
    self.iconGift.hidden = YES;
    
    _saleprice = [self.homeViewModel.bookViewModel getPriceForSerivce:self.cartype.id];
    if (_saleprice > 0) {
        self.price.text = [self formatPrice:_saleprice withSeperator:@"."];
    }
    else {
        self.price.text = EMPTY;
    }
    
    [self checkingPromotion];
}

- (void) checkingPromotion {
    FCBooking* book = [[FCBooking alloc] init];
    book.info = [self.homeViewModel.bookViewModel createTempBookInfo];
    book.info.price = _saleprice;
    book.info.serviceId = self.cartype.id;
    
    [[FCFareService shareInstance] getFareModifier:book complete:^(FCFareModifier *fareModifier) {
        [self loadPromotionInfo:fareModifier
                      salePrice:_saleprice]; // reload price
        
        [self.homeViewModel.bookViewModel saveModifier:fareModifier service:self.cartype.id];
        
        // service for reload
        FCMCarType* service = self.homeViewModel.bookViewModel.serviceSelected;
        self.homeViewModel.bookViewModel.serviceSelected = service;
    }];
}

- (void) loadPromotionInfo: (FCFareModifier*) gift
                 salePrice: (NSInteger) price {
    
    if (_saleprice > 0) {
        if (gift) {
            NSArray* fare = [FCFareService getFareAddition:_saleprice additionFare:0 modifier:gift];
            NSInteger newPrice = [[fare objectAtIndex:0] integerValue];
//            NSInteger driverSupport = [[fare objectAtIndex:1] integerValue];
            NSInteger clientSupport = [[fare objectAtIndex:2] integerValue];
            
#if DEV
            self.price.text = [NSString stringWithFormat:@"%@, %ldk", [self formatPrice:newPrice withSeperator:@"."], _saleprice/1000];
#else
            self.price.text = [self formatPrice:newPrice withSeperator:@"."];
#endif
            if (clientSupport > 0) {
                NSInteger clientPay = MAX(newPrice - clientSupport, 0);
                [self.price crossLable];
                self.promoPrice.hidden = NO;
                self.promoPrice.text = [self formatPrice:clientPay withSeperator:@"."];
            }
            else {
                self.promoPrice.hidden = YES;
            }
            
            // icon gift
            self.iconGift.hidden = clientSupport == 0;
        }
        else {
            self.promoPrice.hidden = YES;
        }
    }
}

- (void) onResetPriceView: (id) sender {
    self.price.text = EMPTY;
    self.promoPrice.hidden = YES;
}

- (void) setSelectedCar:(BOOL)selected {
   
    // default is for select status
    CGFloat from = 0.9f;
    CGFloat to = 1.1f;
    CGFloat icFrom = 0.0f; // for icon star
    CGFloat icTo = 1.0f; // for icon star
    UIImage* iconFrom = [UIImage imageNamed:[NSString stringWithFormat:@"car_menu_%ld-normal", (long)self.cartype.id]];
    UIImage* iconTo = [UIImage imageNamed:[NSString stringWithFormat:@"car_menu_%ld-selected", (long)self.cartype.id]];
    UIImage* iconEffect = [UIImage imageNamed:[NSString stringWithFormat:@"effect-%ld", (long)self.cartype.id]];
    self.iconStar.image = iconEffect;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
    if (!selected) {
        from = 1.1f;
        to = 0.9f;
        icFrom = 1.0f;
        icTo = 0.0f;
        iconFrom = [UIImage imageNamed:[NSString stringWithFormat:@"car_menu_%ld-selected", self.cartype.id]];
        iconTo = [UIImage imageNamed:[NSString stringWithFormat:@"car_menu_%ld-normal", self.cartype.id]];
        options = UIViewAnimationOptionCurveEaseIn;
        self.iconStar.transform = CGAffineTransformMakeScale(icTo, icTo);
    }
    
    self.icon.image = iconFrom;
    self.icon.transform = CGAffineTransformMakeScale(from, from);
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:options
                     animations:^{
                         self.icon.image = iconTo;
                         self.icon.transform = CGAffineTransformMakeScale(to, to);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    // star icon animation
    self.iconStar.transform = CGAffineTransformMakeScale(icFrom, icFrom);
    [UIView animateWithDuration:0.2f
                          delay:0.1f
                        options:options
                     animations:^{
                         self.iconStar.transform = CGAffineTransformMakeScale(icTo, icTo);
                     }
                     completion:^(BOOL finished) {
                     }];
    
}
@end

@implementation Cartype

- (id) init:(NSString*) name iconName: (NSString*) icon type: (NSInteger) type select: (BOOL) select{
    self.icon = icon;
    self.name = name;
    self.type = type;
    self.selected = select;
    
    return self;
}

@end

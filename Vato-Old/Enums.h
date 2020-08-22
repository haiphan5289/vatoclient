//
//  Enums.h
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

typedef enum : NSUInteger {
    BookStatusClientCreateBook = 11,
    BookStatusDriverAccepted = 12,
    BookStatusClientAgreed = 13,
    BookStatusStarted = 14, // chuyến đi bắt đầu
    BookStatusDeliveryReceivePackageSuccess = 15, // use for Express
    BookStatusCompleted = 21, // hoàn thành
    BookStatuDeliveryFail = 22, // use for Express
    BookStatusClientTimeout = 31,
    BookStatusClientCancelInBook = 32,
    BookStatusClientCancelIntrip = 33,
    BookStatusDriverCancelInBook = 41,
    BookStatusDriverDontEnoughMoney = 42,
    BookStatusDriverMissing = 43,
    BookStatusDriverBusyInAnotherTrip = 44, // driver in a another trip
    BookStatusDriverCancelIntrip = 45,
    BookStatusAdminCancel = 51
} TripStatusDetail;

typedef enum : NSUInteger {
    TripStatusStarted = 10,
    TripStatusCompleted = 20,
    TripStatusClientCanceled = 30,
    TripStatusDriverCanceled = 40,
    TripStatusAdminCanceled = 50
} TripStatus;

typedef enum : NSUInteger {
    NotifyTypeDefault = 10,
    NotifyTypeReferal = 20,
    NotifyTypeLink = 30,
    NotifyTypePrmotion = 40,
    NotifyTypeBalance = 50,
    NotifyTypeTranferMoney = 60,
    NotifyTypeUpdateApp = 70,
    NotifyTypeChatting = 90, // new chat
    NotifyTypeNewBooking = 91, // new booking
    NotifyTypeManifest = 100,
    NotifyTypeWeb = 110,
    NotifyNotEnoughVatoPay = 10000
} NotifyType;

typedef enum : NSInteger {
    VatoServiceCar = 1,
    VatoServiceCarPlus = 2,
    VatoServiceCar7 = 4,
    VatoServiceMoto = 8,
    VatoServiceMotoPlus = 16,
    VatoServiceTaxi = 32,
    VatoServiceTaxi7 = 64,
    VatoServiceDelivery = 128
} VatoService;

typedef enum : NSUInteger {
    BookTypeFixed = 10, // book cố định
    BookTypeOneTouch = 20, // book 1 cham
    BookTypeDigital = 30 // đồng hồ điện tử
} BookType;

typedef enum : NSUInteger {
    DRIVER_UNREADY = 0,
    DRIVER_READY = 10,
    DRIVER_BUSY = 20
} OnlineStatus;

typedef enum : NSUInteger {
    APIStatusOK = 200,
    APIStatusAccountBanned = 409,
    APIStatusAccountSpam = 429
} APIStatus;

typedef enum : NSUInteger {
    ViewTypeFavorite = 0,
    ViewTypeBlock = 10
} FavViewType;

typedef enum : NSUInteger {
    UpdateViewTypeEmail = 10,
    UpdateViewTypeNickName = 11,
    UpdateViewTypeFullName = 12
} UpdateViewType;

typedef enum : NSInteger {
    LinkConfigureTypeCreateCar = 10,
    LinkConfigureTypeIDPage = 20,
    LinkConfigureTypeSummaryBonusPage = 21,
    LinkConfigureTypeTopup = 30,
    LinkConfigureTypeUpdateProfile = 40
} LinkConfigureType;

typedef enum : NSInteger {
    ClientConfigTypeTranferMoney = 10,
    ClientConfigTypeIncreasePriceMessage = 20,
    ClientConfigTypePaymentOption = 30
} ClientConfigType;

typedef enum : NSInteger {
    PaymentMethodCash = 0,
    PaymentMethodVATOPay = 1,
    PaymentMethodAll = 2,
    PaymentMethodVisa = 3,
    PaymentMethodMastercard = 4,
    PaymentMethodATM = 5,
    PaymentMethodMomo = 6,
    PaymentMethodZaloPay = 7
} PaymentMethod;

#endif /* Enums_h */

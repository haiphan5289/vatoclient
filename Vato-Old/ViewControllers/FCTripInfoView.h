//
//  FCTripInfoView.h
//  FaceCar
//
//  Created by facecar on 12/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCSwipeView.h"
#import "FCBookViewModel.h"

#define kFooterHeight 250
#define kInfoMarginTop 50

typedef NS_ENUM(NSInteger, FCTripInfoViewType) {
    FCTripInfoViewTypeTripStatus = 0,
    FCTripInfoViewTypeInvoice = 1,
    FCTripInfoViewTypeBookingRequest = 2
};

typedef NS_ENUM(NSInteger, TripShowType) {
    TripShowTypeBooking = 0,
    TripShowTypeExpress = 1,
    TripShowTypeTaxi = 2
};


@protocol FCTripInfoViewDelegate <NSObject>
- (void) onBookCanceled;
- (void) newTrip;
@optional
- (void) didCompleteTrip;
@end

@interface FCTripInfoView : FCSwipeView

@property (weak, nonatomic) IBOutlet FCImageView *imgDriverAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblCarName;
@property (weak, nonatomic) IBOutlet UIButton *taxiBrandLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnNewBook;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIView *dockView;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *receiverName;

@property (weak, nonatomic) IBOutlet UILabel *lblYourTrip;
@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;

@property (weak, nonatomic) IBOutlet UILabel *lblDurationInfo;


@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteForDriver;
@property (weak, nonatomic) IBOutlet UIButton *paymentLabel;


// for invoice info
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePriceStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consDriverInfoHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestConnecting;
@property (weak, nonatomic) IBOutlet UILabel *subTextStatus;
@property (weak, nonatomic) IBOutlet FCProgressView *progressRequestView;

// note
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UIView *noteView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hightViewNoteConstraint;

// Fee serice
@property (weak, nonatomic) IBOutlet UILabel *feeServiceValue;
@property (weak, nonatomic) IBOutlet UILabel *feeServiceText;


@property (strong, nonatomic) FCBooking* bookData;
@property (assign, nonatomic) FCTripInfoViewType currentType;
@property (weak, nonatomic) id<FCTripInfoViewDelegate> delegate;

- (NSInteger) loadInvoiceInfo: (FCBooking*) book
                    bookModel: (FCBookViewModel*) bookViewModel;
- (void) initForRequestBooking;
- (void) loadRequestView: (FCBooking*) book;
- (void) hideCancelButton;
- (void) isShowNewTripButton:(BOOL)isShow;
- (void) showRatingView;

- (void) showChatBadge: (NSInteger) badge;
- (void) hideAnyPopup: (void (^)(void)) complete;
- (void) changeMethodToHardCash;
- (void)updateStatus;

- (id) initTripShowType:(TripShowType) type;
@end

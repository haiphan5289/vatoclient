//
//  TripMapsViewController.h
//  FaceCar
//
//  Created by Vu Dang on 8/21/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCTripViewModel;
@class FCBooking;

@protocol FCTripMapViewControllerDelegate <NSObject>
- (void) onTripFailed;
- (void) onTripCompleted;
- (void) onTripClientCancel;
@optional
- (void) dissmissTripMap;
- (void) newTrip;
@end

@interface TripMapsViewController : UIViewController

@property (strong, nonatomic) NSDictionary* bookSnapshot;
@property (strong, nonatomic) FCBooking* book;
@property (weak, nonatomic) id<FCTripMapViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL fromHistory;
@property (assign, nonatomic) BOOL fromDelivery;

- (instancetype) initViewController:(FCTripViewModel*) viewModel;

- (void) showChatView;
- (void) dismissChat;
- (void) checkShowPopupCancel;
- (void) tripFinished;
- (void) removeBookingListener;
@end

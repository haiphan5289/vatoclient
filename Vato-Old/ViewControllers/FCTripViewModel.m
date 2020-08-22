//
//  FCTripViewModel.m
//  FaceCar
//
//  Created by vudang on 5/23/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripViewModel.h"
#import "UserDataHelper.h"
#import "TripMapsViewController.h"
#import "FCBookingService.h"

@interface FCTripViewModel ()
@property (assign, nonatomic) FIRDatabaseHandle bookDeletedHandler;
@end

@implementation FCTripViewModel {
    FCBookingService* _bookingService;
    FIRDatabaseReference* _refDel;
    BOOL _isFinished;
}

- (instancetype) initViewModel:(FCBooking*)book
                       cartype:(NSInteger)type
                   fromManager:(BOOL)fromManager {
    
    self = [super init];
 
    if (self) {
        self.booking = book;
        self.cartypeSelected = type;
        self.fromManagerBook = fromManager;
        _bookingService = [FCBookingService shareInstance];
        
        if (type == 0) {
            self.cartypeSelected = [[UserDataHelper shareInstance] getCurrentCar];   
        }
        
        [self registerListenerCallback];
    }
    
    return self;
}

- (void) registerListenerCallback {
    @weakify(self);
    // save last book
    [[UserDataHelper shareInstance] saveLastestTripbook:self.booking.info
                                             currentCar:self.cartypeSelected];
    
    // remove booking listener first
//    [_bookingService removeBookingListener];
    
    // trip status listener
    [_bookingService listenerBookingStatusChange:^(FCBookCommand *status) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onBookingStatusChanged:status];
        });
    }];
    
    [_bookingService listenerBookingInfoChange:^(FCBookInfo * info) {
        @strongify(self);
        [self onBookingInfoChanged:info];
    }];
    
    [_bookingService listenerBookDelete:^{
        @strongify(self);
        [self onBookIsDeleted];
    }];
    
    // get last driver's location
    [[FirebaseHelper shareInstance] getLastLocationOfDriver:self.booking.info.driverFirebaseId
                                                   callback:^(FCLocation * location) {
                                                       self.lastDriverLocation = location;
                                                   }];
    
    // listener driver changed location
    [[FirebaseHelper shareInstance] listenerDriverLocationChanged:self.booking.info.driverFirebaseId
                                                         callback:^(FCLocation * location) {
                                                             self.lastDriverLocation = location;
                                                         }];

    // listener book is deleted
//    [self listenerBookDeleted];
}

- (void) onBookingInfoChanged: (FCBookInfo *) info {
    self.booking.info = info;
}

- (void) onBookingStatusChanged: (FCBookCommand*) status {
    if (status) {
        self.status = status;
        if ([_bookingService isTripCompleted]) {
            [self playsound:@"success"];
            [self removeListenerBookDeleted];
        } else if ([_bookingService isTripStarted]) {
            [self playsound:@"success"];
        }
        else if ([_bookingService isAdminCanceled] || [_bookingService isClientCanceled] || [_bookingService isDriverCanceled]) {
            [self playsound:@"cancel"];
            [[UserDataHelper shareInstance] removeLastestTripbook];
            [self removeListenerBookDeleted];
        }
    }
}

// listener book is deleted
- (void) listenerBookDeleted {
    @try {
        /* double check book is deleted in case: user book -> user force app -> driver complete/ cancel trip -> user open app
         -> firebase post event trip delete but listenerBookDeleted not init => app client alway in screen in trip although trip is cancel or delete
         */
        [[FirebaseHelper shareInstance] findTrip:self.booking.info.tripId handler:^(NSDictionary *value) {
            if ([value isEqual:[NSNull null]] || value == nil) {
                [self onBookIsDeleted];
            }
        }];
        
        // listener end place info
        _refDel = [[[FirebaseHelper shareInstance].ref
                    child:TABLE_BOOK_TRIP]
                   child:self.booking.info.tripId];
        
        // listener trip is deleted (trip finished)
        self.bookDeletedHandler = [_refDel observeEventType:FIRDataEventTypeChildRemoved
                                                  withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                                      if (!_isFinished && [snapshot.key isEqualToString:@"info"]) {
                                                          [self onBookIsDeleted];
                                                      }
                                                  }];
    }
    @catch(NSException* e) {
    }
}

- (void) removeListenerBookDeleted {
    @try {
        _isFinished = YES;
        if (self.bookDeletedHandler != 0) {
            [_refDel removeObserverWithHandle:self.bookDeletedHandler];
        }
    }
    @catch (NSException* e) {
        
    }
}

// get book history for show invoice info to user
- (void) onBookIsDeleted {
    self.bookIsDeteleted = YES;
}

@end

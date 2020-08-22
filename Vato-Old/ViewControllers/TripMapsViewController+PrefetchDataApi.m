//
//  TripMapsViewController+PrefetchDataApi.m
//  Vato
//
//  Created by vato. on 2/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

#import "TripMapsViewController+PrefetchDataApi.h"


@implementation TripMapsViewController (PrefetchDataApi)

- (void) checkingNetwork {
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_NETWOTK_CONNECTED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self fetchTrip];
    }];
}

- (void)fetchTrip {
    @weakify(self);
    [[APIHelper shareInstance] get:API_GET_GET_TRIP_DETAIL params:@{@"id": self.book.info.tripId} complete:^(FCResponse *response, NSError *error) {
        @strongify(self);
        if (response.data[@"trip"] != nil && response.data[@"trip"][@"statusDetail"] != nil) {
            NSInteger status = [response.data[@"trip"][@"statusDetail"] integerValue];
            FCBookCommand *command = [[FCBookCommand alloc] init];
            command.status = status;
            if ([self isCancel:command] == true) {
                [self checkShowPopupCancel];
                [self removeBookingListener];
            } else if ([self isComplete:command] == true) {
                [self tripFinished];
                [self removeBookingListener];
            }
        }
    }];
}

- (BOOL) isCancel:(FCBookCommand *) command {
    if (command.status == BookStatusDriverCancelIntrip
        || command.status == BookStatusAdminCancel) {
        return YES;
    }
    return NO;
}

- (BOOL) isComplete:(FCBookCommand *) command {
    if (command.status == BookStatusCompleted
        || command.status == BookStatuDeliveryFail) {
        return YES;
    }
    return NO;
}

@end

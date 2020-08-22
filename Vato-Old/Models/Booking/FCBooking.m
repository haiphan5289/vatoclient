//
//  FCBooking.m
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBooking.h"

@implementation FCBooking


- (instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict
                               error:err];
    if (self) {
        [self setListStatus: dict];
    }
    
    return self;
}

- (void) setListStatus: (NSDictionary*) dict {
    if ([dict objectForKey:@"command"]) {
        NSMutableArray* commands = [[NSMutableArray alloc] init];
        NSDictionary* cmdDict = [dict objectForKey:@"command"];
        for (NSDictionary* d in cmdDict.allValues) {
            FCBookCommand* stt = [[FCBookCommand alloc] initWithDictionary:d
                                                                     error:nil];
            [commands addObject:stt];
        }
        
        NSArray* array = [commands sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
            return obj1.time > obj2.time;
        }];
        
        self.command = [array copy];
    }
    
    if ([dict objectForKey:@"tracking"]) {
        NSMutableArray* tracking = [[NSMutableArray alloc] init];
        NSDictionary* trackDict = [dict objectForKey:@"tracking"];
        for (NSDictionary* d in trackDict.allValues) {
            FCBookTracking* stt = [[FCBookTracking alloc] initWithDictionary:d
                                                                       error:nil];
            if (stt != nil) {
                [tracking addObject:stt];
            }
        }
        
        self.tracking = [tracking copy];
    }
}

- (BOOL)isAllowLoadTripLasted {
    FCBookCommand *stt = [self getLastBookStatus];
    if (stt.status == BookStatusDriverAccepted ||
        stt.status == BookStatusClientCreateBook ||
        stt.status == BookStatusClientAgreed) {
        return YES;
    }
    return NO;
}

- (BOOL)isIntrip {
    FCBookCommand *stt = [self getLastBookStatus];
    if (stt.status == BookStatusClientCreateBook ||
        stt.status == BookStatusDriverAccepted ||
        stt.status == BookStatusClientAgreed ||
        stt.status == BookStatusStarted ||
        stt.status == BookStatusDeliveryReceivePackageSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)isTripComplete {
    if (self.info.statusDetail == BookStatusCompleted ||
        self.info.statusDetail == BookStatuDeliveryFail) {
        return YES;
    }
    for (FCBookCommand *stt in self.command) {
        if (stt.status == BookStatuDeliveryFail ||
            stt.status == BookStatusCompleted) {
            return YES;
        }
    }
    return NO;
}

- (FCBookCommand*) getLastBookStatus {
    if (self.command.count > 0) {
        FCBookCommand* last = [self.command sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand *obj1, FCBookCommand *obj2) {
            return obj1.status < obj2.status;
        }].firstObject;
        return last;
    }
    return nil;
}

@end

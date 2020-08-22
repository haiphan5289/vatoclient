//
//  FCShipViewModel.m
//  FaceCar
//
//  Created by facecar on 3/9/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCShipViewModel.h"

@implementation FCShipViewModel

- (id) init {
    self = [super init];
    if (self) {
        [self getListShipService:^(NSMutableArray *list) {
            [self getDefaultService];
        }];
    }
    
    return self;
}

- (void) getListShipService:(void (^)(NSMutableArray *))handler {
    if (self.listSerivce.count > 0) {
        handler(self.listSerivce);
        return;
    }
    
    [[FirebaseHelper shareInstance] getShipService:^(NSMutableArray *list) {
        self.listSerivce = list;
        handler(list);
    }];
}

- (void) getDefaultService {
    for (FCShipService* se in self.listSerivce) {
        if (se.choose) {
            self.serviceSelected = se;
            break;
        }
    }
}
@end

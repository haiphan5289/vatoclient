//
//  FCBookStatus.m
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookCommand.h"

@implementation FCBookCommand
- (BOOL)isEqual:(id)object {
    FCBookCommand *obj2 = [FCBookCommand castFrom:object];
    if (!obj2) { return NO; }
    return _status == obj2.status;
}


- (BOOL)isClientStatus {
    if (self.status == BookStatusClientCreateBook ||
        self.status == BookStatusClientAgreed ||
        self.status == BookStatusClientTimeout ||
        self.status == BookStatusClientCancelInBook ||
        self.status == BookStatusClientCancelIntrip ) {
        return true;
    }
    return false;
}

@end

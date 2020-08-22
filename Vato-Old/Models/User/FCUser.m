//
//  FCUser.m
//  FaceCar
//
//  Created by facecar on 5/10/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCUser.h"

@implementation FCUser

- (id) init {
    self = [super init];
    if (self) {
        self.phone = @"";
        self.email = @"";
        self.fullName = @"";
        self.avatarUrl = @"";
    }
    return self;
}

- (NSString*) getDisplayName {
    if (self.nickname.length > 0) {
        return self.nickname;
    }
    return self.fullName;
}

@end

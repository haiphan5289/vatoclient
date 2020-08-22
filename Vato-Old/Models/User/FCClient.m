//
//  FCClient.m
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCClient.h"

@implementation FCClient
@synthesize active = _active;

- (id) init {
    self = [super init];
    
    if (self) {
        self.user = [[FCUser alloc] init];
        self.active = @(TRUE);
    }
    return self;
}

- (void) setActive:(NSNumber *)active {
    _active = @([active boolValue]);
}

@end


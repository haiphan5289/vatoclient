//
//  FCMapInfoWindow.m
//  FaceCar
//
//  Created by facecar on 12/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCMapMarker.h"

@implementation FCMapMarker

- (id) init {
    self = [super init];
    if (self) {
        self = (FCMapMarker*) [[[NSBundle mainBundle] loadNibNamed:@"FCMapMarker" owner:self options:nil] firstObject];
    }
    
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.styleEndInbookView.hidden = YES;
    self.styleEndIntripView.hidden = YES;
    self.styleStartInbookView.hidden = YES;
    self.styleStartIntripView.hidden = YES;
    self.styleCustomView.hidden = YES;
    self.styleDefaultView.hidden = YES;
    self.styleStartOnlyIconView.hidden = YES;
    
    [self setMarkerStyle:FCMarkerStyleDefault];
}

- (void) setMarkerStyle:(FCMarkerStyle)style {
    self.styleDefaultView.hidden = YES;
    if (style == FCMarkerStyleDefault) {
        self.styleDefaultView.hidden = NO;
    }
    else if (style == FCMarkerStyleStartInBook) {
        self.styleStartInbookView.hidden = NO;
    }
    else if (style == FCMarkerStyleEndInBook) {
        self.styleEndInbookView.hidden = NO;
    }
    else if (style == FCMarkerStyleStartInTrip) {
        self.styleStartIntripView.hidden = NO;
    }
    else if (style == FCMarkerStyleEndInTrip) {
        self.styleEndIntripView.hidden = NO;
    }
    else if (style == FCMarkerStyleCustom) {
        self.styleCustomView.hidden = NO;
    }
    else if (style == FCMarkerStyleStartOnlyIcon) {
        self.styleStartOnlyIconView.hidden = NO;
    }
}
@end

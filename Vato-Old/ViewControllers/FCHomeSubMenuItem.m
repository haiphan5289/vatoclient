//
//  FCHomeSubMenuItem.m
//  FaceCar
//
//  Created by facecar on 12/16/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCHomeSubMenuItem.h"
@interface FCHomeSubMenuItem ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet FCLabel *label;
@property (weak, nonatomic) IBOutlet FCLabel *lblBadge;
@end

@implementation FCHomeSubMenuItem {
    void (^_clickCallback) (void);
    BOOL _selected;
    NSArray* _icons;
    NSArray* _labels;
}


- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isShadow) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(-2, -2);
        self.layer.shadowRadius = self.shadowRadius;
        self.layer.shadowOpacity = self.shadowOpacity;
    }
}

- (void) itemWithIcon:(NSArray*)icons
                lable:(NSArray*)lbls
                click:(void (^)(void))block {
    _icons = icons;
    _labels = lbls;
    self.icon.image = [icons objectAtIndex:0];
    self.label.text = [lbls objectAtIndex:0];
    _clickCallback = block;
}


- (IBAction)clicked:(id)sender {
    _selected = !_selected;
    if (_icons.count == 2) {
        if (_selected) {
            self.icon.image = [_icons objectAtIndex:1];
            self.label.text = [_labels objectAtIndex:1];
        }
        else {
            self.icon.image = [_icons objectAtIndex:0];
            self.label.text = [_labels objectAtIndex:0];
        }
    }
    
    
    if (_clickCallback) {
        _clickCallback ();
    }
}

- (void) showBadge: (NSInteger) count {
    self.lblBadge.hidden = count == 0;

    if (count > 9) {
        self.lblBadge.text = @"9+";
    }
    else {
        self.lblBadge.text = [NSString stringWithFormat:@"%ld", count];
    }
}

@end

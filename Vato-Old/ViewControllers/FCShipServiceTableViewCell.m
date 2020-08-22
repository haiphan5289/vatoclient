//
//  FCShipServiceTableViewCell.m
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCShipServiceTableViewCell.h"

@implementation FCShipServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)infoClicked:(id)sender {
    [UIAlertController showAlertInViewController:self.viewcontroller
                                       withTitle:nil
                                         message:self.service.desc
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"OK"]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            
                                        }];
}

@end

//
//  FCPopupListView.m
//  FaceCar
//
//  Created by facecar on 12/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPopupListView.h"
#import "FCPartnerTableViewCell.h"

#define kCellIdentify @"FCPartnerTableViewCell"
#define kRowHeight 80

@interface FCPopupListView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblMesage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation FCPopupListView {
    CGRect _fromFrame;
    CGRect _targetFrame;
    NSArray* _listPartner;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.frame =  [UIScreen mainScreen].bounds;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FCPartnerTableViewCell class]) bundle:nil]
         forCellReuseIdentifier:kCellIdentify];
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
    _listPartner = homeViewModel.listPartner;
}

- (void) show {
    self.bgView.alpha = 0.0f;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSInteger targetH = kRowHeight*_listPartner.count > screenSize.height *3/4 ?  screenSize.height *3/4 : kRowHeight*_listPartner.count; // row height * num rows
    _fromFrame = CGRectMake(self.originPoint.x, self.originPoint.y, 0, 0);
    _targetFrame = CGRectMake(20, (screenSize.height - targetH)/2, (screenSize.width - 20*2), targetH);
    self.tableView.frame = _fromFrame;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bgView.alpha = 0.8f;
                         self.tableView.frame = _targetFrame;
                     }
                     completion:^(BOOL finished) {
                         [self layoutSubviews];
                     }];
    
    // reload layout
    [self.indicator stopAnimating];
    self.lblMesage.hidden = _listPartner.count > 0;
    [self.tableView reloadData];
}

- (void) hide {
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bgView.alpha = 0.01f;
                         self.tableView.alpha = 0.01f;
                         self.tableView.frame = _fromFrame;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (IBAction)closeClicked:(id)sender {
    [self hide];
}
- (IBAction)bgclicked:(id)sender {
    [self hide];
}
- (IBAction)chooseAllClicked:(id)sender {
    self.partnerSelected = nil; // clear
    [self hide];
}

#pragma mark - Tableview delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listPartner.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCPartnerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify
                                                                   forIndexPath:indexPath];
    FCPartner* partner = [_listPartner objectAtIndex:indexPath.row];
    [cell.icon setImageWithUrl:partner.logo
                        holder:cell.icon.image];
    cell.lblName.text = partner.fullname;
    cell.lblDescription.text = partner.slogan;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.partnerSelected = [_listPartner objectAtIndex:indexPath.row];
    [self hide];
}

@end

//
//  GoogleAutoCompleteViewController.m
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "GoogleAutoCompleteViewController.h"
#import "FCGooglePlaceTableViewCell.h"

#define CELL @"FCGooglePlaceTableViewCell"

@interface GoogleAutoCompleteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* listPlace;
@property (strong, nonatomic) NSArray* listHistory;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GoogleAutoCompleteViewController

- (void)dealloc {
    self.googleViewModel = nil;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 0, size.width, size.height);
    [self layoutIfNeeded];
    
    [self.tableView setScrollEnabled:NO];
}

- (void) setMapview:(FCGGMapView *)mapview {
    _mapview = mapview;
    
    [self initView];
}

- (void) initView {
    self.googleViewModel = [[GoogleViewModel alloc] init:self.mapview];

    __weak GoogleAutoCompleteViewController * const weakSelf = self;
    [self setInteractionListener:^(BOOL isHide, BOOL isShow) {
        if (isHide) {
            [weakSelf.progressView dismiss];
            [weakSelf.searchView resignFirstResponder];
        }
    }];
    
    // table
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    
    [RACObserve(self.googleViewModel, listPlace) subscribeNext:^(NSArray* x) {
        [self.progressView dismiss];
        self.listPlace = x;
        [self.tableView reloadData];
    }];
    
    [RACObserve(self.googleViewModel, listHistory) subscribeNext:^(id x) {
        [self.progressView dismiss];
        self.listHistory = x;
        [self.tableView reloadData];
    }];

}

- (void) setSearchView:(UITextField *)searchView {
    _searchView = searchView;

    // callback
    __block BOOL allow;
    [_searchView.rac_textSignal subscribeNext:^(id x) {
        if (x) {
            if (allow) {
                [self.progressView show];
                [self.googleViewModel queryPlace:x];
            }
            allow = YES;
        }
    }];
}

#pragma mark - TableView Delegate
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCGooglePlaceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    id data = [self.listPlace objectAtIndex:indexPath.row];
    if (data) {
        [cell loadData:data];
    }
    else {
        FCPlaceHistory* his = [self.listHistory objectAtIndex:indexPath.row];
        [cell loadDataForHis:his];
    }
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listPlace ? self.listPlace.count : self.listHistory.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.progressView show];
    [self.googleViewModel didSelectedPlace:indexPath];
}

@end

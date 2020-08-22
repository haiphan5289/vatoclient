//
//  FCShipServiceViewController.m
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCShipServiceViewController.h"
#import "FCShipServiceTableViewCell.h"

#define kCell @"FCShipServiceTableViewCell"

@interface FCShipServiceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FCShipServiceViewController {
    NSMutableArray* _listService;
    UITableViewCell* _currentCellSelect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCell
                                               bundle:nil]
         forCellReuseIdentifier:kCell];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.viewModel getListShipService:^(NSMutableArray *list) {
        _listService = list;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) closeView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) btnLeftClicked:(id)sender {
    [self closeView];
}

- (IBAction)doneClicked:(id)sender {
    [self closeView];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    FCShipServiceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCell
                                                                       forIndexPath:indexPath];
    FCShipService* service = [_listService objectAtIndex:indexPath.row];
    cell.service = service;
    cell.viewcontroller = self;
    if (service.id == self.viewModel.serviceSelected.id) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        _currentCellSelect = cell;
    }
    cell.lblName.text = service.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return _listService.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentCellSelect) {
        [_currentCellSelect setAccessoryType:UITableViewCellAccessoryNone];
        _currentCellSelect = nil;
    }
    self.viewModel.serviceSelected = [_listService objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
}

@end

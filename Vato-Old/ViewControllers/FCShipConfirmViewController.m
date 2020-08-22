//
//  FCShipConfirmViewController.m
//  FaceCar
//
//  Created by facecar on 3/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCShipConfirmViewController.h"
#import "FCShipServiceViewController.h"
#import "FacecarNavigationViewController.h"

@interface FCShipConfirmViewController ()

@end

@implementation FCShipConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[FCShipViewModel alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)cancelClicked:(id)sender {
    [self closeView];
}

- (IBAction)closeClicked:(id)sender {
    [self closeView];
}

- (IBAction)nextClicked:(id)sender {
    [self.homeViewModel loadConfirmBookingView];
}

- (void) closeView {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void) loadShipServiceView {
    FCShipServiceViewController* serVC = [[FCShipServiceViewController alloc] initViewController];
    serVC.viewModel = self.viewModel;
    [self.navigationController pushViewController:serVC
                                         animated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self loadShipServiceView];
    }
}
@end

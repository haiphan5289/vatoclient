//
//  FCWebViewController.m
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWebViewController.h"

@interface FCWebViewController ()<WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webview;
@property (strong, nonatomic) FCWebViewModel* viewModel;
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;

@end

@implementation FCWebViewController

- (instancetype) initViewWithViewModel:(FCWebViewModel *)viewModel {

    self = [self initWithNibName:@"FCWebViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.viewModel = viewModel;
    self.navigationItem.title = self.title;
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webview.navigationDelegate = self;
    _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_webview atIndex:0];
    [RACObserve(self.viewModel, url) subscribeNext:^(id x) {
        if (x)
            [self loadWebview:self.viewModel.url];
    }];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) loadWebview: (NSString*) url {
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

#pragma mark - Webview Delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.progressView show];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.progressView dismiss];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView dismiss];
}
@end

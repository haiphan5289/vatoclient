//
//  FCNewWebViewController.m
//  FC
//
//  Created by facecar on 6/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCNewWebViewController.h"
#import "UserDataHelper.h"
#import "UserDataHelper-Private.h"
@import WebKit;

@interface FCNewWebViewController () <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) WKWebView* wkWebview;
@end

@implementation FCNewWebViewController {
    BOOL _shouldDismiss;
    NSString* _currentUrl;
}

- (instancetype) init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblTitle.text = self.title;
    [self.progressView show];
    self.wkWebview = [[WKWebView alloc] init];
    self.wkWebview.frame = CGRectMake(0, 67, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 67);
    self.wkWebview.navigationDelegate = self;
    self.wkWebview.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.wkWebview];
}

- (void) loadWebview: (NSString*) url {
    _currentUrl = url;
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) loadWebviewWithConfigure:(FCLinkConfigure*) url {
    if (url.auth) {
        [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
            @try {
                NSString* link = [NSString stringWithFormat:@"%@?token=%@", url.url, token];
                NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                [cookieProperties setObject:@"x-access-token" forKey:NSHTTPCookieName];
                [cookieProperties setObject:token forKey:NSHTTPCookieValue];
                
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
                [self loadWebview:link];
            }
            @catch (NSException* e) {
                DLog(@"Error: %@", e)
            }
        }];
    }
    else {
        [self loadWebview:url.url];
    }
}

- (IBAction)closeClicked:(id)sender {
    _shouldDismiss = YES;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Webview Delegate
- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.progressView dismiss];
}

- (void) webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView dismiss];
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    DLog(@"Request: %@", navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
    if ([navigationAction.request.URL.absoluteString containsString:@"vato://token-expire"]) {
        if ([_currentUrl containsString:@"&#"]) {
            [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
                NSInteger index = [_currentUrl rangeOfString:@"&#"].location;
                _currentUrl = [_currentUrl substringToIndex:index+2];
                _currentUrl = [NSString stringWithFormat:@"%@%@", _currentUrl, token];
                [self loadWebview:_currentUrl];
            }];
        }
    }
}

- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedViewController || _shouldDismiss) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

@end

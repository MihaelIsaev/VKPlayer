//
//  LoginViewController.h
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "CommonHelper.h"
#import "AppDelegate.h"

@interface LoginViewController : NSViewController <NSApplicationDelegate, NSWindowDelegate>

@property (weak) IBOutlet WebView *webView;
@property (unsafe_unretained) IBOutlet NSWindow *window;
- (IBAction)showLoginWindow:(id)sender;

@end

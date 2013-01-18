//
//  LoginViewController.m
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize webView;
@synthesize window;

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    //NSLog(@"oloo");
}

-(void)applicationDidFinishLaunching:(NSNotification*) notification
{
    NSURL*url=[NSURL URLWithString:@"http://api.vk.com/oauth/authorize?client_id=3156439&redirect_uri=http://api.vk.com/blank.html&scope=audio,friends,status&display=page&response_type=token"];
    NSURLRequest*request=[NSURLRequest requestWithURL:url];
    self.webView.UIDelegate = self;
    [[self.webView mainFrame] loadRequest:request];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    //NSLog(@"webView didFinishLoadForFrame");
    
    WebDataSource *source = [frame dataSource];
    //NSData *data = [source data];
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSURL *ur = [[source initialRequest] URL];
    
    //NSLog(@"ur: %@", ur.absoluteString);
    
    if([CommonHelper containsString:@"http://api.vk.com/oauth/authorize?client_id=3156439&redirect_uri=http://api.vk.com/blank.html&scope=audio,friends,status&display=page&response_type=token" inString:ur.absoluteString] || [CommonHelper containsString:@"https://login.vk.com/?act=login&soft=1" inString:ur.absoluteString])
        [webView reload:self];
    
    [self checkToken:ur.absoluteString];
    
    /*if([CommonHelper containsString:@"access_token" inString:ur.absoluteString])
        NSLog(@"URL contains access_token");
    else
        NSLog(@"URL not contains access_token");*/
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame
{
    //NSLog(@"sex url: %@", URL.absoluteString);
    WebDataSource *source = [frame dataSource];
    NSData *data = [source data];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    
    // NSLog(@"connectionDidFinishLoading URL: %@", URL);
    //if([CommonHelper containsString:@"Login success" inString:str])
    //if([CommonHelper containsString:@"https://login.vk.com/?act=grant_access" inString:URL.absoluteString] || [CommonHelper containsString:@"https://login.vk.com/?act=login&soft=1" inString:URL.absoluteString])
        //[webView reload:self];
}

-(void)checkToken:(NSString*)urlString
{
    if ([CommonHelper containsString:@"access_token" inString:urlString]) {
        AppDelegate *ad = [[AppDelegate alloc] init];
        NSString *accessToken = [CommonHelper getStringBetweenTwoSymbols:urlString :@"access_token=" :@"&"];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [urlString componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"VKAccessUserId"];
            [ad saveString:user_id :@"userId"];
        }
        
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"VKAccessToken"];
            // Сохраняем дату получения токена. Параметр expires_in=86400 в ответе ВКонтакта, говорит сколько будет действовать токен.
            // В данном случае, это для примера, мы можем проверять позднее истек ли токен или нет
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"VKAccessTokenDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ad saveString:accessToken :@"accessToken"];
        }
        
        //NSLog(@"vkWebView response: %@",urlString);
        [self authComplete];
        //[self dismissModalViewControllerAnimated:YES];
    } else if ([CommonHelper containsString:@"error" inString:urlString]) {
        //NSLog(@"Error: %@", urlString);
        //[self dismissModalViewControllerAnimated:YES];
    }
}

-(void)authComplete
{
    //NSLog(@"auth complete");
    NSNib *secondNib = [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:nil];
    [secondNib instantiateNibWithOwner:self topLevelObjects:nil];
    [window close];
}

- (IBAction)showLoginWindow:(id)sender
{

}
@end

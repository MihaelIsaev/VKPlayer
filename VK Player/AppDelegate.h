//
//  AppDelegate.h
//  VK Player
//
//  Created by mihael on 01.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

+ (AppDelegate*)sharedInstance;

-(NSString*)retrieveString:(NSString*)key;
-(void)saveString:(NSString*)value:(NSString*)key;

@end

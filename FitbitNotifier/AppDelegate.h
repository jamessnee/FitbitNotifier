//
//  AppDelegate.h
//  FitbitNotifier
//
//  Created by James Snee on 11/12/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FitbitAPIConnection.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) IBOutlet NSMenuItem *statusMenuItem;
@property (strong, nonatomic) IBOutlet NSTextField *pinText;
@property (strong, nonatomic) NSString *steps;
@property (strong, nonatomic) NSTimer *backgroundTimer;

@property (strong, nonatomic) FitbitAPIConnection *apiConnection;

- (IBAction)goGetAccessToken:(id)sender;
- (void)updateStatus;
- (void)beginStatusCheck:(NSTimer *)timer;

@end

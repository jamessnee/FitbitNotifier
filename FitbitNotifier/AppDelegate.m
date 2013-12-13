//
//  AppDelegate.m
//  FitbitNotifier
//
//  Created by James Snee on 11/12/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *ico = [NSImage imageNamed:@"NotifIco.png"];
    [self.statusItem setImage:ico];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:self.statusMenu];
    
    self.apiConnection = [[FitbitAPIConnection alloc] init];
    if ([self.apiConnection signIn])
    {
        [self.window close];
        
        //  Update the step count for today
        [self.apiConnection getStepsForDate:[NSDate date]];
    }
}

- (void)updateStatus{
    NSString *status = [NSString stringWithFormat:@"Steps: %@",self.steps];
    [self.statusMenuItem setTitle:status];
    
    //  If there's no timer (i.e. this is the first time) start it
    if (!self.backgroundTimer)
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(beginStatusCheck:) userInfo:nil repeats:YES];
}

- (IBAction)goGetAccessToken:(id)sender
{
    [self.apiConnection setPin:[self.pinText stringValue]];
    [self.apiConnection getAccessToken];
    [self.apiConnection getStepsForDate:nil];
}

- (void)beginStatusCheck:(NSTimer *)timer
{
    [self.apiConnection getStepsForDate:[NSDate date]];
}

@end

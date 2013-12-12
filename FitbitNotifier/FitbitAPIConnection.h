//
//  FitbitAPIConnection.h
//  FitbitNotifier
//
//  Created by James Snee on 11/12/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

@interface FitbitAPIConnection : NSObject

@property (strong, nonatomic) OAToken *accessToken;
@property (strong, nonatomic) NSString *pin;

// External API
- (void)getStepsForDate:(NSDate *)date;
- (BOOL)signIn;

- (void)getRequestToken;
- (void)getAccessToken;

@end

//
// 
//  FitbitNotifier
//
//  Created by James Snee on 11/12/2013.
//  Copyright (c) 2013 James Snee. All rights reserved.
//

#import "FitbitAPIConnection.h"
#import "Constants.h"
#import "AppDelegate.h"

//  Much of this has come from a great example (project) by Rodrigo
//  from SharpCube.
//  http://rodrigo.sharpcube.com/2010/06/29/using-oauth-with-twitter-in-cocoa-objective-c/

@implementation FitbitAPIConnection

- (void)getStepsForDate:(NSDate *)date{
    if (!self.accessToken)
    {
        OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"com.jamessnee.fitbitnotifier" prefix:@"ACCESSTOKEN"];
        if (!token)
            NSLog(@"We shouldn't be here!");
        [self setAccessToken:token];
    }
    
    // Sort the date out
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"yyyy-MM-dd"];
    NSString *dateFixed = [dateForm stringFromDate:date];
    NSString *urlStr = [NSString stringWithFormat:@"http://api.fitbit.com/1/user/-/activities/date/%@.json",dateFixed];
    NSLog(@"%@",urlStr);
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey
                                                    secret:kConsumerSecret];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    NSURL *url = [NSURL URLWithString:urlStr];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
}

#pragma mark - Signing In

- (BOOL)signIn
{
    if (!self.accessToken)
    {
        OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"com.jamessnee.fitbitnotifier" prefix:@"ACCESSTOKEN"];
        if (token)
        {
            [self setAccessToken:token];
            return YES;
        }
    }
    [self getRequestToken];
    return NO;
}

- (void)getRequestToken
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey
													secret:kConsumerSecret];
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	NSURL *url = [NSURL URLWithString:kRequestTokenURL];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:nil
																	  realm:nil
														  signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	NSLog(@"Getting request token... %@",request);
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void)getAccessToken
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey
													secret:kConsumerSecret];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	NSURL *url = [NSURL URLWithString:kAccessTokenURL];
	
	[self.accessToken setVerifier:self.pin];
	NSLog(@"Using PIN %@", self.accessToken.verifier);
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:self.accessToken
																	  realm:nil
														  signatureProvider:nil];
	
	[request setHTTPMethod:@"POST"];
	
	NSLog(@"Getting access token... %@", request);
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}

#pragma mark - Callbacks
//  Request Token
- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
		NSLog(@"Got request token. Redirecting to Fitbit auth page... %@",self.accessToken.key);
		
		NSString *address = [NSString stringWithFormat:
							 @"%@?oauth_token=%@",
							 kAuthorizeURL,self.accessToken.key];
		
		NSURL *url = [NSURL URLWithString:address];
		[[NSWorkspace sharedWorkspace] openURL:url];
        [NSApp activateIgnoringOtherApps:YES];
	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting request token failed: %@", [error localizedDescription]);
}

//  Access Token
- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        //  Store the Access Token in the user's keychain
		[self.accessToken storeInUserDefaultsWithServiceProviderName:@"com.jamessnee.fitbitnotifier" prefix:@"ACCESSTOKEN"];
        
		NSLog(@"Got access token. Ready to use Fitbit API.");
	}
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting access token failed: %@", [error localizedDescription]);
}

//  API Callback
- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
        if (data)
        {
            NSError *error;
            id objJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error)
            {
                NSLog(@"There was an error parsing the JSON");
                return;
            }
            
            if ([objJson isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *response = (NSDictionary *)objJson;
                NSDictionary *summary = (NSDictionary *) [response objectForKey:@"summary"];
                NSNumber *steps = [summary objectForKey:@"steps"];
                
                AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
                [delegate setSteps:[steps stringValue]];
                [delegate updateStatus];
            }
        }
        
	}
}

- (void) apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting home timeline failed: %@", [error localizedDescription]);
}

@end

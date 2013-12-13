FitbitNotifier
==============
I was annoyed that I couldn't view or update my Fitbit status when on my Mac, without having to go to the Fitbit website. So this is a small app that creates a status bar menu item and connects to the Fitbit api http://dev.fitbit.com to retrieve your step count for that day.

The OAuth is handled by the brilliant oauthconsumer library (https://code.google.com/p/oauthconsumer/wiki/UsingOAuthConsumer). Much of the implementation was taken from an example here: http://rodrigo.sharpcube.com/2010/06/29/using-oauth-with-twitter-in-cocoa-objective-c/

TODO:
* A much better icon needed...
* A timer to periodically retireve the updated step count. 
  * Currently this is only done on startup
* Allow stats to be updated - for example a one button click when you drink a glass of water.

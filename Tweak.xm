#include "headers.h"
#import <notify.h>
#import "TCMediaNotificationController.h"

@interface SBMediaController : NSObject
@property (nonatomic, retain) TCMediaNotificationController *musicNotifController;
+ (id)sharedInstance;
- (BOOL)isPlaying;
- (id) nowPlayingApplication;
@end

// ---------------------------------------------

%hook SBMediaController
%property (nonatomic, retain) TCMediaNotificationController *musicNotifController;
-(id) init {
    if ((self = %orig)){
        self.musicNotifController = [TCMediaNotificationController sharedInstance];
    }
    return self;
}
%end

%hook NCNotificationCombinedListViewController
-(BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2{
    if(request.categoryIdentifier && [request.categoryIdentifier isEqualToString: @"StrawMedia"]){
        return 0;
    } else {
        return %orig;
    }
}
%end

// Preference Bundle stuff
%ctor {
    // Fix rejailbreak bug
    if (![NSBundle.mainBundle.bundleURL.lastPathComponent.pathExtension isEqualToString:@"app"]) {
        return;
    }
    HBPreferences *settings = [[HBPreferences alloc] initWithIdentifier:@"com.thecasle.strawpref"];
    [settings registerDefaults:@{
                                 @"tweakEnabled": @YES,
                                 }];
    BOOL tweakEnabled = [settings boolForKey:@"tweakEnabled"];
    
    if(tweakEnabled) {
        %init;
    }
}

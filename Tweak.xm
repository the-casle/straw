#include "headers.h"
#import <notify.h>
#import "TCMediaNotificationController.h"

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPlaying;
- (id) nowPlayingApplication;
@end

// ---------------------------------------------

%hook SBMediaController
-(id) init {
    if ((self = %orig)){
        static TCMediaNotificationController *notifController = NULL;
        if (!notifController) {
            notifController = [TCMediaNotificationController sharedInstance];
        }
    }
    return self;
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
    
    // from https://github.com/limneos/libbulletin/blob/master/Tweak.xm
    [[NSNotificationCenter defaultCenter] addObserverForName: @"WALockscreenWidgetWillAppearNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        
        // Purge cached lockscreen bulletins like SBLockScreenNotificationListController does upon unlock
        
        static int screenChangedToken=0;
        static BOOL isRemoving=NO;
        
        if (!screenChangedToken){
            notify_register_check("com.apple.springboard.screenchanged",&screenChangedToken);
        }
        uint64_t state;
        notify_get_state(screenChangedToken, &state);
        
        if (((int)state==0 || (int)state==1 || (int)state==2 || (int)state==3) && !isRemoving){
            
            isRemoving=YES;
            
            [[[%c(JBBulletinManager) sharedInstance] bundleImagesForIDs] removeAllObjects];
            
            SBLockScreenNotificationListController *lockScreenNotificationListController=[[%c(JBBulletinManager) sharedInstance] notificationController];
            
            for (int i=0; i< [[[%c(JBBulletinManager) sharedInstance] cachedLockscreenBulletins] count]; i++){
                BBBulletin *bulletin=[[[%c(JBBulletinManager) sharedInstance] cachedLockscreenBulletins] objectAtIndex:i];
                BBObserver *observer=[lockScreenNotificationListController valueForKey:@"observer"];
                [[[%c(JBBulletinManager) sharedInstance] cachedLockscreenBulletins] removeObject:bulletin];
                [lockScreenNotificationListController observer:observer removeBulletin:bulletin];
                i--;
            }
            
            isRemoving=NO;
            
        }
    }];
}

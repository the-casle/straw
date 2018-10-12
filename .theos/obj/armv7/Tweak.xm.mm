#line 1 "Tweak.xm"
#include "headers.h"
#import <notify.h>
#import "TCMediaNotificationController.h"

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPlaying;
- (id) nowPlayingApplication;
@end




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBMediaController; @class JBBulletinManager; 
static SBMediaController* (*_logos_orig$_ungrouped$SBMediaController$init)(_LOGOS_SELF_TYPE_INIT SBMediaController*, SEL) _LOGOS_RETURN_RETAINED; static SBMediaController* _logos_method$_ungrouped$SBMediaController$init(_LOGOS_SELF_TYPE_INIT SBMediaController*, SEL) _LOGOS_RETURN_RETAINED; 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$JBBulletinManager(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("JBBulletinManager"); } return _klass; }
#line 13 "Tweak.xm"

static SBMediaController* _logos_method$_ungrouped$SBMediaController$init(_LOGOS_SELF_TYPE_INIT SBMediaController* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    if ((self = _logos_orig$_ungrouped$SBMediaController$init(self, _cmd))){
        static TCMediaNotificationController *notifController = NULL;
        if (!notifController) {
            notifController = [TCMediaNotificationController sharedInstance];
        }
    }
    return self;
}



static __attribute__((constructor)) void _logosLocalCtor_b3e0c1f1(int __unused argc, char __unused **argv, char __unused **envp) {
    
    if (![NSBundle.mainBundle.bundleURL.lastPathComponent.pathExtension isEqualToString:@"app"]) {
        return;
    }
    HBPreferences *settings = [[HBPreferences alloc] initWithIdentifier:@"com.thecasle.strawpref"];
    [settings registerDefaults:@{
                                 @"tweakEnabled": @YES,
                                 }];
    BOOL tweakEnabled = [settings boolForKey:@"tweakEnabled"];
    
    if(tweakEnabled) {
        {Class _logos_class$_ungrouped$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$_ungrouped$SBMediaController, @selector(init), (IMP)&_logos_method$_ungrouped$SBMediaController$init, (IMP*)&_logos_orig$_ungrouped$SBMediaController$init);}
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName: @"WALockscreenWidgetWillAppearNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        
        
        
        static int screenChangedToken=0;
        static BOOL isRemoving=NO;
        
        if (!screenChangedToken){
            notify_register_check("com.apple.springboard.screenchanged",&screenChangedToken);
        }
        uint64_t state;
        notify_get_state(screenChangedToken, &state);
        
        if (((int)state==0 || (int)state==1 || (int)state==2 || (int)state==3) && !isRemoving){
            
            isRemoving=YES;
            
            [[[_logos_static_class_lookup$JBBulletinManager() sharedInstance] bundleImagesForIDs] removeAllObjects];
            
            SBLockScreenNotificationListController *lockScreenNotificationListController=[[_logos_static_class_lookup$JBBulletinManager() sharedInstance] notificationController];
            
            for (int i=0; i< [[[_logos_static_class_lookup$JBBulletinManager() sharedInstance] cachedLockscreenBulletins] count]; i++){
                BBBulletin *bulletin=[[[_logos_static_class_lookup$JBBulletinManager() sharedInstance] cachedLockscreenBulletins] objectAtIndex:i];
                BBObserver *observer=[lockScreenNotificationListController valueForKey:@"observer"];
                [[[_logos_static_class_lookup$JBBulletinManager() sharedInstance] cachedLockscreenBulletins] removeObject:bulletin];
                [lockScreenNotificationListController observer:observer removeBulletin:bulletin];
                i--;
            }
            
            isRemoving=NO;
            
        }
    }];
}

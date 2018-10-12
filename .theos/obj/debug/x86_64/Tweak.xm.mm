#line 1 "Tweak.xm"
#include "headers.h"

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

@class SBMediaController; 
static SBMediaController* (*_logos_orig$_ungrouped$SBMediaController$init)(_LOGOS_SELF_TYPE_INIT SBMediaController*, SEL) _LOGOS_RETURN_RETAINED; static SBMediaController* _logos_method$_ungrouped$SBMediaController$init(_LOGOS_SELF_TYPE_INIT SBMediaController*, SEL) _LOGOS_RETURN_RETAINED; 

#line 13 "Tweak.xm"

static SBMediaController* _logos_method$_ungrouped$SBMediaController$init(_LOGOS_SELF_TYPE_INIT SBMediaController* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
    if ((self = _logos_orig$_ungrouped$SBMediaController$init(self, _cmd))){
        static TCMediaNotificationController *notifController = NULL;
        if (!notifController) {
            notifController = [[TCMediaNotificationController alloc] init];
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
}

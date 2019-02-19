#include "headers.h"

#import "TCMediaNotificationController.h"
#import <AudioToolbox/AudioToolbox.h>

// thanks mr squid
extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);
/*
static void hapticFeedbackSoft(){
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:[NSNumber numberWithBool:YES]];
    [arr addObject:[NSNumber numberWithInt:30]];
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}
*/
static void hapticFeedbackHard(){
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:[NSNumber numberWithBool:YES]];
    [arr addObject:[NSNumber numberWithInt:30]];
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"Intensity"];
    AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
}


@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end

@interface SBBacklightController : NSObject
@property (nonatomic, readonly) BOOL screenIsOn;
+(id)sharedInstance;
@end

@interface SpringBoard (straw)
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end

//----------------------------------------------------------------

static BOOL playingNotification;
static BOOL lockNotification;
static BOOL wakeScreenNotification;
static NSInteger modeHaptic;

@implementation TCMediaNotificationController {


}

static void postNotification(NSString *title, NSString *message, NSString *sectionID) {
    BBBulletinRequest *bulletin = [[objc_getClass("BBBulletinRequest") alloc] init];
    
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);

    bulletin.section = sectionID;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = uuidStr;
    bulletin.bulletinVersionID = uuidStr;
    bulletin.recordID = uuidStr;
    bulletin.publisherBulletinID=[NSString stringWithFormat:@"-bulletin-manager-%@",uuidStr];
    bulletin.categoryID = @"StrawMedia";
    bulletin.title = title;
    bulletin.message = message;
    
    bulletin.date=[NSDate date] ;
    bulletin.lastInterruptDate=[NSDate date] ;
    [bulletin setClearable:YES];
    
    if (sectionID){
        BBAction *defaultAction = [objc_getClass("BBAction") actionWithLaunchBundleID:sectionID callblock:nil];
        [bulletin setDefaultAction:defaultAction];
    }
    SBLockScreenNotificationListController *listController = ([[objc_getClass("UIApplication") sharedApplication] respondsToSelector:@selector(notificationDispatcher)] && [[[objc_getClass("UIApplication") sharedApplication] notificationDispatcher] respondsToSelector:@selector(notificationSource)]) ? [[[objc_getClass("UIApplication") sharedApplication] notificationDispatcher] notificationSource]  : [[[objc_getClass("SBLockScreenManager") sharedInstanceIfExists] lockScreenViewController] valueForKey:@"notificationController"];
    [listController observer:[listController valueForKey:@"observer"] addBulletin:bulletin forFeed:14];
}

// The custom method that will receive the notification
static void updateNotificationLabel(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *nameOfNotification = (__bridge NSString*)name;
    
    if([nameOfNotification isEqualToString:@"com.apple.springboard.nowPlayingAppChanged"])
    {
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
            SBApplication *nowPlayingApp = [[objc_getClass("SBMediaController") sharedInstance] nowPlayingApplication];
            NSString *appBundleId = nowPlayingApp.bundleIdentifier;
            SpringBoard *sb = (SpringBoard *)[objc_getClass("SpringBoard") sharedApplication];
            
            NSDictionary *musicDict = (__bridge NSDictionary *)result;
            NSString *songName = musicDict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
            NSString *artistName = musicDict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
            NSString *albumName = musicDict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
            
            // check to make sure everything exists
            if (!songName && !artistName && !albumName) {
                return;
            }
            
            // prevent repeat bulletin
            if(songName && [songName isEqualToString: [TCMediaNotificationController sharedInstance].lastSongName]){
                return;
            }
            
            [TCMediaNotificationController sharedInstance].lastSongName = songName;
            
            if(((int)modeHaptic) == 0){
                // nothing lol
            } else if(((int)modeHaptic) == 1){
                BOOL screenIsOn = [[objc_getClass("SBBacklightController") sharedInstance] screenIsOn];
                if(!screenIsOn){
                    hapticFeedbackHard();
                }
                
            } else if(((int)modeHaptic) == 2){
                hapticFeedbackHard();
            }
            
            if(wakeScreenNotification){
                BOOL screenIsOn = [[objc_getClass("SBBacklightController") sharedInstance] screenIsOn];
                if(!screenIsOn){
                    [sb _simulateHomeButtonPress];
                }
            }
            
            if(lockNotification){
                if (sb.isLocked){
                    return;
                }
            }
            
            if(playingNotification && !sb.isLocked){
                SBApplication *currentApp = [sb _accessibilityFrontMostApplication];
                if (currentApp == nowPlayingApp){
                    return;
                }
            }
            
            // check if apple music, otherwise do else
            if([appBundleId isEqualToString:@"com.apple.Music"]){
                if(songName && artistName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@ — %@", artistName, albumName];
                    postNotification(songName, message, appBundleId);
                } else if(songName && artistName){
                    NSString * message = [NSString stringWithFormat:@"%@", artistName];
                    postNotification(songName, message, appBundleId);
                } else if (songName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@", albumName];
                    postNotification(songName, message, appBundleId);
                } else if (artistName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@", albumName];
                    postNotification(@"Unknown", message, appBundleId);
                } else if(songName){
                    postNotification(songName, @"", appBundleId);
                } else if(artistName){
                    postNotification(artistName, @"", appBundleId);
                }else if(albumName){
                    postNotification(albumName, @"", appBundleId);
                }
            } else {
                if(songName && artistName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@\n%@ — %@", songName, artistName, albumName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(songName && artistName){
                    NSString * message = [NSString stringWithFormat:@"%@\n%@", songName, artistName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(songName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@\n%@", songName, albumName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(artistName && albumName){
                    NSString * message = [NSString stringWithFormat:@"%@ — %@", artistName, albumName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(songName){
                    NSString * message = [NSString stringWithFormat:@"%@", songName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(artistName){
                    NSString * message = [NSString stringWithFormat:@"%@", artistName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                } else if(albumName){
                    NSString * message = [NSString stringWithFormat:@"%@", albumName];
                    postNotification(nowPlayingApp.displayName, message, appBundleId);
                }
            }
        });
    }
}

- (instancetype) init{
    if(self = [super init]){
        //NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
        //[notifCenter addObserver:self selector:@selector(updateNotificationLabel:) name:@"NScom.apple.springboard.nowPlayingAppChanged" object:NULL];
        
        // load preferences
        HBPreferences *settings = [[HBPreferences alloc] initWithIdentifier:@"com.thecasle.strawpref"];
        [settings registerDefaults:@{
                                     @"appDisabled": @NO,
                                     @"lockDisabled": @NO,
                                     @"wakeEnabled": @NO,
                                     @"hapticMode": @"0"
                                     }];
        playingNotification = [settings boolForKey:@"appDisabled"];
        lockNotification = [settings boolForKey:@"lockDisabled"];
        wakeScreenNotification = [settings boolForKey:@"wakeEnabled"];
        modeHaptic = ((NSInteger)((NSString *)[settings objectForKey:@"hapticMode"]).intValue);
        
        
        NSString *notificationName = @"com.apple.springboard.nowPlayingAppChanged";
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        updateNotificationLabel,
                                        (__bridge CFStringRef)notificationName,
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}
+ (instancetype)sharedInstance {
    static TCMediaNotificationController *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCMediaNotificationController alloc] init];
    });
    
    return sharedInstance;
}
@end

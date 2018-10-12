#import <Foundation/Foundation.h>

@interface TCMediaNotificationController : NSObject
@property (nonatomic, retain) NSString *lastSongName;
+ (instancetype)sharedInstance;
@end

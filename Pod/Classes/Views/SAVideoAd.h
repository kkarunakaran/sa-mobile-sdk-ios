//
//  SAVideoAd2.h
//  Pods
//
//  Created by Gabriel Coman on 01/09/2016.
//
//

#import <UIKit/UIKit.h>
#import "SAProtocol.h"

@interface SAVideoAd : UIViewController

// static "action" methods
+ (void) load:(NSInteger) placementId;
+ (void) play;
+ (BOOL) hasAdAvailable;

// static "state" methods
+ (void) setDelegate:(id<SAProtocol>) del;
+ (void) setIsParentalGateEnabled: (BOOL) value;
+ (void) setShouldAutomaticallyCloseAtEnd: (BOOL) value;
+ (void) setShouldShowCloseButton: (BOOL) value;
+ (void) setShouldLockOrientation: (BOOL) value;
+ (void) setShouldShowSmallClickButton: (BOOL) value;
+ (void) setLockOrientation: (NSUInteger) value;
+ (void) setTestEnabled;
+ (void) setTestDisabled;
+ (void) setConfigurationProduction;
+ (void) setConfigurationStaging;

@end

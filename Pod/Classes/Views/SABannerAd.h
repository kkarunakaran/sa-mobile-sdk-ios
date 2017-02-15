/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>
#import "SACallback.h"

@class SAAd;

/**
 * Class that abstracts away the process of loading & displaying
 * an Banner type Ad.
 * A subclass of the iOS "UIView" class.
 */
@interface SABannerAd : UIView

/**
 * Method that loads an ad into the queue.
 * Ads can only be loaded once and then can be reloaded after they've
 * been played.
 *
 * @param placementId   the Ad placement id to load data for
 */
- (void) load:(NSInteger)placementId;

/**
 * Method that, if an ad data is loaded, will play
 * the content for the user
 * */
- (void) play;

/**
 * Method that returns whether ad data for a certain placement
 * has already been loaded
 *
 * @return              true or false
 */
- (BOOL) hasAdAvailable;

/**
 * Method that is called to close the ad
 */
- (void) close;

/**
 * Method that resizes the ad object
 *
 * @param frame the new frame to resize to
 */
- (void) resize:(CGRect)toframe;


/**
 * Method that gets whether the banner is closed or not
 */
- (BOOL) isClosed;

/**
 * Group of methods that set ad configuration parameters
 */
- (void) setCallback:(sacallback)callback;
- (void) enableParentalGate;
- (void) disableParentalGate;
- (void) enableTestMode;
- (void) disableTestMode;
- (void) setConfigurationProduction;
- (void) setConfigurationStaging;
- (void) setColorTransparent;
- (void) setColorGray;
- (void) setTestMode: (BOOL) value;
- (void) setParentalGate: (BOOL) value;
- (void) setConfiguration: (NSInteger) value;
- (void) setColor: (BOOL) value;

@end

/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAMoPubInterstitialCustomEvent.h"
#import "AwesomeAds.h"
#import "SASession.h"
#import "SAMoPub.h"
#import "NSDictionary+SafeHandling.h"

#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"
#import "SAMedia.h"

@interface SAMoPubInterstitialCustomEvent ()
@property (nonatomic, assign) NSInteger placementId;
@end

@implementation SAMoPubInterstitialCustomEvent

/**
 * Overridden MoPub method that requests a new interstitial.
 *
 * @param info a dictionary of extra information passed down from MoPub to the
 *             SDK that help with loading the ad
 */
- (void) requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    
    _placementId = [[info safeObjectForKey:PLACEMENT_ID orDefault:@(SA_DEFAULT_PLACEMENTID)] integerValue];
    BOOL isTestEnabled = [[info safeObjectForKey:TEST_ENABLED orDefault:@(SA_DEFAULT_TESTMODE)] boolValue];
    BOOL isParentalGateEnabled = [[info safeObjectForKey:PARENTAL_GATE orDefault:@(SA_DEFAULT_PARENTALGATE)] boolValue];
    BOOL isBumperPageEnabled = [[info safeObjectForKey:BUMPER_PAGE orDefault:@(SA_DEFAULT_BUMPERPAGE)] boolValue];
    SAOrientation orientation = SA_DEFAULT_ORIENTATION;
    
    NSString *ori = [info safeStringForKey:ORIENTATION];
    if (ori != nil && [ori isEqualToString:@"PORTRAIT"]) {
        orientation = PORTRAIT;
    }
    if (ori != nil && [ori isEqualToString:@"LANDSCAPE"]) {
        orientation = LANDSCAPE;
    }
    
    SAConfiguration configuration = SA_DEFAULT_CONFIGURATION;
    
    NSString *conf = [info safeStringForKey:CONFIGURATION];
    if (conf != nil && [conf isEqualToString:@"STAGING"]) {
        configuration = STAGING;
    }
    
    // get a weak self reference
    __weak typeof (self) weakSelf = self;
    
    // start the loader
    [SAInterstitialAd setConfiguration:configuration];
    [SAInterstitialAd setTestMode:isTestEnabled];
    [SAInterstitialAd setParentalGate:isParentalGateEnabled];
    [SAInterstitialAd setBumperPage:isBumperPageEnabled];
    [SAInterstitialAd setOrientation:orientation];
    
    [SAInterstitialAd setCallback:^(NSInteger placementId, SAEvent event) {
        switch (event) {
            case adLoaded: {
                
                SAAd *ad = [SAInterstitialAd getAd:placementId];
                NSString *html = NULL;
                if (ad != NULL) {
                    html = ad.creative.details.media.html;
                }
                BOOL isEmpty = html != NULL && [html rangeOfString:@"mopub://failLoad"].location != NSNotFound;
                
                if (isEmpty) {
                    [weakSelf.delegate interstitialCustomEvent:weakSelf
                                      didFailToLoadAdWithError:[weakSelf createErrorWith:ERROR_LOAD_TITLE(@"Interstitial Ad", placementId)
                                                                               andReason:ERROR_LOAD_MESSAGE
                                                                           andSuggestion:ERROR_LOAD_SUGGESTION]];
                } else {
                    [weakSelf.delegate interstitialCustomEvent:weakSelf didLoadAd:[SAInterstitialAd self]];
                }
                
                break;
            }
            case adAlreadyLoaded:{
                // do nothing
                break;
            }
            case adEmpty: {
                [weakSelf.delegate interstitialCustomEvent:weakSelf
                                  didFailToLoadAdWithError:[weakSelf createErrorWith:ERROR_LOAD_TITLE(@"Interstitial Ad", placementId)
                                                                           andReason:ERROR_LOAD_MESSAGE
                                                                       andSuggestion:ERROR_LOAD_SUGGESTION]];
                break;
            }
            case adFailedToLoad: {
                [weakSelf.delegate interstitialCustomEvent:weakSelf
                                  didFailToLoadAdWithError:[weakSelf createErrorWith:ERROR_LOAD_TITLE(@"Interstitial Ad", placementId)
                                                                           andReason:ERROR_NETWORK_MESSAGE
                                                                       andSuggestion:ERROR_NETWORK_SUGGESTION]];
                break;
            }
            case adShown: {
                [weakSelf.delegate interstitialCustomEventDidAppear:weakSelf];
                break;
            }
            case adFailedToShow: {
                [weakSelf.delegate interstitialCustomEvent:weakSelf
                                  didFailToLoadAdWithError:[weakSelf createErrorWith:ERROR_SHOW_TITLE(@"Interstitial Ad", 0)
                                                                           andReason:ERROR_SHOW_MESSAGE
                                                                       andSuggestion:ERROR_SHOW_SUGGESTION]];
                break;
            }
            case adClicked: {
                [weakSelf.delegate interstitialCustomEventDidReceiveTapEvent:weakSelf];
                [weakSelf.delegate interstitialCustomEventWillLeaveApplication:weakSelf];
                break;
            }
            case adEnded: {
                // do nothing
                break;
            }
            case adClosed: {
                [weakSelf.delegate interstitialCustomEventWillDisappear:weakSelf];
                [weakSelf.delegate interstitialCustomEventDidDisappear:weakSelf];
                break;
            }
        }
    }];
    
    // load
    [SAInterstitialAd load:_placementId];
}

/**
 * Overridden MoPub method that actually displays an interstitial ad.
 *
 * @param rootViewController the view controller from which the ad will spring
 */
- (void) showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [SAInterstitialAd play:_placementId
                    fromVC:rootViewController];
    [self.delegate interstitialCustomEventWillAppear:self];
}

/**
 * MoPub method that creates a new error obkect
 *
 * @param description   the description text of the error
 * @param reason        a reason for why it might have happened
 * @param suggestion    a suggestion of how to fix it
 */
- (NSError*) createErrorWith:(NSString*) description
                   andReason:(NSString*) reason
               andSuggestion:(NSString*) suggestion {
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_CODE userInfo:userInfo];
}

@end

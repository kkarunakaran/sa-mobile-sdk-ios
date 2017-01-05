//
//  SAUnityInterstitialAd.c
//  Pods
//
//  Created by Gabriel Coman on 05/01/2017.
//
//

#import <UIKit/UIKit.h>

#if defined(__has_include)
#if __has_include("SuperAwesomeSDKUnity.h")
#import "SuperAwesomeSDKUnity.h"
#else
#import "SuperAwesome.h"
#endif
#endif

#if defined(__has_include)
#if __has_include(<SASession/SASession.h>)
#import <SASession/SASession.h>
#else
#import "SASession.h"
#endif
#endif

#import "SAUnityCallback.h"

extern "C" {
    
    /**
     *  Methid that adds a callback to the SAInterstitialAd static method class
     */
    void SuperAwesomeUnitySAInterstitialAdCreate () {
        [SAInterstitialAd setCallback:^(NSInteger placementId, SAEvent event) {
            switch (event) {
                case adLoaded: sendToUnity(@"SAInterstitialAd", placementId, @"adLoaded"); break;
                case adFailedToLoad: sendToUnity(@"SAInterstitialAd", placementId, @"adFailedToLoad"); break;
                case adShown: sendToUnity(@"SAInterstitialAd", placementId, @"adShown"); break;
                case adFailedToShow: sendToUnity(@"SAInterstitialAd", placementId, @"adFailedToShow"); break;
                case adClicked: sendToUnity(@"SAInterstitialAd", placementId, @"adClicked"); break;
                case adClosed: sendToUnity(@"SAInterstitialAd", placementId, @"adClosed"); break;
            }
        }];
        
    }
    
    /**
     *  Load an interstitial ad
     *
     *  @param placementId   the placement id to try to load an ad for
     *  @param configuration production = 0 / staging = 1
     *  @param test          true / false
     */
    void SuperAwesomeUnitySAInterstitialAdLoad (int placementId, int configuration, bool test) {
        [SAInterstitialAd setTestMode:test];
        [SAInterstitialAd setConfiguration:getConfigurationFromInt(configuration)];
        [SAInterstitialAd load: placementId];
    }
    
    /**
     *  Check to see if there's an ad available
     *
     *  @return true / false
     */
    bool SuperAwesomeUnitySAInterstitialAdHasAdAvailable(int placementId) {
        return [SAInterstitialAd hasAdAvailable: placementId];
    }
    
    /**
     *  Play an interstitial ad
     *
     *  @param isParentalGateEnabled true / false
     *  @param shouldLockOrientation true / false
     *  @param lockOrientation       ANY = 0 / PORTRAIT = 1 / LANDSCAPE = 2
     */
    void SuperAwesomeUnitySAInterstitialAdPlay (int placementId, bool isParentalGateEnabled, int orientation) {
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [SAInterstitialAd setParentalGate:isParentalGateEnabled];
        [SAInterstitialAd setOrientation:getOrientationFromInt (orientation)];
        [SAInterstitialAd play: placementId fromVC: root];
    }
    
}
//
//  SAVideoAd.m
//  Pods
//
//  Created by Gabriel Coman on 20/10/2015.
//
//

#import "SAVideoAd.h"

// import video stuff
#import <AVFoundation/AVFoundation.h>
#import "IMAAdsLoader.h"
#import "IMAAdsManager.h"
#import "IMAAVPlayerContentPlayhead.h"
#import "IMAAdDisplayContainer.h"

// import models
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"
#import "SASender.h"

// import utils
#import "UIViewController+Utils.h"

@interface SAView ()
- (void) display;
- (void) clickOnAd;
- (void) createPadlockButtonWithParent:(UIView *)parent;
- (void) removePadlockButtonFromParent;
@end

@interface SAVideoAd () <IMAAdsLoaderDelegate, IMAAdsManagerDelegate>

// views
@property (nonatomic, strong) AVPlayer *contentPlayer;

// google specific stuff
@property (nonatomic, strong) IMAAdsLoader *adsLoader;
@property (nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;
@property (nonatomic, strong) IMAAdsManager *adsManager;

// notif center
@property (nonatomic, strong) NSNotificationCenter *notifCenter;

@end

@implementation SAVideoAd

- (id) initWithPlacementId:(NSInteger)placementId andFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        super.placementId = placementId;
        _notifCenter = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

// specific to the halfscreen view
- (void) didMoveToWindow {
    if (super.playInstantly) {
        [self playInstant];
    }
}

- (void) display {
    [super display];
    
    // setup content player
//    NSURL *contentURL = [NSURL URLWithString:ad.creative.details.video];
//    _contentPlayer = [AVPlayer playerWithURL:contentURL];
//    
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_contentPlayer];
//    playerLayer.frame = self.layer.bounds;
//    [self.layer addSublayer:playerLayer];
    
    // setup ads loader
    _adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    _adsLoader.delegate = self;
    
    // request ads
    IMAAdDisplayContainer *adDisplayContainer = [[IMAAdDisplayContainer alloc] initWithAdContainer:self companionSlots:nil];
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:ad.creative.details.vast adDisplayContainer:adDisplayContainer userContext:nil];
    [_adsLoader requestAdsWithRequest:request];
}

#pragma mark SAVideoAd functions

- (void) createContentPlayhead {
    _contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:_contentPlayer];
    [_notifCenter addObserver:self selector:@selector(contentDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_contentPlayer currentItem]];
}

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // end of content
    if (notification.object == _contentPlayer.currentItem) {
        NSLog(@"AD HAS ENDED");
        [_adsLoader contentComplete];
    }
}

#pragma mark AdsLoader Delegate

- (void) adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    _adsManager = adsLoadedData.adsManager;
    _adsManager.delegate = self;
    
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = [UIViewController currentViewController];
    [self createContentPlayhead];
    [_adsManager initializeWithContentPlayhead:_contentPlayhead adsRenderingSettings:adsRenderingSettings];
}

- (void) adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    [_contentPlayer play];
}

#pragma mark AdsManager Delegate

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    switch (event.type) {
        case kIMAAdEvent_LOADED: {
            
            [adsManager start];
            
            break;
        }
        case kIMAAdEvent_STARTED:{
            
            [SASender postEventViewableImpression:ad];
            
            if ([super.delegate respondsToSelector:@selector(adWasShown:)]) {
                [super.delegate adWasShown:ad.placementId];
            }
            
            if ([_videoDelegate respondsToSelector:@selector(videoStarted:)]) {
                [_videoDelegate videoStarted:ad.placementId];
            }
            
            break;
        }
        case kIMAAdEvent_FIRST_QUARTILE:{
            
            if ([_videoDelegate respondsToSelector:@selector(videoReachedFirstQuartile:)]){
                [_videoDelegate videoReachedFirstQuartile:ad.placementId];
            }
            
            break;
        }
        case kIMAAdEvent_MIDPOINT: {
            
            if ([_videoDelegate respondsToSelector:@selector(videoReachedMidpoint:)]) {
                [_videoDelegate videoReachedMidpoint:ad.placementId];
            }
            
            break;
        }
        case kIMAAdEvent_THIRD_QUARTILE:{
            
            if ([_videoDelegate respondsToSelector:@selector(videoReachedThirdQuartile:)]) {
                [_videoDelegate videoReachedThirdQuartile:ad.placementId];
            }
            
            break;
        }
        case kIMAAdEvent_COMPLETE:{
            
            if ([_videoDelegate respondsToSelector:@selector(videoEnded:)]) {
                [_videoDelegate videoEnded:ad.placementId];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    [_contentPlayer play];
    
    [SASender postEventAdFailedToView:ad];
    
    if ([super.delegate respondsToSelector:@selector(adFailedToShow:)]) {
        [super.delegate adFailedToShow:ad.placementId];
    }
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    [_contentPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    [_contentPlayer play];
}

@end

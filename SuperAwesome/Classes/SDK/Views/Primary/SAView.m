//
//  SAView.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 12/10/2015.
//
//

#import "SAView.h"

// import model
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"

// import subview
#import "SAParentalGate.h"
#import "SAPadlock.h"

#import "SAURLUtils.h"
#import "SASender.h"

@implementation SAView

// overwriting init functions
- (id) init {
    if (self = [super init]) {
        _isParentalGateEnabled = NO;
        _refreshPeriod = 30;
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isParentalGateEnabled = NO;
        _refreshPeriod = 30;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _isParentalGateEnabled = NO;
        _refreshPeriod = 30;
        
    }
    
    return self;
}

#pragma mark Playing and displaying

- (void) play {
    // init the pad
    gate = [[SAParentalGate alloc] initWithWeakRefToView:self];
    gate.delegate = _parentalGateDelegate;
    pad = [[SAPadlock alloc] initWithWeakRefToView:self];
}


#pragma mark Click Handling

- (void) tryToGoToURL:(NSURL*)url {
    
    if (!_ad.creative.isFullClickURLReliable){
        _ad.creative.fullClickURL = [url absoluteString];
    }
    
    if (_isParentalGateEnabled) {
        // send an event
        [SASender sendEventToURL:_ad.creative.parentalGateClickURL];
        
        // show the gate
        [gate show];
    } else {
        [self advanceToClick];
    }
}

- (void) advanceToClick {
    NSLog(@"[AA :: INFO] Going to %@", _ad.creative.fullClickURL);
    
    // call delegate
    if (_adDelegate && [_adDelegate respondsToSelector:@selector(adWasClicked:)]) {
        [_adDelegate adWasClicked:_ad.placementId];
    }
    
    // if full clicks is not reliable, just goto the designeted website,
    // but first send an event to the tracking stuff
    if (!_ad.creative.isFullClickURLReliable) {
        NSLog(@"Success: %@", _ad.creative.trackingURL);
        [SASender sendEventToURL:_ad.creative.trackingURL];
    }
    
    NSURL *url = [NSURL URLWithString:_ad.creative.fullClickURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark Resize to Frame

- (void) resizeToFrame:(CGRect)frame {
    // do nothing
}

@end

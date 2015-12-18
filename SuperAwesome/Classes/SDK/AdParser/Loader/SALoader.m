//
//  SALoader.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 11/10/2015.
//
//

// import header
#import "SALoader.h"

// import other headers
#import "SAParser.h"
#import "SAValidator.h"
#import "SAHTMLParser.h"
#import "SAVASTParser.h"

// import model headers
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"

// import SA main Singleton
#import "SuperAwesome.h"

// import Aux class
#import "libSAiOSUtils.h"
#import "libSAiOSNetwork.h"

@implementation SALoader

static id<SALoaderProtocol> delegate;

+ (id<SALoaderProtocol>) delegate {
    @synchronized(self) {
        return delegate;
    }
}
+ (void) setDelegate:(id<SALoaderProtocol>)del {
    @synchronized(self) {
        delegate = del;
    }
}

+ (void) loadAdForPlacementId:(NSInteger)placementId {
    
    // First thing to do is format the AA URL to get an ad, based on specs
    NSString *endpoint = [NSString stringWithFormat:@"%@/ad/%ld", [[SuperAwesome getInstance] getBaseURL], (long)placementId];
    NSDictionary *dict = @{
        @"test": [NSNumber numberWithBool:[[SuperAwesome getInstance] isTestingEnabled]],
        @"sdkVersion": [[SuperAwesome getInstance] getSdkVersion],
        @"rnd": [NSNumber numberWithInteger:[SAURLUtils getCachebuster]]
    };
    
    // The second operation to perform is calling a SANetwork class function
    // to get Ad data, returned as NSData
    [SANetwork sendGETtoEndpoint:endpoint withQueryDict:dict andSuccess:^(NSData *data) {
        
        // We're assuming the NSData is actually a JSON in string format,
        // so the next step is to parse it
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        // some error occured, probably the JSON string was badly formatted
        if (jsonError) {
            if (SALoader.delegate != NULL && [SALoader.delegate respondsToSelector:@selector(didFailToLoadAdForPlacementId:)]) {
                [SALoader.delegate didFailToLoadAdForPlacementId:placementId];
            }
        }
        // if there is no specific JSON Error, we can move forward to try to
        // create the Ad as it's needed by AA
        else {
            // we invoke SAParser class functions to parse different aspects
            // of the Ad
            [SAParser parseDictionary:json withPlacementId:placementId intoAd:^(SAAd *parsedAd) {
                
                // one final check for validity
                BOOL isValid = [SAValidator isAdDataValid:parsedAd];
                
                // and if all is OK go forward and announce the new ad
                if (isValid) {
                    if (SALoader.delegate != NULL && [SALoader.delegate respondsToSelector:@selector(didLoadAd:)]) {
                        [SALoader.delegate didLoadAd:parsedAd];
                    }
                }
                // else announce failure
                else {
                    if (SALoader.delegate != NULL && [SALoader.delegate respondsToSelector:@selector(didFailToLoadAdForPlacementId:)]) {
                        [SALoader.delegate didFailToLoadAdForPlacementId:placementId];
                    }
                }
            }];
        }
        
    } orFailure:^{
        if (SALoader.delegate != NULL && [SALoader.delegate respondsToSelector:@selector(didFailToLoadAdForPlacementId:)]) {
            [SALoader.delegate didFailToLoadAdForPlacementId:placementId];
        }
    }];
}

@end
//
//  SAParser.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 11/10/2015.
//
//

// import header file
#import "SAParser.h"

// import modelspace
#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"

// import SuperAwesome main header
 #import "SALoaderSession.h"

// import SAAux library of goodies
#import "SAUtils.h"
#import "SAJsonParser.h"

// modelspace for vast parsing
#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SAVASTTracking.h"

// parser implementation
@implementation SAParser

- (SAAd*) parseInitialAdFromNetwork:(NSData*)jsonData withPlacementId:(NSInteger)placementId {
    
    SAAd *ad = [[SAAd alloc] initWithJsonData:jsonData];
    ad.placementId = placementId;
    
    ad.creative.creativeFormat = invalid;
    if ([ad.creative.format isEqualToString:@"image_with_link"]) ad.creative.creativeFormat = image;
    else if ([ad.creative.format isEqualToString:@"video"]) ad.creative.creativeFormat = video;
    else if ([ad.creative.format containsString:@"rich_media"]) ad.creative.creativeFormat = rich;
    else if ([ad.creative.format containsString:@"tag"]) ad.creative.creativeFormat = tag;
    
    // create the tracking URL
    NSDictionary *trackjson = @{
        @"placement":@(ad.placementId),
        @"line_item":@(ad.lineItemId),
        @"creative":@(ad.creative._id),
        @"sdkVersion":[[SALoaderSession getInstance] getVersion],
        @"rnd":@([SAUtils getCachebuster])
    };
    ad.creative.trackingUrl = [NSString stringWithFormat:@"%@/%@click?%@",
                               [[SALoaderSession getInstance] getBaseUrl],
                               (ad.creative.creativeFormat == video ? @"video/" : @""),
                               [SAUtils formGetQueryFromDict:trackjson]];
    
    // get the viewbale impression URL
    NSDictionary *imprjson = @{
        @"sdkVersion":[[SALoaderSession getInstance] getVersion],
        @"rnd":@([SAUtils getCachebuster]),
        @"data":[SAUtils encodeURI:[@{
            @"placement":@(ad.placementId),
            @"line_item":@(ad.lineItemId),
            @"creative":@(ad.creative._id),
            @"type":@"viewable_impression"
        } jsonCompactStringRepresentation]]
    };
    ad.creative.viewableImpressionUrl = [NSString stringWithFormat:@"%@/event?%@",
                                         [[SALoaderSession getInstance] getBaseUrl],
                                         [SAUtils formGetQueryFromDict:imprjson]];
    
    // get the parental gate URL
    NSDictionary *pgjson = @{
        @"sdkVersion":[[SALoaderSession getInstance] getVersion],
        @"rnd":@([SAUtils getCachebuster]),
        @"data":[SAUtils encodeURI:[@{
            @"placement":@(ad.placementId),
            @"line_item":@(ad.lineItemId),
            @"creative":@(ad.creative._id),
            @"type":@"custom.parentalGateAccessed"
        } jsonCompactStringRepresentation]]
    };
    ad.creative.parentalGateClickUrl = [NSString stringWithFormat:@"%@/event?%@",
                                        [[SALoaderSession getInstance] getVersion],
                                        [SAUtils formGetQueryFromDict:pgjson]];
    
    // valdate ad
     if ([ad isValid]) return ad;
    return nil;
}

@end
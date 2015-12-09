//
//  SAAux.m
//  Pods
//
//  Created by Gabriel Coman on 02/12/2015.
//
//

#import "SAAux.h"

@implementation SAAux

+ (CGRect) arrangeAdInNewFrame:(CGRect)frame fromFrame:(CGRect)oldframe {
    
    CGFloat newW = frame.size.width;
    CGFloat newH = frame.size.height;
    CGFloat oldW = oldframe.size.width;
    CGFloat oldH = oldframe.size.height;
    if (oldW == 1 || oldW == 0) { oldW = newW; }
    if (oldH == 1 || oldH == 0) { oldH = newH; }
    
    CGFloat oldR = oldW / oldH;
    CGFloat newR = newW / newH;
    
    CGFloat X = 0, Y = 0, W = 0, H = 0;
    
    if (oldR > newR) {
        W = newW;
        H = W / oldR;
        X = 0;
        Y = (newH - H) / 2.0f;
    }
    else {
        H = newH;
        W = H * oldR;
        Y = 0;
        X = (newW - W) / 2.0f;
    }
    
    return CGRectMake(X, Y, W, H);
}

+ (NSInteger) randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max {
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

+ (NSInteger) getCachebuster {
    return [SAAux randomNumberBetween:1000000 maxNumber:1500000];
}

+ (NSString*) findSubstringFrom:(NSString*)source betweenStart:(NSString*)start andEnd:(NSString*)end {
    NSRange startRange = [source rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [source length] - targetRange.location;
        NSRange endRange = [source rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [source substringWithRange:targetRange];
        }
    }
    
    // if it gets to here there is no substring, and just return
    return nil;
}

+ (NSString*) formGetQueryFromDict:(NSDictionary *)dict {
    // initial var declaration
    NSMutableString *query = [[NSMutableString alloc] init];
    NSMutableArray *getParams = [[NSMutableArray alloc] init];
    
    // perform operation
    for (NSString *key in dict.allKeys) {
        [getParams addObject:[NSString stringWithFormat:@"%@=%@", key, [dict objectForKey:key]]];
    }
    [query appendString:[getParams componentsJoinedByString:@"&"]];
    
    // return
    return query;
}

+ (NSString*) encodeURI:(NSString*)stringToEncode {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (__bridge CFStringRef)stringToEncode,
                                                                     NULL,
                                                                     (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString*) encodeJSONDictionaryFromNSDictionary:(NSDictionary *)dict {
    
    // initial var declaration
    NSMutableString *stringJSON = [[NSMutableString alloc] init];
    NSMutableArray *jsonFields = [[NSMutableArray alloc] init];
    
    // process data
    for (NSObject *key in dict.allKeys) {
        if ([[dict objectForKey:key] isKindOfClass:[NSString class]]){
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"", key, [dict objectForKey:key] ]];
        } else {
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":%@", key, [dict objectForKey:key] ]];
        }
    }
    [stringJSON appendString:@"{"];
    [stringJSON appendString:[jsonFields componentsJoinedByString:@","]];
    [stringJSON appendString:@"}"];
    
    // return data
    return [SAAux encodeURI:stringJSON];
}

+ (BOOL) isValidURL:(NSObject *)urlObject {
    
    if ([urlObject isKindOfClass:[NSNull class]]) {
        
        return false;
    }
    else if ([urlObject isKindOfClass:[NSString class]]){
        NSString *urlString = (NSString*)urlObject;
        
        NSUInteger length = [urlString length];
        // Empty strings should return NO
        if (length > 0) {
            NSError *error = nil;
            NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            if (dataDetector && !error) {
                NSRange range = NSMakeRange(0, length);
                NSRange notFoundRange = (NSRange){NSNotFound, 0};
                NSRange linkRange = [dataDetector rangeOfFirstMatchInString:urlString options:0 range:range];
                if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                    if ([urlString isEqualToString:@"http://"] || [urlString isEqualToString:@"https://"]){
                        return false;
                    } else {
                        return true;
                    }
                }
            }
            else {
                NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
            }
        }
        return false;
    }
    
    return false;
}

@end
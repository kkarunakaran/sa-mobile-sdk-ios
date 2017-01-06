#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"

// import other AIR header files
#import "SAAIRBannerAd.h"
#import "SAAIRInterstitialAd.h"
#import "SAAIRVideoAd.h"
#import "SAAIRAppWall.h"
#import "SAAIRCPI.h"
#import "SAAIRVersion.h"

void SAContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToTest = 19;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "SuperAwesomeAIRSAVideoAdCreate";
    func[0].functionData = NULL;
    func[0].function = &SuperAwesomeAIRSAVideoAdCreate;
    
    func[1].name = (const uint8_t*) "SuperAwesomeAIRSAVideoAdLoad";
    func[1].functionData = NULL;
    func[1].function = &SuperAwesomeAIRSAVideoAdLoad;
    
    func[2].name = (const uint8_t*) "SuperAwesomeAIRSAVideoAdHasAdAvailable";
    func[2].functionData = NULL;
    func[2].function = &SuperAwesomeAIRSAVideoAdHasAdAvailable;
    
    func[3].name = (const uint8_t*) "SuperAwesomeAIRSAVideoAdPlay";
    func[3].functionData = NULL;
    func[3].function = &SuperAwesomeAIRSAVideoAdPlay;
    
    func[4].name = (const uint8_t*) "SuperAwesomeAIRSAInterstitialAdCreate";
    func[4].functionData = NULL;
    func[4].function = &SuperAwesomeAIRSAInterstitialAdCreate;
    
    func[5].name = (const uint8_t*) "SuperAwesomeAIRSAInterstitialAdLoad";
    func[5].functionData = NULL;
    func[5].function = &SuperAwesomeAIRSAInterstitialAdLoad;
    
    func[6].name = (const uint8_t*) "SuperAwesomeAIRSAInterstitialAdHasAdAvailable";
    func[6].functionData = NULL;
    func[6].function = &SuperAwesomeAIRSAInterstitialAdHasAdAvailable;
    
    func[7].name = (const uint8_t*) "SuperAwesomeAIRSAInterstitialAdPlay";
    func[7].functionData = NULL;
    func[7].function = &SuperAwesomeAIRSAInterstitialAdPlay;
    
    func[8].name = (const uint8_t*) "SuperAwesomeAIRSAAppWallCreate";
    func[8].functionData = NULL;
    func[8].function = &SuperAwesomeAIRSAAppWallCreate;
    
    func[9].name = (const uint8_t*) "SuperAwesomeAIRSAAppWallLoad";
    func[9].functionData = NULL;
    func[9].function = &SuperAwesomeAIRSAAppWallLoad;
    
    func[10].name = (const uint8_t*) "SuperAwesomeAIRSAAppWallHasAdAvailable";
    func[10].functionData = NULL;
    func[10].function = &SuperAwesomeAIRSAAppWallHasAdAvailable;
    
    func[11].name = (const uint8_t*) "SuperAwesomeAIRSAAppWallPlay";
    func[11].functionData = NULL;
    func[11].function = &SuperAwesomeAIRSAAppWallPlay;
    
    func[12].name = (const uint8_t*) "SuperAwesomeAIRSABannerAdCreate";
    func[12].functionData = NULL;
    func[12].function = &SuperAwesomeAIRSABannerAdCreate;
    
    func[13].name = (const uint8_t*) "SuperAwesomeAIRSABannerAdLoad";
    func[13].functionData = NULL;
    func[13].function = &SuperAwesomeAIRSABannerAdLoad;
    
    func[14].name = (const uint8_t*) "SuperAwesomeAIRSABannerAdHasAdAvailable";
    func[14].functionData = NULL;
    func[14].function = &SuperAwesomeAIRSABannerAdHasAdAvailable;
    
    func[15].name = (const uint8_t*) "SuperAwesomeAIRSABannerAdPlay";
    func[15].functionData = NULL;
    func[15].function = &SuperAwesomeAIRSABannerAdPlay;
    
    func[16].name = (const uint8_t*) "SuperAwesomeAIRSABannerAdClose";
    func[16].functionData = NULL;
    func[16].function = &SuperAwesomeAIRSABannerAdClose;
    
    func[17].name = (const uint8_t*) "SuperAwesomeAIRSuperAwesomeHandleCPI";
    func[17].functionData = NULL;
    func[17].function = &SuperAwesomeAIRSuperAwesomeHandleCPI;
    
    func[18].name = (const uint8_t*) "SuperAwesomeAIRSetVersion";
    func[18].functionData = NULL;
    func[18].function = &SuperAwesomeAIRSetVersion;
    
    *functionsToSet = func;
}

// this should start the Extension (and also be present in the XML file)
void SAExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
    *extDataToSet = NULL;
    *ctxInitializerToSet = &SAContextInitializer;
}

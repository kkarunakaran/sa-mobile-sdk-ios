//
//  SAInterstitialAd2.m
//  Pods
//
//  Created by Gabriel Coman on 13/02/2016.
//
//

#import "SAInterstitialAd.h"
#import "SABannerAd.h"
#import "SAUtils.h"
#import "SAAd.h"
#import "SACreative.h"

// defines
#define INTER_BG_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1]

@interface SABannerAd () <SAWebPlayerProtocol>
@property (nonatomic, weak) id<SAAdProtocol> internalAdProto;
@end

@interface SAInterstitialAd () <SAAdProtocol>
@property (nonatomic, assign) CGRect adviewFrame;
@property (nonatomic, assign) CGRect buttonFrame;
@property (nonatomic, strong) SAAd *ad;
@property (nonatomic, strong) SABannerAd *banner;
@property (nonatomic, strong) UIButton *closeBtn;
@end

@implementation SAInterstitialAd

#pragma mark <ViewController> functions

- (id) init {
    if (self = [super init]) {
        _shouldLockOrientation = NO;
        _lockOrientation = UIInterfaceOrientationMaskAll;
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _shouldLockOrientation = NO;
        _lockOrientation = UIInterfaceOrientationMaskAll;
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _shouldLockOrientation = NO;
        _lockOrientation = UIInterfaceOrientationMaskAll;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // set bg color
    self.view.backgroundColor = INTER_BG_COLOR;
    
    _banner = [[SABannerAd alloc] initWithFrame:_adviewFrame];
    _banner.adDelegate = _adDelegate;
    _banner.parentalGateDelegate = _parentalGateDelegate;
    _banner.isParentalGateEnabled = _isParentalGateEnabled;
    _banner.internalAdProto = self;
    [_banner setAd:_ad];
    _banner.backgroundColor = INTER_BG_COLOR;
    [self.view addSubview:_banner];
    
    // create close button
    _closeBtn = [[UIButton alloc] initWithFrame:_buttonFrame];
    [_closeBtn setTitle:@"" forState:UIControlStateNormal];
    [_closeBtn setImage:[SAUtils closeImage] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    [self.view bringSubviewToFront:_closeBtn];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // setup coordinates
    CGSize scrSize = [UIScreen mainScreen].bounds.size;
    CGSize currentSize = CGSizeZero;
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat bigDimension = MAX(scrSize.width, scrSize.height);
    CGFloat smallDimension = MIN(scrSize.width, scrSize.height);
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:{
            currentSize = CGSizeMake(bigDimension, smallDimension);
            break;
        }
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:{
            currentSize = CGSizeMake(smallDimension, bigDimension);
            break;
        }
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown: {
            if (scrSize.width > scrSize.height){
                currentSize = CGSizeMake(bigDimension, smallDimension);
            }
            else {
                currentSize = CGSizeMake(smallDimension, bigDimension);
            }
            break;
        }
        default: {
            currentSize = CGSizeMake(smallDimension, bigDimension);
            break;
        }
    }
    
    [self resizeToFrame:CGRectMake(0, 0, currentSize.width, currentSize.height)];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self resizeToFrame:CGRectMake(0, 0, size.width, size.height)];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGSize scrSize = [UIScreen mainScreen].bounds.size;
    CGFloat bigDimension = MAX(scrSize.width, scrSize.height);
    CGFloat smallDimension = MIN(scrSize.width, scrSize.height);
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            [self resizeToFrame:CGRectMake(0, 0, bigDimension, smallDimension)];
            break;
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationUnknown:
        default: {
            [self resizeToFrame:CGRectMake(0, 0, smallDimension, bigDimension)];
            break;
        }
    }
}

- (NSUInteger) supportedInterfaceOrientations {
    if (_shouldLockOrientation) {
        return _lockOrientation;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL) prefersStatusBarHidden {
    return true;
}

#pragma mark <SAViewProtocol> functions

- (void) setAd:(SAAd*)__ad {
    _ad = __ad;
}

- (SAAd*) getAd {
    return _ad;
}

- (void) play {
    [_banner play];
}

- (BOOL) shouldShowPadlock {
    return [_banner shouldShowPadlock];
}

- (void) close {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([_banner.adDelegate respondsToSelector:@selector(adWasClosed:)]) {
            [_banner.adDelegate adWasClosed:_ad.placementId];
        }
    }];

}

- (void) advanceToClick {
    // do nothing
}

- (void) resizeToFrame:(CGRect)frame {
    CGFloat tW = frame.size.width;// * 0.85;
    CGFloat tH = frame.size.height;// * 0.85;
    CGFloat tX = ( frame.size.width - tW ) / 2;
    CGFloat tY = ( frame.size.height - tH) / 2;
    CGRect newR = [SAUtils mapOldFrame:CGRectMake(tX, tY, tW, tH) toNewFrame:frame];
    newR.origin.x += tX;
    newR.origin.y += tY;
    
    CGFloat cs = 40.0f;
    
    // final frames
    _adviewFrame = newR;
    _buttonFrame = CGRectMake(frame.size.width - cs, 0, cs, cs);
    
    // actually resize stuff
    _closeBtn.frame = _buttonFrame;
    [_banner resizeToFrame:_adviewFrame];
}

#pragma mark <SAAdProtocol> - internal

- (void) adFailedToShow:(NSInteger)placementId {
    [self close];
}

- (void) adHasIncorrectPlacement:(NSInteger)placementId {
    [self close];
}

@end

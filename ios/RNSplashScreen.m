/**
 * SplashScreen
 * from：https:/qgx.digital
 * Author:qgxpagamentos
 * GitHub:https://github.com/qgxpagamentos
 * Email:admin@qgxpagamentos.com.br
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waiting = true;
static bool isAnimationFinished = false;
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
  if (!addedJsLoadErrorObserver) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsLoadError:)
                                                 name:RCTJavaScriptDidFailToLoadNotification
                                               object:nil];
    addedJsLoadErrorObserver = true;
  }

  while (waiting) {
    NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
    [[NSRunLoop mainRunLoop] runUntilDate:later];
  }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
  if (!loadingView) {
    loadingView = [[[NSBundle mainBundle] loadNibNamed:splashScreen owner:self
                                               options:nil] objectAtIndex:0];
    CGRect frame = rootView.frame;
    frame.origin = CGPointMake(0, 0);
    loadingView.frame = frame;
  }
  waiting = false;

  [rootView addSubview:loadingView];
}

+ (void)showLottieSplash:(UIView*)animationView inRootView:(UIView*)rootView {
  loadingView = animationView;
  waiting = false;
  [rootView addSubview:animationView];
}

+ (void)hide {
  if (waiting) {
    dispatch_async(dispatch_get_main_queue(), ^{
      waiting = false;
    });
  } else {
    waiting = true;
      if (isAnimationFinished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                         [loadingView removeFromSuperview];
                       });
      }
  }
}

+ (void)setAnimationFinished:(Boolean)flag {
    isAnimationFinished = true;
    if (waiting) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
                       [loadingView removeFromSuperview];
                     });
    }
}

+ (void)jsLoadError:(NSNotification*)notification {
  // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise
  // the splash screen will remain forever, which is a hassle to debug.
  [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) { [RNSplashScreen hide]; }

RCT_EXPORT_METHOD(show) { [RNSplashScreen show]; }

@end

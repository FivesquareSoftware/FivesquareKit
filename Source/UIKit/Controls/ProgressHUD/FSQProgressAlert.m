//
//  FSQProgressAlert.m
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQProgressAlert.h"

#import "FSQProgressView.h"
#import "FSQProgressPanel.h"

#import "FSQAlertView.h"
#import "FSQUIKitConstants.h"
#import "FSQLogging.h"

#define kSPProgressAlertDefaultOptions FSQProgressAlertOptionsNone


@interface FSQProgressAlert ()

@property (nonatomic) FSQProgressAlertOptions options;
@property (nonatomic, readwrite, getter = isCanceled) BOOL canceled;


@property (nonatomic, weak) FSQProgressView *progressView;
@property (nonatomic, strong) UIWindow *previousKeyWindow;

@end

@implementation FSQProgressAlert

// ========================================================================== //

#pragma mark - Class Methods



static FSQProgressAlert *__instance = nil;
+ (id) instance {
	@synchronized(self) {
		if (__instance == nil) {
			__instance = [[FSQProgressAlert alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		}
	}
	return __instance;
}


// ========================================================================== //

#pragma mark - Properties

- (void) setOptions:(FSQProgressAlertOptions)options {
	if (_options != options) {
		_options = options;
		
		_progressView.showsCancelButton = ((_options&FSQProgressAlertOptionsShowsCancelButton)==FSQProgressAlertOptionsShowsCancelButton);
		_progressView.indeterminate = ((_options&FSQProgressAlertOptionsIndeterminate)==FSQProgressAlertOptionsIndeterminate);
	}
}

@dynamic showsCancelButton;
- (BOOL) showsCancelButton {
	return (_options&FSQProgressAlertOptionsShowsCancelButton)==FSQProgressAlertOptionsShowsCancelButton;
}

@dynamic indeterminate;
- (BOOL) indeterminate {
	return (_options&FSQProgressAlertOptionsIndeterminate)==FSQProgressAlertOptionsIndeterminate;
}

@dynamic message;
- (void) setMessage:(NSString *)message {
	[_progressView setMessage:message];
}
- (NSString *) message {
	return [_progressView message];
}

@dynamic style;
- (void) setStyle:(FSQProgressAlertStyle)style {
    _progressView.style = style;
}

- (FSQProgressAlertStyle) style {
    return _progressView.style;
}

@dynamic progress;
- (void) setProgress:(float)progress {
	dispatch_async(dispatch_get_main_queue(), ^{
		[_progressView setProgress:progress];
	});
}
- (float) progress {
	return [_progressView progress];
}





// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = YES;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.autoresizesSubviews = YES;
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.userInteractionEnabled = NO;
	self.windowLevel = UIWindowLevelNormal;
	self.options = kSPProgressAlertDefaultOptions;
	self.minimumDisplayTime = 1.3;
}

- (void) ready {		
	FSQProgressView *progressView = [[FSQProgressView alloc] initWithFrame:CGRectZero];
	[self addSubview:progressView];
	_progressView = progressView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
		[self ready];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self ready];
}


// ========================================================================== //

#pragma mark - View

- (void) resignKeyWindow {
	FLogMethod();
	[super resignKeyWindow];
	// In case any hide animations are in progress, let's just drop out
//	[UIView animateWithDuration:kSpotDefaultAnimationDuration animations:^{
//		self.hidden = YES;
//	}];
}

- (void) layoutSubviews {
//	[super layoutSubviews];
	
	_progressView.frame = self.bounds; // We could resize this to handle keyboard & other stuff
	[_progressView setNeedsUpdateConstraints];
	[super layoutSubviews];
}


// ========================================================================== //

#pragma mark - Public


// Run

+ (void) runWithStatus:(NSString *)status {
	[self runWithStatus:status executingBlock:nil completionBlock:nil options:kSPProgressAlertDefaultOptions];
}

+ (void) runWithStatus:(NSString *)status options:(FSQProgressAlertOptions)options {
	[self runWithStatus:status executingBlock:nil completionBlock:nil options:options];
}

+ (void) runWithStatus:(NSString *)status untilDone:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock {
	[self runWithStatus:status executingBlock:block completionBlock:completionBlock options:FSQProgressAlertOptionsIndeterminate];
}

+ (void) runWithStatus:(NSString *)status whileProgressing:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock {
	[self runWithStatus:status executingBlock:block completionBlock:completionBlock options:kSPProgressAlertDefaultOptions];
}

+ (void) runWithStatus:(NSString *)status executingBlock:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock options:(FSQProgressAlertOptions)options {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance runWithStatus:status executingBlock:block completionBlock:completionBlock options:options];
}


// Control

+ (void) setProgress:(float)progress {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance setProgress:progress];
}

+ (void) tick {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance tick];
}

+ (void) cancel {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance cancel];
}

+ (void) dismiss {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance dismiss];
}

+ (void) dismissWithError:(NSError *)error {
	FSQProgressAlert *instance = [FSQProgressAlert instance];
	[instance dismissWithError:error];
}


// ========================================================================== //

#pragma mark - Instance Methods

- (void) runWithStatus:(NSString *)status executingBlock:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock options:(FSQProgressAlertOptions)options {
	self.options = options;
	[self setMessage:status];
	[self setProgress:0];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if(NO == [self isKeyWindow]) {
			[[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				UIWindow *window = (UIWindow*)obj;
				if(window.windowLevel == UIWindowLevelNormal && ![[window class] isEqual:[self class]]) {
					self.previousKeyWindow = window;
					*stop = YES;
				}
			}];
			[self makeKeyAndVisible];
		}		
		[self showAnimated:YES];
	});
	NSDate *runStarted = [NSDate date];
	
	if (block) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			block(self);
			self.progress = 1.f;
			NSTimeInterval sinceRunStarted = [[NSDate date] timeIntervalSinceDate:runStarted];
			NSTimeInterval dismissDelay = _minimumDisplayTime-sinceRunStarted;
			if (dismissDelay < 0) {
				dismissDelay = 0;
			}
			double delayInSeconds = dismissDelay;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self dismiss];
				if (completionBlock) {
					dispatch_async(dispatch_get_main_queue(), completionBlock);
				}
			});
		});
	}
}

- (void) tick {
	if (self.progress < 1.f) {
		self.progress += .1;
	}
}

- (void) cancel {
	self.canceled = YES;
	[self dismiss];
}

- (void) dismiss {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self hideAnimated:YES];
	});
}

- (void) dismissWithError:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
//		[self.previousKeyWindow makeKeyWindow];
		[self hideAnimated:YES completionBlock:^{
			FSQAlertView *alert = [FSQAlertView errorAlertWithError:error];
			[alert show];
		}];
	});
}


// ========================================================================== //

#pragma mark - Visibility


- (void) showAnimated:(BOOL)animated {
	// animate in
	NSTimeInterval duration = animated ? kFSQUIKitDefaultAnimationDuration : 0;
	
	_progressView.panel.transform = CGAffineTransformMakeScale(.3, .3);
	_progressView.panel.alpha = 0;
	
	[UIView animateWithDuration:duration*.55 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		_progressView.panel.transform = CGAffineTransformMakeScale(1.1, 1.1);
		_progressView.panel.alpha = 1.0*.55;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:duration*.25 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^{
			_progressView.panel.transform = CGAffineTransformMakeScale(.9, .9);
			_progressView.panel.alpha = 1.0*.80;
		} completion:^(BOOL finished1) {
			[UIView animateWithDuration:duration*.2 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^{
				_progressView.panel.transform = CGAffineTransformIdentity;
				_progressView.panel.alpha = 1.0;
			} completion:^(BOOL finished2) {
			}];
		}];
	}];
}

- (void) hideAnimated:(BOOL)animated {
	[self hideAnimated:animated completionBlock:nil];
}

- (void) hideAnimated:(BOOL)animated completionBlock:(void(^)())block {
	NSTimeInterval duration = animated ? kFSQUIKitDefaultAnimationDuration : 0;
	_progressView.panel.transform = CGAffineTransformIdentity;
	_progressView.panel.alpha = 1.f;
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^{
		_progressView.panel.alpha = 0;
	} completion:^(BOOL finished) {
		if (!finished) {
			FLog(@"*** PANEL NOT HIDDEN: panel.alpha: %f",_progressView.panel.alpha);
		}
		else {
			FLog(@"*** Panel successfully hidden");
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([self isKeyWindow] && self.previousKeyWindow) {
				[self.previousKeyWindow makeKeyWindow];
			}
			__instance = nil;
		});
		if (block) {
			dispatch_async(dispatch_get_main_queue(), block);
		}
	}];
}


@end

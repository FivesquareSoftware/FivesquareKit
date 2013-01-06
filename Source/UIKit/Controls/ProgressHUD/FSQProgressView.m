//
//  SPProgressView.m
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQProgressView.h"

#import "FSQProgressAlert.h"
#import "FSQProgressPanel.h"
#import "FSQLabel.h"
#import "FSQUIKitConstants.h"
#import "FSQLogging.h"


@interface FSQProgressView ()
@property (nonatomic, strong) NSArray *layoutConstraints;
@property (nonatomic, strong) NSLayoutConstraint *panelScaleConstraint;
@end

@implementation FSQProgressView


+ (BOOL) requiresConstraintBasedLayout {
	return YES;
}

// ========================================================================== //

#pragma mark - Properties

@dynamic showsCancelButton;
- (void) setShowsCancelButton:(BOOL)showsCancelButton {
	_panel.showsCancelButton = showsCancelButton;
}
- (BOOL) showsCancelButton {
	return _panel.showsCancelButton;
}

@dynamic indeterminate;
- (void) setIndeterminate:(BOOL)indeterminate {
	_panel.indeterminate = indeterminate;
}
- (BOOL) indeterminate {
	return _panel.indeterminate;
}

@dynamic message;
- (void) setMessage:(NSString *)message {
	_panel.messageLabel.text = message;
}
- (NSString *) message {
	return _panel.messageLabel.text;
}

@dynamic style;
- (void) setStyle:(FSQProgressAlertStyle)style {
    _panel.style = style;
}

- (FSQProgressAlertStyle) style {
    return _panel.style;
}

@dynamic progress;
- (void) setProgress:(float)progress {
	FLog(@"setProgress: %f",progress);
	[UIView animateWithDuration:kFSQUIKitDefaultAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear|UIViewAnimationOptionOverrideInheritedDuration animations:^{
		_panel.progressBar.progress = progress;
	} completion:^(BOOL finished) {
		;
	}];
}
- (float) progress {
	return _panel.progressBar.progress;
}


// Private

- (void) setLayoutConstraints:(NSArray *)layoutConstraints {
	if (_layoutConstraints != layoutConstraints) {
		if (_layoutConstraints) {
			[self removeConstraints:_layoutConstraints];
		}
		_layoutConstraints = layoutConstraints;
		if (_layoutConstraints) {
			[self addConstraints:_layoutConstraints];
		}
	}
}

- (void) setPanelScaleConstraint:(NSLayoutConstraint *)panelScaleConstraint {
	if (_panelScaleConstraint != panelScaleConstraint) {
		if (_panelScaleConstraint) {
			[self removeConstraint:panelScaleConstraint];
		}
		_panelScaleConstraint = panelScaleConstraint;
		if (_panelScaleConstraint) {
			[self addConstraint:_panelScaleConstraint];
		}
	}
}



// ========================================================================== //

#pragma mark - Objects

- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
}

- (void) ready {
	FSQProgressPanel *panel = [[FSQProgressPanel alloc] initWithFrame:CGRectZero];
	[self addSubview:panel];
	_panel = panel;
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


- (void) updateConstraints {
	[super updateConstraints];
	
	
//	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(self, _panel);
//	NSDictionary *metrics = @{};//@{ @"panelWidth" : @(kFSQProgressAlertPanelWidth), @"panelHeight" : @(kFSQProgressAlertPanelHeight) };
	
	NSMutableArray *layoutConstraints = [NSMutableArray new];
	
	[layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_panel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0]];
	[layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_panel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0]];
	
	self.layoutConstraints = layoutConstraints;
}

- (void) layoutSubviews {
	[super layoutSubviews];
}


// ========================================================================== //

#pragma mark - Public






@end

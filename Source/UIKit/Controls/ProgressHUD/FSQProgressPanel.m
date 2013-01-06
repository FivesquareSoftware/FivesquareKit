//
//  SPProgressPanel.m
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQProgressPanel.h"

#import <QuartzCore/QuartzCore.h>
#import "FSQLabel.h"

#define kSPProgressPanelCornerRadius 10.f
#define kSPProgressPanelWidth 245.f
#define kSPProgressPanelTopInset 5.f
#define kSPProgressPanelBottomInset 10.f
#define kSPProgressPanelSpinnerInset 10.f


@interface FSQProgressPanel ()
@property (nonatomic, weak) CAGradientLayer *panelBackground;
@property (nonatomic, strong) NSArray *layoutConstraints;
@end

@implementation FSQProgressPanel

+ (BOOL) requiresConstraintBasedLayout {
	return YES;
}

+ (NSArray *) defaultBackgroundGradient {
	static NSArray *defaultBackgroundGradient = nil;
	if (defaultBackgroundGradient == nil) {
		UIColor *color1 = [UIColor colorWithWhite:.55 alpha:1.f];
		UIColor *color2 = [UIColor colorWithWhite:.35 alpha:1.f];
		
		defaultBackgroundGradient = @[ @{@"color" : (id)color1.CGColor, @"location" :  @0 }, @{@"color" : (id)color2.CGColor, @"location" :  @1 } ];
	}
	return defaultBackgroundGradient;
}

+ (UIColor *) defaultTintColor {
    return [UIColor colorWithWhite:.25 alpha:1.f];
}



// ========================================================================== //

#pragma mark - Properties


- (void) setShowsCancelButton:(BOOL)showsCancelButton {
	if (_showsCancelButton != showsCancelButton) {
		_showsCancelButton = showsCancelButton;
		//TODO: update cancel button 
	}
}

- (void) setIndeterminate:(BOOL)indeterminate {
	if (_indeterminate != indeterminate) {
		_indeterminate = indeterminate;
		//		[self needsUpdateConstraints];
		_messageLabel.textAlignment = _indeterminate ? NSTextAlignmentLeft : NSTextAlignmentCenter;
		_progressBar.hidden = _indeterminate;
		_spinner.hidden = !_indeterminate;
		if (_indeterminate) {
			[_spinner startAnimating];
		}
		else {
			[_spinner stopAnimating];
		}

//		[self setNeedsUpdateConstraints];
	}
}

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


// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.layer.cornerRadius = kSPProgressPanelCornerRadius;
	self.backgroundColor = [UIColor clearColor];
	_indeterminate = NO;
	
	CALayer *layer = self.layer;
	layer.shadowColor = [UIColor blackColor].CGColor;
	layer.shadowOpacity = 1.f;
	layer.shadowOffset = CGSizeZero;
	layer.shadowRadius = 1.f;

}

- (void) ready {
	
	//	panel.backgroundColor = [UIColor blueColor];
	
	CAGradientLayer *panelBackground = [[CAGradientLayer alloc] init];
	panelBackground.colors = [[[self class] defaultBackgroundGradient] valueForKey:@"color"];
	panelBackground.locations = [[[self class] defaultBackgroundGradient] valueForKey:@"location"];
	panelBackground.cornerRadius = kSPProgressPanelCornerRadius;
	panelBackground.borderColor = [UIColor whiteColor].CGColor;
	panelBackground.borderWidth = 2.f;
	panelBackground.needsDisplayOnBoundsChange = YES;
	
	[self.layer addSublayer:panelBackground];
	_panelBackground = panelBackground;
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:spinner];
	_spinner = spinner;
	
	UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	progressBar.translatesAutoresizingMaskIntoConstraints = NO;
	progressBar.progressTintColor = [[self class] defaultTintColor];
	progressBar.trackTintColor = [UIColor whiteColor];
	_progressBar.hidden = _indeterminate;
	[self addSubview:progressBar];
	_progressBar = progressBar;
	
	FSQLabel *messageLabel = [[FSQLabel alloc] initWithFrame:CGRectZero];
	[messageLabel setTextColor:[UIColor whiteColor]];
	[messageLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
	messageLabel.collapseWhenEmpty = YES;
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.opaque = NO;
	[self addSubview:messageLabel];
	_messageLabel = messageLabel;
	
	
//	[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_panel(>=panelHeight@1000)]" options:0 metrics:metrics views:viewsDictionary]];
//	[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_panel(==panelWidth@1000)]" options:0 metrics:metrics views:viewsDictionary]];

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

- (CGSize) intrinsicContentSize {
	return CGSizeMake(kSPProgressPanelWidth, UIViewNoIntrinsicMetric);
}

- (void) updateConstraints {
	[super updateConstraints];
	
	
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(self, _spinner, _progressBar, _messageLabel);
	NSDictionary *metrics = @{ @"topInset" : @(kSPProgressPanelTopInset), @"bottomInset" : @(kSPProgressPanelBottomInset), @"spinnerInset" : @(kSPProgressPanelSpinnerInset) };
	
	NSMutableArray *layoutConstraints = [NSMutableArray new];
	
	
	if (_indeterminate) {
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spinnerInset-[_spinner]-spinnerInset-|" options:0 metrics:metrics views:viewsDictionary]];
//		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_messageLabel]-5-|" options:0 metrics:metrics views:viewsDictionary]];
		[layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0]];
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_spinner]-[_messageLabel]-|" options:0 metrics:metrics views:viewsDictionary]];
		
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressBar][self]" options:0 metrics:metrics views:viewsDictionary]];
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_progressBar][self]" options:0 metrics:metrics views:viewsDictionary]];
	}
	else {
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topInset-[_messageLabel]-[_progressBar]-bottomInset-|" options:0 metrics:metrics views:viewsDictionary]];
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_messageLabel]-|" options:0 metrics:metrics views:viewsDictionary]];
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressBar]-|" options:0 metrics:metrics views:viewsDictionary]];
		
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_spinner][self]" options:0 metrics:metrics views:viewsDictionary]];
		[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_spinner][self]" options:0 metrics:metrics views:viewsDictionary]];
	}
	
	
	self.layoutConstraints = layoutConstraints;
	
	//	[UIView animateWithDuration:kSpotDefaultAnimationDuration animations:^{
	//		[self layoutIfNeeded];
	//	}];
	
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	_panelBackground.frame = self.bounds;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

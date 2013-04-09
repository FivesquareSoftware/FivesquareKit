//
//  FSQSegmentedControl.m
//  FivesquareKit
//
//  Created by John Clayton on 2/14/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQSegmentedControl.h"
#import "NSArray+FSQFoundation.h"

@interface FSQSegmentedControl	()
@property (nonatomic, strong) NSMutableArray *segments;
@property (nonatomic, strong)UIImage *defaultBackgroundImage;
@property (nonatomic, strong)UIImage *defaultSelectedBackgroundImage;
@end

@implementation FSQSegmentedControl

// ========================================================================== //

#pragma mark - Properties


- (void) setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
	[self setSelectedSegmentIndex:selectedSegmentIndex generateEvent:NO];
}

- (void) setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex generateEvent:(BOOL)shouldGenerateEvent {
	if (_selectedSegmentIndex != selectedSegmentIndex) {
		if (_selectedSegmentIndex != UISegmentedControlNoSegment) {
			id selectedSegment = [_segments objectAtIndex:(NSUInteger)_selectedSegmentIndex];
			[selectedSegment setSelected:NO];
		}
		id selectingSegment = [_segments objectAtIndex:(NSUInteger)selectedSegmentIndex];
		[selectingSegment setSelected:YES];
		_selectedSegmentIndex = selectedSegmentIndex;
		if (shouldGenerateEvent) {
			[self sendActionsForControlEvents:UIControlEventValueChanged];
		}
	}
}




// ========================================================================== //

#pragma mark - Object



- (void) initialize {
//	self.translatesAutoresizingMaskIntoConstraints = NO;
	_segments = [NSMutableArray new];
	_selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (void) ready {
	self.backgroundColor = [UIColor clearColor];
	
	UISegmentedControl *templateControl = [[UISegmentedControl alloc] initWithItems:@[]];
	_defaultBackgroundImage = [templateControl backgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	_defaultSelectedBackgroundImage = [templateControl backgroundImageForState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	
	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		if ([subview isKindOfClass:[UIButton class]]) {
			UIButton *segment = [self segmentWithButton:(UIButton *)subview];
			[_segments addObject:segment];
		}
	}];
	
	self.selectedSegmentIndex = 0;
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

- (id)initWithItems:(NSArray *)items {
    self = [super initWithFrame:self.frame];
    if (self) {
        [self initialize];
		[items enumerateObjectsUsingBlock:^(NSString *item, NSUInteger idx, BOOL *stop) {
			UIButton *segment = [self segmentWithItem:item];
			[_segments addObject:segment];
		}];
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


- (void) layoutSubviews {
    [super layoutSubviews];
}



// ========================================================================== //

#pragma mark - Appearance

- (void) setbackgroundImageForLeftSegment:(UIImage *)image controlState:(UIControlState)controlState {
	[(UIButton *)[_segments firstObject] setBackgroundImage:image forState:controlState];
}

- (void) setbackgroundImageForMiddleSegments:(UIImage *)image controlState:(UIControlState)controlState {
	if (_segments.count > 2) {
		NSIndexSet *middleIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, _segments.count-2)];
		[_segments enumerateObjectsAtIndexes:middleIndexes options:0 usingBlock:^(UIButton *segment, NSUInteger idx, BOOL *stop) {
			[segment setBackgroundImage:image forState:controlState];
		}];
	}
}

- (void) setbackgroundImageForRightSegment:(UIImage *)image controlState:(UIControlState)controlState {
	[(UIButton *)[_segments lastObject] setBackgroundImage:image forState:controlState];
}

- (void) setTitleColor:(UIColor *)color controlState:(UIControlState)controlState {
	[_segments enumerateObjectsUsingBlock:^(UIButton *segment, NSUInteger idx, BOOL *stop) {
		[segment setTitleColor:color forState:controlState];
	}];
}


// ========================================================================== //

#pragma mark - Helpers

- (UIButton *) segmentWithButton:(UIButton *)segment {
	[segment setReversesTitleShadowWhenHighlighted:YES];
	[segment addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventTouchDown];
	return segment;
}

- (UIButton *) segmentWithItem:(NSString *)item  {
	UIButton *segment = [UIButton buttonWithType:UIButtonTypeCustom];
	[segment setTitle:item forState:UIControlStateNormal];
	[segment setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[segment setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[segment setReversesTitleShadowWhenHighlighted:YES];
	[segment setBackgroundImage:_defaultBackgroundImage forState:UIControlStateNormal];
	[segment setBackgroundImage:_defaultSelectedBackgroundImage forState:UIControlStateSelected];
	[segment addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventTouchDown];
	return segment;
}



// ========================================================================== //

#pragma mark - Actions


- (IBAction) segmentTapped:(id)sender {
	NSUInteger selectedIndex = [_segments indexOfObject:sender];
	[self setSelectedSegmentIndex:(NSInteger)selectedIndex generateEvent:YES];
}



@end

//
//  FSQUIColorToDataTransformer.m
//  FivesquareKit
//
//  Created by John Clayton on 3/26/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQUIColorToDataTransformer.h"

@implementation FSQUIColorToDataTransformer

+ (void) load {
	@autoreleasepool {
		[NSValueTransformer setValueTransformer:[FSQUIColorToDataTransformer new] forName:@"FSQUIColorToDataTransformer"];
	}
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
	return data;
}

- (id)reverseTransformedValue:(id)value {
	id transformedValue = [NSKeyedUnarchiver unarchiveObjectWithData:value];
	return transformedValue;
}

@end

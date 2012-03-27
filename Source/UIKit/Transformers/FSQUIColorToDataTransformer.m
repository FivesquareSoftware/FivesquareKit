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
		[NSValueTransformer setValueTransformer:[FSQUIColorToDataTransformer new] forName:@"UIColorToDataTransformer"];
	}
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

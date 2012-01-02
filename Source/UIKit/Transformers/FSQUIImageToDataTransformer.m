//
//  FSQUIImageToDataTransformer.m
//  FivesquareKit
//
//  Created by John Clayton on 12/31/11.
//  Copyright (c) 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQUIImageToDataTransformer.h"

@implementation FSQUIImageToDataTransformer

+ (void) load {
	@autoreleasepool {
		[NSValueTransformer setValueTransformer:[FSQUIImageToDataTransformer new] forName:@"UIImageToDataTransformer"];
	}
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}

@end

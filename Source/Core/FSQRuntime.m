//
//  FSQRuntime.m
//  FivesquareKit
//
//  Created by John Clayton on 5/29/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQRuntime.h"

#import "FSQAsserter.h"

@implementation FSQRuntime

+ (BOOL) copyMethod:(SEL)aMethod_sel from:(Class)source to:(Class)target overwrite:(BOOL)overwrite {
	BOOL copied = NO;
	Method aMethod_originalMethod = class_getInstanceMethod(target, aMethod_sel);
	Method aMethod_relacementMethod = class_getInstanceMethod(source,aMethod_sel);
	
	if(aMethod_originalMethod == NULL) {
		copied = class_addMethod(target
								, method_getName(aMethod_relacementMethod)
								, method_getImplementation(aMethod_relacementMethod)
								, method_getTypeEncoding(aMethod_relacementMethod));
	} else if(overwrite) {
		IMP oldMethod = method_setImplementation(aMethod_originalMethod, method_getImplementation(aMethod_relacementMethod));
		copied = oldMethod != NULL;
	}
	return copied;
}

+ (BOOL) swizzleMethod:(SEL)originalMethod_sel inTarget:(Class)target withMethod:(SEL)replacementMethod_sel fromSource:(Class)source aliasOriginal:(BOOL)shouldAlias {

	BOOL swizzled = NO;
	Method originalMethod = class_getInstanceMethod(target, originalMethod_sel);
	Method relacementMethod = class_getInstanceMethod(source,replacementMethod_sel);
	
	FSQAssert(originalMethod != NULL, @"Can't swizzle missing original method");
	FSQAssert(relacementMethod != NULL, @"Can't swizzle missing replacement method");

	if(shouldAlias) {
		NSString *aliasMethodName = [NSString stringWithFormat:@"_original%@",NSStringFromSelector(originalMethod_sel)];
		[self aliasMethod:originalMethod_sel to:NSSelectorFromString(aliasMethodName) inClass:target];
	}
	
	swizzled = [self copyMethod:replacementMethod_sel from:source to:target overwrite:YES];
	
	return swizzled;
}

+ (BOOL) aliasMethod:(SEL)originalMethod_sel to:(SEL)newMethod_sel inClass:(Class)klass {
	Method newMethod = class_getInstanceMethod(klass, newMethod_sel);
	
	FSQAssert(newMethod == NULL, @"Original method already aliased %@",NSStringFromSelector(originalMethod_sel));
	
	Method originalMethod = class_getInstanceMethod(klass, originalMethod_sel);
	BOOL aliased = class_addMethod(
								   klass
								   , newMethod_sel
								   , method_getImplementation(originalMethod)
								   , method_getTypeEncoding(originalMethod));
	return aliased;
}





@end

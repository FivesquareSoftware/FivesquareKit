//
//  FSQRuntime.m
//  FivesquareKit
//
//  Created by John Clayton on 5/29/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQRuntime.h"

#import "FSQAsserter.h"
#import "FSQLogging.h"

@implementation FSQRuntime

+ (BOOL) copyInstanceMethod:(SEL)aMethod_sel from:(Class)source to:(Class)target searchInherited:(BOOL)searchInherited overwrite:(BOOL)overwrite {
	Method aMethod_relacementMethod = NULL;
	if (searchInherited) {
		// class_getInstanceMethod will look all the way up the inheritance chain for this method
		aMethod_relacementMethod = class_getInstanceMethod(source,aMethod_sel);
	}
	else {
		// we force the method to exist in the actual source class before we go ahead and copy it
		unsigned int numMethods;
		Method *methods = class_copyMethodList(source, &numMethods);
		for (unsigned int i = 0; i < numMethods; i++) {
			SEL mSel = method_getName(methods[i]);
			if (aMethod_sel == mSel) {
				aMethod_relacementMethod = class_getInstanceMethod(source, aMethod_sel);
				break;
			}
		}
		free(methods);
	}
	
	// same search path as above
	Method aMethod_originalMethod = NULL;
	if (searchInherited) {
		aMethod_originalMethod = class_getInstanceMethod(target, aMethod_sel);
	}
	else {
		unsigned int numMethods;
		Method *methods = class_copyMethodList(target, &numMethods);
		for (unsigned int i = 0; i < numMethods; i++) {
			SEL mSel = method_getName(methods[i]);
			if (aMethod_sel == mSel) {
				aMethod_originalMethod = class_getInstanceMethod(target, aMethod_sel);
				break;
			}
		}
		free(methods);
	}
	
	BOOL copied = NO;

	if(!aMethod_originalMethod) {
		copied = class_addMethod(target, method_getName(aMethod_relacementMethod), method_getImplementation(aMethod_relacementMethod), method_getTypeEncoding(aMethod_relacementMethod));
	} else if(overwrite) {
		IMP oldMethod = method_setImplementation(aMethod_originalMethod, method_getImplementation(aMethod_relacementMethod));
		copied = oldMethod != NULL;
	}
	return copied;
}

+ (BOOL) swizzleInstanceMethod:(SEL)originalMethod_sel inTarget:(Class)target withMethod:(SEL)replacementMethod_sel fromSource:(Class)source aliasOriginal:(BOOL)shouldAlias {	
	Method originalMethod = class_getInstanceMethod(target, originalMethod_sel);
	Method relacementMethod = class_getInstanceMethod(source,replacementMethod_sel);
	
	if (originalMethod == NULL) {
		FLog(@"Can't swizzle, missing original method %@",NSStringFromSelector(originalMethod_sel));
		FSQAssert(NO, @"Can't swizzle, missing original method %@",NSStringFromSelector(originalMethod_sel));
		return NO;
	}

	if (relacementMethod == NULL) {
		FLog(@"Can't swizzle, missing replacement method %@",NSStringFromSelector(replacementMethod_sel));
		FSQAssert(NO, @"Can't swizzle, missing replacement method %@",NSStringFromSelector(replacementMethod_sel));
		return NO;
	}

	if(shouldAlias) {
		NSString *aliasMethodName = [NSString stringWithFormat:@"%@_original",NSStringFromSelector(originalMethod_sel)];
		[self aliasInstanceMethod:originalMethod_sel to:NSSelectorFromString(aliasMethodName) inClass:target];
	}
	
	BOOL swizzled = [self copyInstanceMethod:replacementMethod_sel from:source to:target searchInherited:YES overwrite:YES];
	return swizzled;
}

+ (BOOL) aliasInstanceMethod:(SEL)originalMethod_sel to:(SEL)newMethod_sel inClass:(Class)klass {
	Method newMethod = class_getInstanceMethod(klass, newMethod_sel);
	
	if (newMethod != NULL) {
		FLog(@"Original method already aliased %@",NSStringFromSelector(originalMethod_sel));
		FSQAssert(NO, @"Original method already aliased %@",NSStringFromSelector(originalMethod_sel));
		return NO;
	}
	
	Method originalMethod = class_getInstanceMethod(klass, originalMethod_sel);
	BOOL aliased = class_addMethod(klass, newMethod_sel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
	return aliased;
}


@end

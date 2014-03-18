//
//  ModalAlert.m
//  ModalAlertDemo
//
//  Created by zhang zhiyu on 14-3-17.
//  Copyright (c) 2014年 YK-Unit. All rights reserved.
//

#import "ModalAlert.h"
#import <stdarg.h>

#define TEXT_FIELD_TAG	9998
#define ANOTHER_TEXT_FIELD_TAG  9999

#define IS_IOS_5Plus  ([[UIDevice currentDevice].systemVersion doubleValue] >= 5.0f)

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
	CFRunLoopRef currentLoop;
	NSUInteger index;
    NSString *text;
    NSString *anotherText;
}
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,copy) NSString *anotherText;
@end

@implementation ModalAlertDelegate
@synthesize index,text,anotherText;

-(id) initWithRunLoop: (CFRunLoopRef)runLoop
{
	if (self = [super init])
        currentLoop = runLoop;
	return self;
}

- (void)alertView:(UIAlertView *)aView didDismissWithButtonIndex:(NSInteger)anIndex
{
    index = anIndex;

    UITextField *tf = nil;
    UITextField *another_tf = nil;
    
    if (IS_IOS_5Plus) {
        if (aView.alertViewStyle == UIAlertViewStylePlainTextInput) {
            tf = (UITextField *)[aView textFieldAtIndex:0];
        }else if(aView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput){
            tf = (UITextField *)[aView textFieldAtIndex:0];
            another_tf = (UITextField *)[aView textFieldAtIndex:1];
        }
    }else{
    	tf = (UITextField *)[aView viewWithTag:TEXT_FIELD_TAG];
        another_tf = (UITextField *)[aView viewWithTag:ANOTHER_TEXT_FIELD_TAG];
    }
    
	if (tf){
        self.text = tf.text;
    }
	
    if (another_tf) {
        self.anotherText = another_tf.text;
    }

	CFRunLoopStop(currentLoop);
}

- (BOOL) isLandscape
{
	return ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
}

// Move alert into place to allow keyboard to appear
- (void) moveAlert: (UIAlertView *) alertView
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	if (![self isLandscape])
		alertView.center = CGPointMake(160.0f, 180.0f);
	else
		alertView.center = CGPointMake(240.0f, 90.0f);
	[UIView commitAnimations];
	
	[[alertView viewWithTag:TEXT_FIELD_TAG] becomeFirstResponder];
}

- (void) dealloc
{
    text = nil;
    anotherText = nil;
#if(!__has_feature(objc_arc))
    [super dealloc];
#endif
}

@end

@interface ModalAlert(Private)
+(NSString *) textQueryWith: (NSString *)question withKeyborType:(UIKeyboardType)type prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2;

+ (NSArray *) textQueryWith:(NSString *)question withKeyborType1:(UIKeyboardType)type1 prompt1:(NSString *)prompt1  keyborType:(UIKeyboardType)type2 prompt2:(NSString *)prompt2 button1: (NSString *)button1 button2:(NSString *) button2;

@end

@implementation ModalAlert
+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	// Create Alert
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
    
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:maDelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    for (NSString *buttonTitle in buttons){
        [alertView addButtonWithTitle:buttonTitle];
    }

	[alertView show];
	
	// Wait for response
	CFRunLoopRun();
	
	// Retrieve answer
	NSUInteger answer = maDelegate.index;
#if(!__has_feature(objc_arc))
	[alertView release];
	[maDelegate release];
#endif
	return answer;
}

+ (void) say: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	[ModalAlert ask:statement withCancel:NSLocalizedString(@"YES", @"") withButtons:nil];
#if(!__has_feature(objc_arc))
    [statement release];
#endif
}

+ (BOOL) ask: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = ([ModalAlert ask:statement withCancel:nil withButtons:[NSArray arrayWithObjects:NSLocalizedString(@"YES", @""),NSLocalizedString(@"NO", @""), nil]] == 0);
#if(!__has_feature(objc_arc))
    [statement release];
#endif
	return answer;
}

+ (BOOL) confirm: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = [ModalAlert ask:statement withCancel:NSLocalizedString(@"NO", @"") withButtons:[NSArray arrayWithObject:NSLocalizedString(@"YES", @"")]];
#if(!__has_feature(objc_arc))
    [statement release];
#endif
	return	answer;
}

#pragma mark -
+(NSString *) textQueryWith: (NSString *)question withKeyborType:(UIKeyboardType)type prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2
{
	// Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:maDelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = prompt;
        tf.keyboardType = type;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:maDelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
        
        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = prompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
        [alertView addSubview:tf];
        
#if(!__has_feature(objc_arc))
        [tf release];
#endif
        
        // Set the field to first responder and move it into place
        [maDelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
    
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = maDelegate.index;
    NSString *answer = [maDelegate.text copy];

	if (index == 0) answer = nil; // assumes cancel in position 0
    
#if(!__has_feature(objc_arc))
    [alertView release];
	[maDelegate release];
#endif

	return answer;
}

+ (NSString *) ask: (NSString *) question withKeyborType:(UIKeyboardType)type withTextPrompt: (NSString *) prompt
{
    // Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:maDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = prompt;
        tf.keyboardType = type;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:maDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        
        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = prompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
        [alertView addSubview:tf];
        
#if(!__has_feature(objc_arc))
        [tf release];
#endif
        
        // Set the field to first responder and move it into place
        [maDelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
    
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = maDelegate.index;
    NSString *answer = [maDelegate.text copy];
    
	if (index == 0) answer = nil; // assumes cancel in position 0
    
#if(!__has_feature(objc_arc))
    [alertView release];
	[maDelegate release];
#endif
    
	return answer;
}

+ (NSArray *) ask:(NSString *)question withKeyborType:(UIKeyboardType)type withTextPrompt:(NSString *)prompt  withAnotherKeyborType:(UIKeyboardType)anotherType withAnotherTextPrompt:(NSString *)anotherPrompt;
{
    // Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:maDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = prompt;
        tf.keyboardType = type;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UITextField *another_tf = (UITextField *)[alertView textFieldAtIndex:1];
        another_tf.secureTextEntry = NO;
        another_tf.placeholder = anotherPrompt;
        another_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        another_tf.keyboardType = anotherType;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n\n\n" delegate:maDelegate cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = prompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = type;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Build text field
        UITextField *another_tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 32.0f, 260.0f, 30.0f)];
        another_tf.borderStyle = UITextBorderStyleRoundedRect;
        another_tf.tag = ANOTHER_TEXT_FIELD_TAG;
        another_tf.placeholder = anotherPrompt;
        another_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        another_tf.keyboardType = anotherType;
        another_tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        another_tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        another_tf.autocorrectionType = UITextAutocorrectionTypeNo;
        another_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 30.0f);
        [alertView addSubview:tf];
        
        another_tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f + 10.0f);
        [alertView addSubview:another_tf];
        
#if(!__has_feature(objc_arc))
        [tf release];
        [another_tf release];
#endif
        
        // Set the field to first responder and move it into place
        [maDelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
	
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = maDelegate.index;
    
    NSString *answer = [maDelegate.text copy];
    NSString *anotherAnswer = [maDelegate.anotherText copy];

    if (!answer) {
        answer = @"";
    }
    if (!anotherAnswer) {
        anotherAnswer = @"";
    }
    NSArray *answers = [NSArray arrayWithObjects:answer,anotherAnswer, nil];
	if (index == 0) answers = nil; // assumes cancel in position 0
	
#if(!__has_feature(objc_arc))
    [alertView release];
	[maDelegate release];
#endif

	return answers;
}

+ (NSArray *) askUserNameAndPassword:(NSString *)question withNameKeyborType:(UIKeyboardType)nameType withNameTextPrompt:(NSString *)namePrompt  withPasswordKeyborType:(UIKeyboardType)passwordType withPasswordTextPrompt:(NSString *)passwordPrompt
{
    // Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = nil;
	
    if (IS_IOS_5Plus) {
        alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:maDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        
        UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
        tf.placeholder = namePrompt;
        tf.keyboardType = nameType;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UITextField *another_tf = (UITextField *)[alertView textFieldAtIndex:1];
        another_tf.secureTextEntry = YES;
        another_tf.placeholder = passwordPrompt;
        another_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        another_tf.keyboardType = passwordType;
        
        [alertView show];
    }else{
        alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n\n\n" delegate:maDelegate cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        // Build text field
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = TEXT_FIELD_TAG;
        tf.placeholder = namePrompt;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        //tf.keyboardType = UIKeyboardTypeAlphabet;
        tf.keyboardType = nameType;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // Build text field
        UITextField *another_tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 32.0f, 260.0f, 30.0f)];
        another_tf.borderStyle = UITextBorderStyleRoundedRect;
        another_tf.tag = ANOTHER_TEXT_FIELD_TAG;
        another_tf.placeholder = passwordPrompt;
        another_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        another_tf.keyboardType = passwordType;
        another_tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        another_tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        another_tf.autocorrectionType = UITextAutocorrectionTypeNo;
        another_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        another_tf.secureTextEntry = YES;
        
        // Show alert and wait for it to finish displaying
        [alertView show];
        while (CGRectEqualToRect(alertView.bounds, CGRectZero));
        
        // Find the center for the text field and add it
        CGRect bounds = alertView.bounds;
        tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 30.0f);
        [alertView addSubview:tf];
        
        another_tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f + 10.0f);
        [alertView addSubview:another_tf];
        
#if(!__has_feature(objc_arc))
        [tf release];
        [another_tf release];
#endif
        
        // Set the field to first responder and move it into place
        [maDelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
    }
	
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = maDelegate.index;
    
    NSString *name = [maDelegate.text copy];
    NSString *password = [maDelegate.anotherText copy];
    
    if (!name) {
        name = @"";
    }
    if (!password) {
        password = @"";
    }
    NSArray *answers = [NSArray arrayWithObjects:name,password, nil];
	if (index == 0) answers = nil; // assumes cancel in position 0
	
#if(!__has_feature(objc_arc))
    [alertView release];
	[maDelegate release];
#endif
    
	return answers;
}
@end

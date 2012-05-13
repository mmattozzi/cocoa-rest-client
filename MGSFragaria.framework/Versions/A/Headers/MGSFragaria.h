/*
 *  MGSFragaria.h
 *  Fragaria
 *
 *  Created by Jonathan on 30/04/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// valid keys for 
// - (void)setObject:(id)object forKey:(id)key;
// - (id)objectForKey:(id)key;

// BOOL
extern NSString * const MGSFOIsSyntaxColoured;
extern NSString * const MGSFOShowLineNumberGutter;
extern NSString * const MGSFOIsEdited;

// string
extern NSString * const MGSFOSyntaxDefinitionName;
extern NSString * const MGSFODocumentName;

// integer
extern NSString * const MGSFOGutterWidth;

// NSView *
extern NSString * const ro_MGSFOTextView; // readonly
extern NSString * const ro_MGSFOScrollView; // readonly
extern NSString * const ro_MGSFOGutterScrollView; // readonly

// NSObject
extern NSString * const MGSFODelegate;
extern NSString * const ro_MGSFOLineNumbers; // readonly
extern NSString * const ro_MGSFOSyntaxColouring; // readonly

@class MGSTextMenuController;
@class MGSExtraInterfaceController;

#import "MGSFragariaPreferences.h"

@interface MGSFragaria : NSObject
{
	@private
	id _docSpec;
	MGSExtraInterfaceController *extraInterfaceController;
}

@property (nonatomic, readonly, assign) MGSExtraInterfaceController *extraInterfaceController;

+ (id)currentInstance;
+ (void)setCurrentInstance:(MGSFragaria *)anInstance;

+ (void)initializeFramework;
+ (id)createDocSpec;
+ (void)docSpec:(id)docSpec setString:(NSString *)string;
+ (void)docSpec:(id)docSpec setString:(NSString *)string options:(NSDictionary *)options;
+ (NSString *)stringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringWithTemporaryAttributesAppliedForDocSpec:(id)docSpec;
+ (NSString *)stringForDocSpec:(id)docSpec;

- (id)initWithObject:(id)object;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)embedInView:(NSView *)view;
- (void)setString:(NSString *)aString;
- (void)setString:(NSString *)aString options:(NSDictionary *)options;
- (NSAttributedString *)attributedString;
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied;
- (NSString *)string;
- (id)docSpec;
- (NSTextView *)textView;
- (MGSTextMenuController *)textMenuController;
@end

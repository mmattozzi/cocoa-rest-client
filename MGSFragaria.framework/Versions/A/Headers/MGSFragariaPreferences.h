/*
 *  MGSFragariaPreferences.h
 *  Fragaria
 *
 *  Created by Jonathan on 06/05/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// Fragraria preference keys by type

// color data
// [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
extern NSString * const MGSPrefsCommandsColourWell;
extern NSString * const MGSPrefsCommentsColourWell;
extern NSString * const MGSPrefsInstructionsColourWell;
extern NSString * const MGSPrefsKeywordsColourWell;
extern NSString * const MGSPrefsAutocompleteColourWell;
extern NSString * const MGSPrefsVariablesColourWell;
extern NSString * const MGSPrefsStringsColourWell;
extern NSString * const MGSPrefsAttributesColourWell;
extern NSString * const MGSPrefsBackgroundColourWell;
extern NSString * const MGSPrefsTextColourWell;
extern NSString * const MGSPrefsGutterTextColourWell;
extern NSString * const MGSPrefsInvisibleCharactersColourWell;
extern NSString * const MGSPrefsHighlightLineColourWell;

// bool
extern NSString * const MGSPrefsColourCommands;
extern NSString * const MGSPrefsColourComments;
extern NSString * const MGSPrefsColourInstructions;
extern NSString * const MGSPrefsColourKeywords;
extern NSString * const MGSPrefsColourAutocomplete;
extern NSString * const MGSPrefsColourVariables;
extern NSString * const MGSPrefsColourStrings;	
extern NSString * const MGSPrefsColourAttributes;	
extern NSString * const MGSPrefsLiveUpdatePreview;
extern NSString * const MGSPrefsShowFullPathInWindowTitle;
extern NSString * const MGSPrefsShowLineNumberGutter;
extern NSString * const MGSPrefsSyntaxColourNewDocuments;
extern NSString * const MGSPrefsLineWrapNewDocuments;
extern NSString * const MGSPrefsIndentNewLinesAutomatically;
extern NSString * const MGSPrefsOnlyColourTillTheEndOfLine;
extern NSString * const MGSPrefsShowMatchingBraces;
extern NSString * const MGSPrefsShowInvisibleCharacters;
extern NSString * const MGSPrefsIndentWithSpaces;
extern NSString * const MGSPrefsColourMultiLineStrings;
extern NSString * const MGSPrefsAutocompleteSuggestAutomatically;
extern NSString * const MGSPrefsAutocompleteIncludeStandardWords;
extern NSString * const MGSPrefsAutoSpellCheck;
extern NSString * const MGSPrefsAutoGrammarCheck;
extern NSString * const MGSPrefsSmartInsertDelete;
extern NSString * const MGSPrefsAutomaticLinkDetection;
extern NSString * const MGSPrefsAutomaticQuoteSubstitution;
extern NSString * const MGSPrefsUseTabStops;
extern NSString * const MGSPrefsHighlightCurrentLine;
extern NSString * const MGSPrefsAutomaticallyIndentBraces;
extern NSString * const MGSPrefsAutoInsertAClosingParenthesis;
extern NSString * const MGSPrefsAutoInsertAClosingBrace;

// integer
extern NSString * const MGSPrefsGutterWidth;
extern NSString * const MGSPrefsTabWidth;
extern NSString * const MGSPrefsIndentWidth;
extern NSString * const MGSPrefsShowPageGuideAtColumn;	

// float
extern NSString * const MGSPrefsAutocompleteAfterDelay;	
extern NSString * const MGSPrefsLiveUpdatePreviewDelay;

// font data
// [NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:11]]
extern NSString * const MGSPrefsTextFont;

// string
extern NSString * const MGSPrefsSyntaxColouringPopUpString;


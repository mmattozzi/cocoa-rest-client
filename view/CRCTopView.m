#import "CRCTopView.h"


@implementation CRCTopView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL) isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSImage * image   = [NSImage imageNamed:@"background-header.png"];
	NSRect imageRect  = (NSRect){NSZeroPoint, [image size]};
	NSRect originRect = (NSRect){NSZeroPoint, [self bounds].size};
	
	//NSColor * background = [NSColor colorWithPatternImage:image];
	//[background set];
	//NSRectFill([self bounds]);
	
	[image drawInRect:originRect 
			 fromRect:imageRect 
			operation:NSCompositeSourceOver 
			 fraction:1];
	
}

@end

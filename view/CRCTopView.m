#import "CRCTopView.h"


@implementation CRCTopView


- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(systemTintDidChange:)
                                                    name:NSControlTintDidChangeNotification
                                                  object:nil];
        [self drawGradient];
        
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(systemTintDidChange:)
                                                name:NSControlTintDidChangeNotification
                                              object:nil];
    [self drawGradient];
}

- (void)drawGradient {
    
    NSColor *tintColor = [[NSColor colorForControlTint:[NSColor currentControlTint]]colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    NSColor *tintDarkerColor = [NSColor colorWithRed:tintColor.redComponent - 0.2
                                               green:tintColor.greenComponent - 0.2
                                                blue:tintColor.blueComponent - 0.2
                                               alpha:1];
    _bgGradient = [[NSGradient alloc]initWithStartingColor:tintDarkerColor
                                               endingColor:tintColor];
    [self setNeedsDisplay:YES];
}

- (BOOL) isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [_bgGradient drawInRect:self.bounds angle:90];
}

- (void)systemTintDidChange:(NSNotification*)not {
    [self drawGradient];
}

@end

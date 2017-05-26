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
    NSColor *tintColor = nil;
    NSColor *tintDarkerColor = nil;
    if ([[self identifier] isEqualToString:@"topview"]) {
        tintColor = [[NSColor colorForControlTint:[NSColor currentControlTint]]colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        tintDarkerColor = [NSColor colorWithRed:tintColor.redComponent - 0.2
                                               green:tintColor.greenComponent - 0.2
                                                blue:tintColor.blueComponent - 0.2
                                               alpha:1];
    } else {
        tintColor = [NSColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        tintDarkerColor = [NSColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    }
    _bgGradient = [[NSGradient alloc]initWithStartingColor:tintDarkerColor
                                               endingColor:tintColor];
    line = [[NSBezierPath alloc] init];
    [self setNeedsDisplay:YES];
}

- (BOOL) isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [_bgGradient drawInRect:self.bounds angle:90];
    if ([[self identifier] isEqualToString:@"statusbar"]) {
        [[NSColor darkGrayColor] set];
        [line stroke];
        [line setLineWidth:1.0];
        NSPoint start;
        start.x = self.bounds.origin.x;
        start.y = self.bounds.origin.y + self.bounds.size.height;
        NSPoint end;
        end.x = self.bounds.origin.x + self.bounds.size.width;
        end.y = self.bounds.origin.y + self.bounds.size.height;
        [line moveToPoint:start];
        [line lineToPoint:end];
        [line closePath];
    }
}

- (void)systemTintDidChange:(NSNotification*)not {
    [self drawGradient];
}

@end

Warning: truncated output (original token count: 49875)
Total output lines: 4340

#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>

static const UInt32 SpeedProofCopyHotKeyID = 1;
static const UInt32 SpeedProofPasteHotKeyID = 2;
static const OSType SpeedProofHotKeySignature = 'SPHK';

static BOOL SPHasAutomationAccess(BOOL shouldPrompt) {
    BOOL accessibilityTrusted = AXIsProcessTrusted();
    BOOL eventPostingAllowed = CGPreflightPostEventAccess();
    if ((!accessibilityTrusted || !eventPostingAllowed) && shouldPrompt) {
        CGRequestPostEventAccess();
        NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
        AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    }
    return accessibilityTrusted && eventPostingAllowed;
}

static NSColor *SPColor(NSUInteger hex) {
    return [NSColor colorWithSRGBRed:((hex >> 16) & 0xFF) / 255.0
                              green:((hex >> 8) & 0xFF) / 255.0
                               blue:(hex & 0xFF) / 255.0
                              alpha:1.0];
}

@interface RoundedView : NSView
- (instancetype)initWithColor:(NSColor *)color radius:(CGFloat)radius;
@property(nonatomic, strong) NSColor *fillColor;
- (void)setStrokeColor:(NSColor *)color width:(CGFloat)width;
- (void)setElevationOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(NSSize)offset;
@end

@implementation RoundedView {
    CGFloat _radius;
}

- (instancetype)initWithColor:(NSColor *)color radius:(CGFloat)radius {
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        _fillColor = color;
        _radius = radius;
        self.wantsLayer = YES;
        self.layer.cornerRadius = radius;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.borderColor = [NSColor colorWithRed:0.16 green:0.19 blue:0.23 alpha:1].CGColor;
        self.layer.borderWidth = 0.7;
        self.layer.backgroundColor = color.CGColor;
        self.layer.shadowColor = [NSColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.03;
        self.layer.shadowRadius = 10;
        self.layer.shadowOffset = NSMakeSize(0, -1);
    }
    return self;
}

- (void)setFillColor:(NSColor *)fillColor {
    _fillColor = fillColor;
    self.layer.backgroundColor = fillColor.CGColor;
}

- (void)setStrokeColor:(NSColor *)color width:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)setElevationOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(NSSize)offset {
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
}
@end

@interface HoverButton : NSButton
- (void)setBaseColor:(NSColor *)baseColor hoverColor:(NSColor *)hoverColor;
@end

@implementation HoverButton {
    NSColor *_baseColor;
    NSColor *_hoverColor;
    NSTrackingArea *_trackingArea;
}

- (void)setBaseColor:(NSColor *)baseColor hoverColor:(NSColor *)hoverColor {
    _baseColor = baseColor;
    _hoverColor = hoverColor;
    self.layer.backgroundColor = baseColor.CGColor;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect)
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    (void)event;
    if (!_hoverColor) {
        return;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.14];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    self.layer.backgroundColor = _hoverColor.CGColor;
    [CATransaction commit];
}

- (void)mouseExited:(NSEvent *)event {
    (void)event;
    if (!_baseColor) {
        return;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.18];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    self.layer.backgroundColor = _baseColor.CGColor;
    [CATransaction commit];
}

- (void)mouseDown:(NSEvent *)event {
    CABasicAnimation *press = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    press.fromValue = @1.0;
    press.toValue = @0.975;
    press.duration = 0.08;
    press.autoreverses = YES;
    press.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:press forKey:@"press"];
    [super mouseDown:event];
}
@end

@interface SpeedProofLogoView : NSView
- (void)applyTextColor:(NSColor *)textColor accentColor:(NSColor *)accentColor boltColor:(NSColor *)boltColor;
@end

@implementation SpeedProofLogoView {
    NSColor *_logoTextColor;
    NSColor *_logoAccentColor;
    NSColor *_boltColor;
}

- (instancetype)init {
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _logoTextColor = SPColor(0xF7F4EB);
        _logoAccentColor = SPColor(0x789BFF);
        _boltColor = SPColor(0xFFCA2E);
    }
    return self;
}

- (void)applyTextColor:(NSColor *)textColor accentColor:(NSColor *)accentColor boltColor:(NSColor *)boltColor {
    _logoTextColor = textColor;
    _logoAccentColor = accentColor;
    _boltColor = boltColor;
    [self setNeedsDisplay:YES];
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(286, 50);
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSBezierPath *bolt = [NSBezierPath bezierPath];
    [bolt moveToPoint:NSMakePoint(14.8, 43.0)];
    [bolt lineToPoint:NSMakePoint(4.7, 25.2)];
    [bolt lineToPoint:NSMakePoint(11.5, 25.2)];
    [bolt lineToPoint:NSMakePoint(7.6, 8.0)];
    [bolt lineToPoint:NSMakePoint(23.4, 30.0)];
    [bolt lineToPoint:NSMakePoint(16.0, 30.0)];
    [bolt closePath];

    NSShadow *boltShadow = [NSShadow new];
    boltShadow.shadowColor = [_boltColor colorWithAlphaComponent:0.42];
    boltShadow.shadowBlurRadius = 10;
    boltShadow.shadowOffset = NSMakeSize(0, -1);
    [NSGraphicsContext saveGraphicsState];
    [boltShadow set];
    [_boltColor setFill];
    [bolt fill];
    [NSGraphicsContext restoreGraphicsState];

    NSMutableAttributedString *logo = [[NSMutableAttributedString alloc] initWithString:@"Speed"];
    [logo addAttributes:@{
        NSFontAttributeName: [NSFont fontWithName:@"Georgia" size:31] ?: [NSFont systemFontOfSize:31 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: _logoTextColor
    } range:NSMakeRange(0, logo.length)];

    NSAttributedString *accent = [[NSAttributedString alloc] initWithString:@"Proof"
                                                                 attributes:@{
        NSFontAttributeName: [NSFont fontWithName:@"Georgia Italic" size:31] ?: [NSFont systemFontOfSize:31 weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: _logoAccentColor
    }];
    [logo appendAttributedString:accent];

    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (version.length > 0) {
        NSAttributedString *versionSpacer = [[NSAttributedString alloc] initWithString:@" "
                                                                            attributes:@{
            NSFontAttributeName: [NSFont systemFontOfSize:8.5],
            NSKernAttributeName: @6
        }];
        [logo appendAttributedString:versionSpacer];

        NSAttributedString *versionLabel = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"v%@", version]
                                                                           attributes:@{
            NSFontAttributeName: [NSFont systemFontOfSize:8.5 weight:NSFontWeightSemibold],
            NSForegroundColorAttributeName: [_logoTextColor colorWithAlphaComponent:0.55],
            NSBaselineOffsetAttributeName: @13
        }];
        [logo appendAttributedString:versionLabel];
    }

    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.35];
    shadow.shadowBlurRadius = 6;
    shadow.shadowOffset = NSMakeSize(0, -1);
    [NSGraphicsContext saveGraphicsState];
    shadow.shadowColor = [NSColor colorWithWhite:0 alpha:0.28];
    [shadow set];
    [logo drawAtPoint:NSMakePoint(33, 6)];
    [NSGraphicsContext restoreGraphicsState];
}
@end

@interface LightningRailView : NSView
- (void)setProcessing:(BOOL)processing;
- (void)flashCompletion;
- (void)applyTrackColor:(NSColor *)trackColor nodeColor:(NSColor *)nodeColor accentColor:(NSColor *)accentColor;
@end

@implementation LightningRailView {
    CALayer *_trackLayer;
    CALayer *_beamLayer;
    CALayer *_leftNode;
    CALayer *_rightNode;
    BOOL _processing;
    NSColor *_trackColor;
    NSColor *_nodeColor;
    NSColor *_railAccentColor;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        _trackColor = SPColor(0x3B4A61);
        _nodeColor = SPColor(0x59739E);
        _railAccentColor = SPColor(0xFFCC2E);

        _trackLayer = [CALayer layer];
        _trackLayer.backgroundColor = [_trackColor colorWithAlphaComponent:0.75].CGColor;
        _trackLayer.cornerRadius = 1;

        _beamLayer = [CALayer layer];
        _beamLayer.bounds = CGRectMake(0, 0, 42, 2);
        _beamLayer.backgroundColor = _railAccentColor.CGColor;
        _beamLayer.cornerRadius = 1;
        _beamLayer.shadowColor = _railAccentColor.CGColor;
        _beamLayer.shadowOpacity = 0.95;
        _beamLayer.shadowRadius = 8;
        _beamLayer.shadowOffset = CGSizeZero;
        _beamLayer.opacity = 0;

        _leftNode = [CALayer layer];
        _rightNode = [CALayer layer];
        for (CALayer *node in @[_leftNode, _rightNode]) {
            node.bounds = CGRectMake(0, 0, 6, 6);
            node.cornerRadius = 3;
            node.backgroundColor = _nodeColor.CGColor;
        }

        [self.layer addSublayer:_trackLayer];
        [self.layer addSublayer:_beamLayer];
        [self.layer addSublayer:_leftNode];
        [self.layer addSublayer:_rightNode];
    }
    return self;
}

- (void)layout {
    [super layout];
    CGFloat y = NSMidY(self.bounds);
    CGFloat inset = 7;
    _trackLayer.frame = CGRectMake(inset, y - 1, MAX(0, self.bounds.size.width - inset * 2), 2);
    _leftNode.position = CGPointMake(inset, y);
    _rightNode.position = CGPointMake(MAX(inset, self.bounds.size.width - inset), y);
    if (!_processing) {
        _beamLayer.position = CGPointMake(inset + 21, y);
    }
}

- (void)applyTrackColor:(NSColor *)trackColor nodeColor:(NSColor *)nodeColor accentColor:(NSColor *)accentColor {
    _trackColor = trackColor;
    _nodeColor = nodeColor;
    _railAccentColor = accentColor;
    _beamLayer.backgroundColor = accentColor.CGColor;
    _beamLayer.shadowColor = accentColor.CGColor;
    [self setProcessing:_processing];
    if (!_processing) {
        _trackLayer.backgroundColor = [trackColor colorWithAlphaComponent:0.75].CGColor;
        _leftNode.backgroundColor = nodeColor.CGColor;
        _rightNode.backgroundColor = nodeColor.CGColor;
    }
}

- (void)setProcessing:(BOOL)processing {
    _processing = processing;
    [_beamLayer removeAllAnimations];
    [_rightNode removeAllAnimations];

    if (processing) {
        _beamLayer.opacity = 1;
        _trackLayer.backgroundColor = [[_trackColor blendedColorWithFraction:0.24 ofColor:_railAccentColor] colorWithAlphaComponent:0.85].CGColor;
        _leftNode.backgroundColor = _railAccentColor.CGColor;
        _rightNode.backgroundColor = _nodeColor.CGColor;

        CABasicAnimation *travel = [CABasicAnimation animationWithKeyPath:@"position.x"];
        CGFloat beamHalfWidth = CGRectGetWidth(_beamLayer.bounds) / 2.0;
        CGFloat railInset = 7;
        CGFloat startX = railInset + beamHalfWidth;
        CGFloat endX = MAX(startX, self.bounds.size.width - railInset - beamHalfWidth);
        travel.fromValue = @(startX);
        travel.toValue = @(endX);
        travel.duration = 1.05;
        travel.repeatCount = HUGE_VALF;
        travel.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_beamLayer addAnimation:travel forKey:@"travel"];
    } else {
        _beamLayer.opacity = 0;
        _trackLayer.backgroundColor = [_trackColor colorWithAlphaComponent:0.75].CGColor;
        _leftNode.backgroundColor = _nodeColor.CGColor;
        _rightNode.backgroundColor = _nodeColor.CGColor;
    }
}

- (void)flashCompletion {
    _rightNode.backgroundColor = _railAccentColor.CGColor;
    _rightNode.shadowColor = _railAccentColor.CGColor;
    _rightNode.shadowOpacity = 1;
    _rightNode.shadowRadius = 10;

    CAKeyframeAnimation *pulse = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    pulse.values = @[@1.0, @2.2, @1.0];
    pulse.keyTimes = @[@0, @0.35, @1];
    pulse.duration = 0.52;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_rightNode addAnimation:pulse forKey:@"complete"];
}
@end

@interface TextCardView : RoundedView <NSTextViewDelegate>
- (instancetype)initWithTitle:(NSString *)title tintColor:(NSColor *)tintColor editable:(BOOL)editable;
- (void)setTitleText:(NSString *)title;
- (void)setBodyText:(NSString *)text;
- (void)setAttributedBodyTextValue:(NSAttributedString *)text;
- (NSString *)bodyText;
- (void)setBodyFont:(NSFont *)font;
- (void)setBoldQuotedText:(BOOL)enabled;
- (void)setBodyTopSpacing:(CGFloat)spacing;
- (void)setTitleColor:(NSColor *)color;
- (void)applyFillColor:(NSColor *)fillColor
            titleColor:(NSColor *)titleColor
             bodyColor:(NSColor *)bodyColor
        insertionColor:(NSColor *)insertionColor
           borderColor:(NSColor *)borderColor;
@property(nonatomic, copy) void (^textDidChangeHandler)(NSString *text);
@end

@implementation TextCardView {
    NSTextField *_titleLabel;
    NSTextView *_textView;
    NSScrollView *_scrollView;
    NSLayoutConstraint *_scrollTopConstraint;
    BOOL _editable;
    BOOL _boldQuotedText;
}

- (instancetype)initWithTitle:(NSString *)title tintColor:(NSColor *)tintColor editable:(BOOL)editable {
    self = [super initWithColor:tintColor radius:15];
    if (self) {
        _editable = editable;
        _titleLabel = [NSTextField wrappingLabelWithString:title];
        _titleLabel.font = [NSFont systemFontOfSize:10.5 weight:NSFontWeightSemibold];
        _titleLabel.textColor = [NSColor colorWithRed:0.59 green:0.62 blue:0.67 alpha:1];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _textView = [NSTextView new];
        _textView.editable = editable;
        _textView.selectable = YES;
        _textView.drawsBackground = NO;
        _textView.backgroundColor = NSColor.clearColor;
        _textView.textColor = [NSColor colorWithRed:0.91 green:0.90 blue:0.86 alpha:1];
        _textView.font = [NSFont systemFontOfSize:14.5 weight:NSFontWeightRegular];
        _textView.textContainerInset = NSMakeSize(0, 3);
        _textView.textContainer.widthTracksTextView = YES;
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.horizontallyResizable = NO;
        _textView.verticallyResizable = YES;
        _textView.minSize = NSMakeSize(0, 0);
        _textView.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        _textView.autoresizingMask = NSViewWidthSizable;
        _textView.frame = NSMakeRect(0, 0, 300, 120);
        _textView.insertionPointColor = [NSColor colorWithRed:1.0 green:0.80 blue:0.18 alpha:1];
        if (editable) {
            _textView.delegate = self;
        }

        _scrollView = [NSScrollView new];
        _scrollView.borderType = NSNoBorder;
        _scrollView.drawsBackground = NO;
        _scrollView.hasVerticalScroller = YES;
        _scrollView.hasHorizontalScroller = NO;
        _scrollView.autohidesScrollers = YES;
        _scrollView.documentView = _textView;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_titleLabel];
        [self addSubview:_scrollView];

        _scrollTopConstraint = [_scrollView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:9];

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:14],

            [_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-14],
            _scrollTopConstraint,
            [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-14]
        ]];
    }
    return self;
}

- (void)setBodyText:(NSString *)text {
    NSString *value = text ?: @"";
    if (_boldQuotedText) {
        [_textView.textStorage setAttributedString:[self attributedBodyText:value]];
    } else {
        _textView.string = value;
    }
    [self refreshLayout];
}

- (void)setTitleText:(NSString *)title {
    _titleLabel.stringValue = title ?: @"";
}

- (void)setAttributedBodyTextValue:(NSAttributedString *)text {
    NSAttributedString *value = text ?: [[NSAttributedString alloc] initWithString:@""];
    [_textView.textStorage setAttributedString:value];
    [self refreshLayout];
}

- (NSString *)bodyText {
    return _textView.string ?: @"";
}

- (void)setBodyFont:(NSFont *)font {
    _textView.font = font ?: [NSFont systemFontOfSize:15 weight:NSFontWeightRegular];
    [self refreshLayout];
}

- (void)setBoldQuotedText:(BOOL)enabled {
    _boldQuotedText = enabled;
    [self setBodyText:self.bodyText];
}

- (void)setBodyTopSpacing:(CGFloat)spacing {
    _scrollTopConstraint.constant = spacing;
    [self refreshLayout];
}

- (void)setTitleColor:(NSColor *)color {
    _titleLabel.textColor = color;
}

- (void)applyFillColor:(NSColor *)fillColor
            titleColor:(NSColor *)titleColor
             bodyColor:(NSColor *)bodyColor
        insertionColor:(NSColor *)insertionColor
           borderColor:(NSColor *)borderColor {
    self.fillColor = fillColor;
    [self setStrokeColor:borderColor width:0.8];
    _titleLabel.textColor = titleColor;
    _textView.textColor = bodyColor;
    _textView.insertionPointColor = insertionColor;
    _textView.typingAttributes = @{
        NSFontAttributeName: _textView.font ?: [NSFont systemFontOfSize:14.5 weight:NSFontWeightRegular],
        NSForegroundColorAttributeName: bodyColor
    };
    if (_boldQuotedText) {
        [self setBodyText:self.bodyText];
    }
}

- (NSAttributedString *)attributedBodyText:(NSString *)text {
    NSFont *baseFont = _textView.font ?: [NSFont systemFontOfSize:15 weight:NSFontWeightRegular];
    NSColor *baseColor = _textView.textColor ?: [NSColor textColor];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: baseFont,
        NSForegroundColorAttributeName: baseColor
    }];

    NSFont *boldFont = [[NSFontManager sharedFontManager] convertFont:baseFont toHaveTrait:NSBoldFontMask] ?: [NSFont systemFontOfSize:baseFont.pointSize weight:NSFontWeightSemibold];
    NSArray<NSString *> *patterns = @[@"\"[^\"]+\"", @"«[^»]+»"];
    for (NSString *pattern in patterns) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            [attributed addAttribute:NSFontAttributeName value:boldFont range:match.range];
        }
    }

    return attributed;
}

- (void)textDidChange:(NSNotification *)notification {
    (void)notification;
    [self refreshLayout];
    if (_textDidChangeHandler) {
        _textDidChangeHandler(self.bodyText);
    }
}

- (void)layout {
    [super layout];
    [self refreshLayout];
}

- (void)refreshLayout {
    CGFloat width = MAX(120, _scrollView.contentSize.width);
    _textView.textContainer.containerSize = NSMakeSize(width, CGFLOAT_MAX);
    _textView.frame = NSMakeRect(0, 0, width, MAX(_scrollView.contentSize.height, 40));
    [_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
    NSRect usedRect = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer];
    _textView.frame = NSMakeRect(0, 0, width, MAX(_scrollView.contentSize.height, ceil(usedRect.size.height) + 10));
}
@end

typedef NS_ENUM(NSInteger, TransformMode) {
    TransformModeUnsupported = 0,
    TransformModeTranslateToEnglish,
    TransformModePolishEnglishWithReview,
    TransformModeTranslateToRussian,
};

@interface ModelOption : NSObject
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *modelID;
+ (instancetype)optionWithDisplayName:(NSString *)displayName modelID:(NSString *)modelID;
@end

@implementation ModelOption
+ (instancetype)optionWithDisplayName:(NSString *)displayName modelID:(NSString *)modelID {
    ModelOption *option = [ModelOption new];
    option.displayName = displayName;
    option.modelID = modelID;
    return option;
}
@end

@interface ToneOption : NSObject
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *instruction;
+ (instancetype)optionWithDisplayName:(NSString *)displayName instruction:(NSString *)instruction;
@end

@implementation ToneOption
+ (instancetype)optionWithDisplayName:(NSString *)displayName instruction:(NSString *)instruction {
    ToneOption *option = [ToneOption new];
    option.displayName = displayName;
    option.instruction = instruction;
    return option;
}
@end

@interface LanguageOption : NSObject
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *englishName;
+ (instancetype)optionWithDisplayName:(NSString *)displayName englishName:(NSString *)englishName;
@end

@implementation LanguageOption
+ (instancetype)optionWithDisplayName:(NSString *)displayName englishName:(NSString *)englishName {
    LanguageOption *option = [LanguageOption new];
    option.displayName = displayName;
    option.englishName = englishName;
    return option;
}
@end

@interface APIKeyStore : NSObject
+ (NSString *)loadAPIKey;
+ (BOOL)saveAPIKey:(NSString *)apiKey error:(NSError **)error;
+ (BOOL)deleteAPIKey:(NSError **)error;
@end

@implementation APIKeyStore
+ (NSString *)loadAPIKey {
    NSString *path = [self storagePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) {
        data = [NSData dataWithContentsOfFile:[self legacyStoragePath]];
    }
    if (data.length == 0) {
        return @"";
    }
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
    return [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

+ (BOOL)saveAPIKey:(NSString *)apiKey error:(NSError **)error {
    NSString *trimmed = [apiKey stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSData *data = [trimmed dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:@"SpeedProof" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't save the key."}];
        }
        return NO;
    }

    NSString *directory = [self storageDirectory];
    NSError *directoryError = nil;
    if (![NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&directoryError]) {
        if (error) {
            *error = directoryError ?: [NSError errorWithDomain:@"SpeedProof" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't prepare the app settings folder."}];
        }
        return NO;
    }

    NSDictionary *attributes = @{NSFilePosixPermissions: @0600};
    NSString *path = [self storagePath];
    BOOL wrote = [NSFileManager.defaultManager createFileAtPath:path contents:data attributes:attributes];
    if (!wrote) {
        NSError *writeError = nil;
        wrote = [data writeToFile:path options:NSDataWritingAtomic error:&writeError];
        if (!wrote) {
            if (error) {
                *error = writeError ?: [NSError errorWithDomain:@"SpeedProof" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't write the key to app settings."}];
            }
            return NO;
        }
        [NSFileManager.defaultManager setAttributes:attributes ofItemAtPath:path error:nil];
    }

    return YES;
}

+ (BOOL)deleteAPIKey:(NSError **)error {
    NSString *path = [self storagePath];
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return YES;
    }

    NSError *removeError = nil;
    if ([NSFileManager.defaultManager removeItemAtPath:path error:&removeError]) {
        return YES;
    }
    if (error) {
        *error = removeError ?: [NSError errorWithDomain:@"SpeedProof" code:4 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't remove the key from app settings."}];
    }
    return NO;
}

+ (NSString *)storageDirectory {
    return [self storageDirectoryNamed:@"SpeedProof"];
}

+ (NSString *)legacyStorageDirectory {
    return [self storageDirectoryNamed:@"Grace AI"];
}

+ (NSString *)storageDirectoryNamed:(NSString *)name {
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *baseURL = urls.firstObject ?: [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *directoryURL = [baseURL URLByAppendingPathComponent:name isDirectory:YES];
    return directoryURL.path;
}

+ (NSString *)storagePath {
    return [[self storageDirectory] stringByAppendingPathComponent:@"openai_api_key.txt"];
}

+ (NSString *)legacyStoragePath {
    return [[self legacyStorageDirectory] stringByAppendingPathComponent:@"openai_api_key.txt"];
}
@end

@interface AppSettings : NSObject
+ (NSArray<ModelOption *> *)modelOptions;
+ (ModelOption *)selectedModelOption;
+ (void)setSelectedModelByDisplayName:(NSString *)displayName;
+ (NSArray<LanguageOption *> *)languageOptions;
+ (NSArray<NSString *> *)translationPair;
+ (void)setTranslationLanguageA:(NSString *)languageA languageB:(NSString *)languageB;
+ (NSString *)targetLanguage;
+ (void)setTargetLanguage:(NSString *)language;
+ (NSString *)interfaceLanguage;
+ (void)setInterfaceLanguage:(NSString *)language;
+ (NSString *)englishNameForLanguage:(NSString *)language;
+ (NSArray<ToneOption *> *)toneOptions;
+ (ToneOption *)selectedToneOption;
+ (void)setSelectedToneByDisplayName:(NSString *)displayName;
+ (NSArray<NSString *> *)themeNames;
+ (NSString *)selectedThemeName;
+ (void)setSelectedThemeName:(NSString *)themeName;
+ (NSDictionary<NSString *, NSColor *> *)selectedThemePalette;
+ (BOOL)selectedThemeUsesDarkAppearance;
@end

@implementation AppSettings
+ (NSString *)modelDefaultsKey {
    return @"SpeedProof.SelectedModel";
}

+ (NSString *)targetLanguageDefaultsKey {
    return @"SpeedProof.TargetLanguage";
}

+ (NSString *)translationLanguageADefaultsKey {
    return @"SpeedProof.TranslationLanguageA";
}

+ (NSString *)translationLanguageBDefaultsKey {
    return @"SpeedProof.TranslationLanguageB";
}

+ (NSString *)interfaceLanguageDefaultsKey {
    return @"SpeedProof.InterfaceLanguage";
}

+ (NSString *)toneDefaultsKey {
    return @"SpeedProof.ToneOfVoice";
}

+ (NSString *)themeDefaultsKey {
    return @"SpeedProof.ColorScheme";
}

+ (NSString *)legacyModelDefaultsKey {
    return @"GraceAI.SelectedModel";
}

+ (NSString *)legacyTargetLanguageDefaultsKey {
    return @"GraceAI.TargetLanguage";
}

+ (NSArray<ModelOption *> *)modelOptions {
    static NSArray<ModelOption *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = @[
            [ModelOption optionWithDisplayName:@"Latest (GPT-5.6 Sol)" modelID:@"gpt-5.6"],
            [ModelOption optionWithDisplayName:@"ChatGPT Latest (Instant)" modelID:@"chat-latest"],
            [ModelOption optionWithDisplayName:@"Balanced (GPT-5.6 Terra)" modelID:@"gpt-5.6-terra"],
            [ModelOption optionWithDisplayName:@"Fast (GPT-5.6 Luna)" modelID:@"gpt-5.6-luna"],
            [ModelOption optionWithDisplayName:@"Budget (GPT-5 mini)" modelID:@"gpt-5-mini"]
        ];
    });
    return options;
}

+ (ModelOption *)selectedModelOption {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self modelDefaultsKey]];
    if (saved.length == 0) {
        saved = [NSUserDefaults.standardUserDefaults stringForKey:[self legacyModelDefaultsKey]];
    }
    for (ModelOption *option in [self modelOptions]) {
        if ([option.displayName isEqualToString:saved]) {
            return option;
        }
    }
    NSDictionary<NSString *, NSString *> *legacySelections = @{
        @"Latest (GPT-5.5)": @"Latest (GPT-5.6 Sol)",
        @"Fast (GPT-5.4 mini)": @"Fast (GPT-5.6 Luna)"
    };
    NSString *migratedSelection = legacySelections[saved];
    for (ModelOption *option in [self modelOptions]) {
        if ([option.displayName isEqualToString:migratedSelection]) {
            return option;
        }
    }
    return [self modelOptions].firstObject;
}

+ (void)setSelectedModelByDisplayName:(NSString *)displayName {
    if (displayName.length == 0) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[self modelDefaultsKey]];
        return;
    }
    [NSUserDefaults.standardUserDefaults setObject:displayName forKey:[self modelDefaultsKey]];
}

+ (NSArray<LanguageOption *> *)languageOptions {
    static NSArray<LanguageOption *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = @[
            [LanguageOption optionWithDisplayName:@"English" englishName:@"English"],
            [LanguageOption optionWithDisplayName:@"Russian" englishName:@"Russian"],
            [LanguageOption optionWithDisplayName:@"Spanish" englishName:@"Spanish"],
            [LanguageOption optionWithDisplayName:@"French" englishName:@"French"],
            [LanguageOption optionWithDisplayName:@"German" englishName:@"German"],
            [LanguageOption optionWithDisplayName:@"Portuguese" englishName:@"Portuguese"],
            [LanguageOption optionWithDisplayName:@"Italian" englishName:@"Italian"],
            [LanguageOption optionWithDisplayName:@"Chinese" englishName:@"Chinese"],
            [LanguageOption optionWithDisplayName:@"Japanese" englishName:@"Japanese"],
            [LanguageOption optionWithDisplayName:@"Korean" englishName:@"Korean"],
            [LanguageOption optionWithDisplayName:@"Arabic" englishName:@"Arabic"],
            [LanguageOption optionWithDisplayName:@"Hindi" englishName:@"Hindi"]
        ];
    });
    return options;
}

+ (BOOL)isSupportedLanguage:(NSString *)language {
    for (LanguageOption *option in [self languageOptions]) {
        if ([option.displayName isEqualToString:language]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)normalizedLanguage:(NSString *)language fallback:(NSString *)fallback {
    if ([self isSupportedLanguage:language]) {
        return language;
    }
    return fallback;
}

+ (NSArray<NSString *> *)translationPair {
    NSString *languageA = [NSUserDefaults.standardUserDefaults stringForKey:[self translationLanguageADefaultsKey]];
    NSString *languageB = [NSUserDefaults.standardUserDefaults stringForKey:[self translationLanguageBDefaultsKey]];
    languageA = [self normalizedLanguage:languageA fallback:@"English"];
    languageB = [self normalizedLanguage:languageB fallback:@"Russian"];
    if ([languageA isEqualToString:languageB]) {
        languageB = [languageA isEqualToString:@"English"] ? @"Russian" : @"English";
    }
    return @[languageA, languageB];
}

+ (void)setTranslationLanguageA:(NSString *)languageA languageB:(NSString *)languageB {
    languageA = [self normalizedLanguage:languageA fallback:@"English"];
    languageB = [self normalizedLanguage:languageB fallback:@"Russian"];
    if ([languageA isEqualToString:languageB]) {
        languageB = [languageA isEqualToString:@"English"] ? @"Russian" : @"English";
    }
    [NSUserDefaults.standardUserDefaults setObject:languageA forKey:[self translationLanguageADefaultsKey]];
    [NSUserDefaults.standardUserDefaults setObject:languageB forKey:[self translationLanguageBDefaultsKey]];
    NSString *target = [self targetLanguage];
    if (![target isEqualToString:languageA] && ![target isEqualToString:languageB]) {
        [self setTargetLanguage:languageB];
    }
}

+ (NSString *)targetLanguage {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self targetLanguageDefaultsKey]];
    if (saved.length == 0) {
        saved = [NSUserDefaults.standardUserDefaults stringForKey:[self legacyTargetLanguageDefaultsKey]];
    }
    NSArray<NSString *> *pair = [self translationPair];
    if ([saved isEqualToString:pair[0]] || [saved isEqualToString:pair[1]]) {
        return saved;
    }
    if ([saved isEqualToString:@"Russian"] && [pair containsObject:@"Russian"]) {
        return @"Russian";
    }
    return pair[1];
}

+ (void)setTargetLanguage:(NSString *)language {
    NSArray<NSString *> *pair = [self translationPair];
    if (![language isEqualToString:pair[0]] && ![language isEqualToString:pair[1]]) {
        language = pair[1];
    }
    [NSUserDefaults.standardUserDefaults setObject:language forKey:[self targetLanguageDefaultsKey]];
}

+ (NSString *)interfaceLanguage {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self interfaceLanguageDefaultsKey]];
    return [self normalizedLanguage:saved fallback:@"English"];
}

+ (void)setInterfaceLanguage:(NSString *)language {
    [NSUserDefaults.standardUserDefaults setObject:[self normalizedLanguage:language fallback:@"English"] forKey:[self interfaceLanguageDefaultsKey]];
}

+ (NSString *)englishNameForLanguage:(NSString *)language {
    for (LanguageOption *option in [self languageOptions]) {
        if ([option.displayName isEqualToString:language]) {
            return option.englishName;
        }
    }
    return language.length > 0 ? language : @"English";
}

+ (NSArray<ToneOption *> *)toneOptions {
    static NSArray<ToneOption *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = @[
            [ToneOption optionWithDisplayName:@"Neutral" instruction:@""],
            [ToneOption optionWithDisplayName:@"Polite" instruction:@" Make the final text more polite, warm, and respectful while preserving the original meaning and avoiding unnecessary flattery."],
            [ToneOption optionWithDisplayName:@"Shorter" instruction:@" Make the final text concise and easy to scan while preserving all important meaning."],
            [ToneOption optionWithDisplayName:@"Confident" instruction:@" Make the final text sound clear, confident, and professional while preserving the original meaning."]
        ];
    });
    return options;
}

+ (ToneOption *)selectedToneOption {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self toneDefaultsKey]];
    if (saved.length == 0 && [NSUserDefaults.standardUserDefaults boolForKey:@"SpeedProof.MorePolite"]) {
        saved = @"Polite";
    }
    for (ToneOption *option in [self toneOptions]) {
        if ([option.displayName isEqualToString:saved]) {
            return option;
        }
    }
    return [self toneOptions].firstObject;
}

+ (void)setSelectedToneByDisplayName:(NSString *)displayName {
    if (displayName.length == 0) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[self toneDefaultsKey]];
        return;
    }
    [NSUserDefaults.standardUserDefaults setObject:displayName forKey:[self toneDefaultsKey]];
}

+ (NSArray<NSString *> *)themeNames {
    return @[@"Electric", @"Graphite", @"Arctic", @"Evergreen"];
}

+ (NSString *)selectedThemeName {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self themeDefaultsKey]];
    return [[self themeNames] containsObject:saved] ? saved : @"Electric";
}

+ (void)setSelectedThemeName:(NSString *)themeName {
    NSString *value = [[self themeNames] containsObject:themeName] ? themeName : @"Electric";
    [NSUserDefaults.standardUserDefaults setObject:value forKey:[self themeDefaultsKey]];
}

+ (NSDictionary<NSString *, NSColor *> *)selectedThemePalette {
    NSDictionary<NSString *, NSDictionary<NSString *, NSColor *> *> *palettes = @{
        @"Electric": @{
            @"canvas": SPColor(0x090C10),
            @"surface": SPColor(0x13171E),
            @"surface2": SPColor(0x0E1116),
            @"source": SPColor(0x0F1318),
            @"result": SPColor(0x13161C),
            @"border": SPColor(0x293341),
            @"text": SPColor(0xF5F2E9),
            @"muted": SPColor(0xA0A8B5),
            @"accent": SPColor(0xFFCA2E),
            @"accentForeground": SPColor(0x111318),
            @"secondary": SPColor(0x789BFF),
            @"selection": SPColor(0x34301B),
            @"selectionBorder": SPColor(0x7A6B2B)
        },
        @"Graphite": @{
            @"canvas": SPColor(0x161616),
            @"surface": SPColor(0x242424),
            @"surface2": SPColor(0x1D1D1D),
            @"source": SPColor(0x202020),
            @"result": SPColor(0x272624),
            @"border": SPColor(0x3D3D3D),
            @"text": SPColor(0xF2F0EB),
            @"muted": SPColor(0xABA8A1),
            @"accent": SPColor(0xE8B44A),
            @"accentForeground": SPColor(0x17130D),
            @"secondary": SPColor(0xB9C3D2),
            @"selection": SPColor(0x3B3220),
            @"selectionBorder": SPColor(0x77643A)
        },
        @"Arctic": @{
            @"canvas": SPColor(0xE9EDF2),
            @"surface": SPColor(0xFFFFFF),
            @"surface2": SPColor(0xF3F5F8),
            @"source": SPColor(0xFFFFFF),
            @"result": SPColor(0xF8FAFD),
            @"border": SPColor(0xC7D0DC),
            @"text": SPColor(0x17202B),
            @"muted": SPColor(0x5B6877),
            @"accent": SPColor(0xE7B126),
            @"accentForeground": SPColor(0x17130B),
            @"secondary": SPColor(0x315FD6),
            @"selection": SPColor(0x253044),
            @"selectionBorder": SPColor(0x53657E)
        },
        @"Evergreen": @{
            @"canvas": SPColor(0x0C1513),
            @"surface": SPColor(0x14201D),
            @"surface2": SPColor(0x101A18),
            @"source": SPColor(0x121E1B),
            @"result": SPColor(0x17231F),
            @"border": SPColor(0x29423A),
            @"text": SPColor(0xF0F3EA),
            @"muted": SPColor(0x9BADA5),
            @"accent": SPColor(0xF3C94F),
            @"accentForeground": SPColor(0x111712),
            @"secondary": SPColor(0x6BC8A3),
            @"selection": SPColor(0x30321D),
            @"selectionBorder": SPColor(0x6E7540)
        }
    };
    return palettes[[self selectedThemeName]] ?: palettes[@"Electric"];
}

+ (BOOL)selectedThemeUsesDarkAppearance {
    return ![[self selectedThemeName] isEqualToString:@"Arctic"];
}
@end

@interface ClipboardWindowController : NSObject <NSWindowDelegate>
- (void)show;
- (void)setProcessing:(BOOL)isProcessing;
- (void)setModeText:(NSString *)modeText detail:(NSString *)detail;
- (void)setSourceText:(NSString *)sourceText resultText:(NSString *)resultText;
- (void)setResultText:(NSString *)resultText;
- (void)setAnalysisText:(NSString *)analysisText;
- (void)setAPIKeyAvailable:(BOOL)isAvailable;
- (void)setHistoryItems:(NSArray<NSDictionary *> *)items;
- (void)showIdlePlaceholders;
- (void)showProcessingPlaceholder;
- (void)showReviewPendingPlaceholder;
- (void)showReviewUnavailablePlaceholder;
- (void)setCopyHandler:(void (^)(void))handler;
- (void)setPasteHandler:(void (^)(void))handler;
- (void)setPasteBackHandler:(void (^)(void))handler;
- (void)setPasteBackAvailable:(BOOL)isAvailable applicationName:(NSString *)applicationName;
- (void)setSettingsHandler:(void (^)(void))handler;
- (void)setHistorySelectionHandler:(void (^)(NSInteger index))handler;
- (void)setSourceChangeHandler:(void (^)(NSString *text))handler;
- (void)setTargetLanguageChangeHandler:(void (^)(NSString *language))handler;
- (void)setToneChangeHandler:(void (^)(NSString *tone))handler;
- (void)showCopiedFeedback;
- (void)refreshLanguageControls;
- (void)refreshToneControl;
- (void)applyTheme;
- (NSString *)sourceText;
- (void)refreshCopyButton;
- (NSWindow *)window;
@end

@implementation ClipboardWindowController {
    NSWindow *_window;
    NSVisualEffectView *_backgroundView;
    SpeedProofLogoView *_titleLabel;
    NSTextField *_subtitleLabel;
    RoundedView *_connectionPill;
    NSView *_connectionDot;
    NSTextField *_connectionLabel;
    NSTextField *_statusLabel;
    NSTextField *_detailLabel;
    RoundedView *_statusPill;
    NSView *_statusDot;
    LightningRailView *_energyRail;
    RoundedView *_languageSwitchContainer;
    NSButton *_englishLanguageButton;
    NSButton *_russianLanguageButton;
    NSTextField *_toneLabel;
    NSPopUpButton *_tonePopup;
    NSTextField *_recentLabel;
    NSStackView *_recentStack;
    NSButton *_pasteButton;
    NSButton *_copyButton;
    NSButton *_pasteBackButton;
    NSStackView *_resultActionsStack;
    NSLayoutConstraint *_resultActionsWidthConstraint;
    NSButton *_helpButton;
    NSPopover *_helpPopover;
    NSButton *_settingsButton;
    TextCardView *_sourceCard;
    TextCardView *_resultCard;
    RoundedView *_reviewTabContainer;
    NSButton *_errorReviewTabButton;
    NSButton *_diffViewTabButton;
    TextCardView *_diffCard;
    TextCardView *_analysisCard;
    void (^_copyHandler)(void);
    void (^_pasteHandler)(void);
    void (^_pasteBackHandler)(void);
    void (^_settingsHandler)(void);
    void (^_historySelectionHandler)(NSInteger index);
    void (^_sourceChangeHandler)(NSString *text);
    void (^_targetLanguageChangeHandler)(NSString *language);
    void (^_toneChangeHandler)(NSString *tone);
    BOOL _isProcessing;
    BOOL _didPlaceWindow;
    BOOL _suppressSourceChange;
    BOOL _pasteBackAvailable;
    NSInteger _selectedReviewTab;
    NSTimer *_copyFeedbackTimer;
    NSTimer *_dockBadgeTimer;
}

- (NSColor *)accentColor {
    return [AppSettings selectedThemePalette][@"accent"];
}

- (NSColor *)surfaceColor {
    return [AppSettings selectedThemePalette][@"surface"];
}

- (NSColor *)surface2Color {
    return [AppSettings selectedThemePalette][@"surface2"];
}

- (NSColor *)borderColor {
    return [AppSettings selectedThemePalette][@"border"];
}

- (NSColor *)textColor {
    return [AppSettings selectedThemePalette][@"text"];
}

- (NSColor *)mutedColor {
    return [AppSettings selectedThemePalette][@"muted"];
}

- (NSColor *)canvasColor {
    return [AppSettings selectedThemePalette][@"canvas"];
}

- (NSColor *)sourceSurfaceColor {
    return [AppSettings selectedThemePalette][@"source"];
}

- (NSColor *)resultSurfaceColor {
    return [AppSettings selectedThemePalette][@"result"];
}

- (NSColor *)accentForegroundColor {
    return [AppSettings selectedThemePalette][@"accentForeground"];
}

- (NSColor *)secondaryAccentColor {
    return [AppSettings selectedThemePalette][@"secondary"];
}

- (NSColor *)selectionColor {
    return [AppSettings selectedThemePalette][@"selection"];
}

- (NSColor *)selectionBorderColor {
    return [AppSettings selectedThemePalette][@"selectionBorder"];
}

- (void)applyTheme {
    BOOL dark = [AppSettings selectedThemeUsesDarkAppearance];
    _window.appearance = [NSAppearance appearanceNamed:(dark ? NSAppearanceNameDarkAqua : NSAppearanceNameAqua)];
    _backgroundView.layer.backgroundColor = [[self canvasColor] colorWithAlphaComponent:0.97].CGColor;

    [_titleLabel applyTextColor:[self textColor]
                   accentColor:[self secondaryAccentColor]
                     boltColor:[self accentColor]];
    _subtitleLabel.textColor = [self mutedColor];

    _connectionPill.fillColor = [self selectionColor];
    [_connectionPill setStrokeColor:[self selectionBorderColor] width:0.8];
    _connectionDot.layer.backgroundColor = [self accentColor].CGColor;
    _connectionLabel.textColor = [self accentColor];

    _statusPill.fillColor = [self surface2Color];
    [_statusPill setStrokeColor:[self borderColor] width:0.8];
    _statusLabel.textColor = [self textColor];
    _detailLabel.textColor = [self mutedColor];

    [_sourceCard applyFillColor:[self sourceSurfaceColor]
                     titleColor:[self mutedColor]
                      bodyColor:[self textColor]
                 insertionColor:[self accentColor]
                    borderColor:[self borderColor]];
    [_resultCard applyFillColor:[self resultSurfaceColor]
                     titleColor:[self accentColor]
                      bodyColor:[self textColor]
                 insertionColor:[self accentColor]
                    borderColor:[self selectionBorderColor]];
    [_analysisCard applyFillColor:[self surfaceColor]
                       titleColor:[self mutedColor]
                        bodyColor:[self textColor]
                   insertionColor:[self accentColor]
                      borderColor:[self borderColor]];
    [_diffCard applyFillColor:[self surfaceColor]
                   titleColor:[self mutedColor]
                    bodyColor:[self textColor]
               insertionColor:[self accentColor]
                  borderColor:[self borderColor]];

    _languageSwitchContainer.fillColor = [self surface2Color];
    [_languageSwitchContainer setStrokeColor:[self borderColor] width:0.7];
    _reviewTabContainer.fillColor = [self surface2Color];
    [_reviewTabContainer setStrokeColor:[self borderColor] width:0.7];
    _toneLabel.textColor = [self mutedColor];
    _recentLabel.textColor = [self mutedColor];
    [self styleTonePopup:_tonePopup];
    [self refreshLanguageButtons];
    [self refreshReviewTabs];

    [self styleButton:_pasteButton
           background:[self surface2Color]
           foreground:[self textColor]
               border:[self borderColor]
               radius:9];
    [self decorateButton:_pasteButton
                   title:[self localized:@"paste"]
                  symbol:@"clipboard"
                iconSize:14
                    font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
              foreground:[self textColor]];

    [self styleButton:_pasteBackButton
           background:[self selectionColor]
           foreground:[self textColor]
               border:[self selectionBorderColor]
               radius:12];
    [self decorateButton:_pasteBackButton
                   title:[self localized:@"copyPaste"]
                  symbol:@"clipboard.fill"
                iconSize:15
                    font:[NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]
              foreground:[self textColor]];

    [self styleButton:_helpButton
           background:[self surfaceColor]
           foreground:[self mutedColor]
               border:[self borderColor]
               radius:10];
    [self decorateButton:_helpButton
                   title:@""
                  symbol:@"questionmark.circle.fill"
                iconSize:18
                    font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
              foreground:[self mutedColor]];

    [self styleButton:_settingsButton
           background:[self surfaceColor]
           foreground:[self mutedColor]
               border:[self borderColor]
               radius:10];
    [self decorateButton:_settingsButton
                   title:@""
                  symbol:@"gearshape.fill"
                iconSize:19
                    font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
              foreground:[self mutedColor]];

    [_energyRail applyTrackColor:[self borderColor]
                       nodeColor:[self secondaryAccentColor]
                     accentColor:[self accentColor]];

    for (NSView *view in _recentStack.arrangedSubviews) {
        if ([view isKindOfClass:NSTextField.class]) {
            ((NSTextField *)view).textColor = [self mutedColor];
            continue;
        }
        if (![view isKindOfClass:NSButton.class]) {
            continue;
        }
        NSButton *button = (NSButton *)view;
        NSMutableAttributedString *title = [button.attributedTitle mutableCopy];
        if (title.length == 0) {
            continue;
        }
        [title addAttributes:@{
            NSForegroundColorAttributeName: [self mutedColor],
            NSFontAttributeName: button.font ?: [NSFont systemFontOfSize:11.5 weight:NSFontWeightRegular]
        } range:NSMakeRange(0, title.length)];
        NSRange separator = [title.string rangeOfString:@"   "];
        if (separator.location != NSNotFound && separator.location > 0) {
            [title addAttributes:@{
                NSForegroundColorAttributeName: [self accentColor],
                NSFontAttributeName: [NSFont systemFontOfSize:11 weight:NSFontWeightBold]
            } range:NSMakeRange(0, separator.location)];
        }
        button.attributedTitle = title;
    }

    [self refreshCopyButton];
    [self updateDiffFromSource:_sourceCard.bodyText result:_resultCard.bodyText];
    [_analysisCard setBodyText:_analysisCard.bodyText];
    [self setModeText:_statusLabel.stringValue detail:_detailLabel.stringValue];
}

- (NSString *)localized:(NSString *)key {
    NSString *language = [AppSettings interfaceLanguage];
    NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *strings = @{
        @"English": @{
            @"subtitle": @"One-click AI text cleanup and translation from your clipboard.",
            @"source": @"ORIGINAL TEXT", @"final": @"FINAL TEXT", @"review": @"Error Review", @"diff": @"Diff View",
            @"recent": @"RECENT", @"paste": @"Paste", @"copy": @"Copy final text", @"copyPaste": @"Copy & Paste", @"tone": @"Tone",
            @"noRecent": @"No recent items yet.", @"finalPlaceholder": @"The final text will appear here.",
            @"diffPlaceholder": @"Changes will appear here.", @"reviewPlaceholder": @"Error review will appear here for English text cleanup."
        },
        @"Russian": @{
            @"subtitle": @"Быстро вычитывает, улучшает и переводит текст из буфера обмена.",
            @"source": @"ИСХОДНЫЙ ТЕКСТ", @"final": @"ГОТОВЫЙ ТЕКСТ", @"review": @"Разбор правок", @"diff": @"Что изменилось",
            @"recent": @"ИСТОРИЯ", @"paste": @"Вставить", @"copy": @"Скопировать", @"copyPaste": @"Скопировать и вставить", @"tone": @"Стиль",
            @"noRecent": @"История пока пустая.", @"finalPlaceholder": @"Здесь появится готовый текст.",
            @"diffPlaceholder": @"Здесь появится сравнение исходного и готового текста.", @"reviewPlaceholder": @"Здесь появится разбор правок: что было исправлено и почему так лучше."
        },
        @"Spanish": @{
            @"subtitle": @"Limpieza y traducción de texto con IA desde el portapapeles.",
            @"source": @"TEXTO ORIGINAL", @"final": @"TEXTO FINAL", @"review": @"Revisión de errores", @"diff": @"Vista de cambios",
            @"recent": @"RECIENTE", @"paste": @"Pegar", @"copy": @"Copiar texto final", @"copyPaste": @"Copiar y pegar", @"tone": @"Tono",
            @"noRecent": @"Aún no hay elementos recientes.", @"finalPlaceholder": @"El texto final aparecerá aquí.",
            @"diffPlaceholder": @"Los cambios aparecerán aquí.", @"reviewPlaceholder": @"La revisión aparecerá aquí para mejorar texto en inglés."
        },
        @"French": @{
            @"subtitle": @"Nettoyage et traduction IA depuis le presse-papiers.",
            @"source": @"TEXTE ORIGINAL", @"final": @"TEXTE FINAL", @"review": @"Revue des erreurs", @"diff": @"Vue des changements",
            @"recent": @"RÉCENT", @"paste": @"Coller", @"copy": @"Copier le texte final", @"copyPaste": @"Copier et coller", @"tone": @"Ton",
            @"noRecent": @"Aucun élément récent.", @"finalPlaceholder": @"Le texte final apparaîtra ici.",
            @"diffPlaceholder": @"Les changements apparaîtront ici.", @"reviewPlaceholder": @"La revue apparaîtra ici pour améliorer le texte anglais."
        },
        @"German": @{
            @"subtitle": @"KI-Textkorrektur und Übersetzung direkt aus der Zwischenablage.",
            @"source": @"AUSGANGSTEXT", @"final": @"FINALER TEXT", @"review": @"Fehleranalyse", @"diff": @"Änderungsansicht",
            @"recent": @"ZULETZT", @"paste": @"Einfügen", @"copy": @"Finalen Text kopieren", @"copyPaste": @"Kopieren & einfügen", @"tone": @"Ton",
            @"noRecent": @"Noch keine Einträge.", @"finalPlaceholder": @"Der finale Text erscheint hier.",
            @"diffPlaceholder": @"Änderungen erscheinen hier.", @"reviewPlaceholder": @"Die Fehleranalyse erscheint hier für englische Textkorrektur."
        },
        @"Portuguese": @{
            @"subtitle": @"Limpeza e tradução de texto com IA direto da área de transferência.",
            @"source": @"TEXTO ORIGINAL", @"final": @"TEXTO FINAL", @"review": @"Revisão de erros", @"diff": @"Ver alterações",
            @"recent": @"RECENTE", @"paste": @"Colar", @"copy": @"Copiar texto final", @"copyPaste": @"Copiar e colar", @"tone": @"Tom",
            @"noRecent": @"Ainda não há itens recentes.", @"finalPlaceholder": @"O texto final aparecerá aqui.",
            @"diffPlaceholder": @"As alterações aparecerão aqui.", @"reviewPlaceholder": @"A revisão aparecerá aqui para melhorar texto em inglês."
        },
        @"Italian": @{
            @"subtitle": @"Pulizia e traduzione AI dal tuo appunti.",
            @"source": @"TESTO ORIGINALE", @"final": @"TESTO FINALE", @"review": @"Revisione errori", @"diff": @"Vista modifiche",
            @"recent": @"RECENTI", @"paste": @"Incolla", @"copy": @"Copia testo finale", @"copyPaste": @"Copia e incolla", @"tone": @"Tono",
            @"noRecent": @"Nessun elemento recente.", @"finalPlaceholder": @"Il testo finale apparirà qui.",
            @"diffPlaceholder": @"Le modifiche appariranno qui.", @"reviewPlaceholder": @"La revisione apparirà qui per migliorare il testo inglese."
        },
        @"Chinese": @{
            @"subtitle": @"从剪贴板一键进行 AI 文本清理和翻译。",
            @"source": @"原文", @"final": @"最终文本", @"review": @"错误解析", @"diff": @"差异视图",
            @"recent": @"最近", @"paste": @"粘贴", @"copy": @"复制最终文本", @"copyPaste": @"复制并粘贴", @"tone": @"语气",
            @"noRecent": @"暂无最近项目。", @"finalPlaceholder": @"最终文本会显示在这里。",
            @"diffPlaceholder": @"更改会显示在这里。", @"reviewPlaceholder": @"英文文本优化的错误解析会显示在这里。"
        },
        @"Japanese": @{
            @"subtitle": @"クリップボードから AI で文章を整え翻訳します。",
            @"source": @"元のテキスト", @"final": @"最終テキスト", @"review": @"エラー解説", @"diff": @"差分表示",
            @"recent": @"最近", @"paste": @"貼り付け", @"copy": @"最終テキストをコピー", @"copyPaste": @"コピー＆貼り付け", @"tone": @"トーン",
            @"noRecent": @"最近の項目はありません。", @"finalPlaceholder": @"最終テキストがここに表示されます。",
            @"diffPlaceholder": @"変更点がここに表示されます。", @"reviewPlaceholder": @"英語改善のエラー解説がここに表示されます。"
        },
        @"Korean": @{
            @"subtitle": @"클립보드에서 AI 텍스트 정리와 번역을 한 번에.",
            @"source": @"원문", @"final": @"최종 텍스트", @"review": @"오류 리뷰", @"diff": @"차이 보기",
            @"recent": @"최근", @"paste": @"붙여넣기", @"copy": @"최종 텍스트 복사", @"copyPaste": @"복사 및 붙여넣기", @"tone": @"톤",
            @"noRecent": @"최근 항목이 없습니다.", @"finalPlaceholder": @"최종 텍스트가 여기에 표시됩니다.",
            @"diffPlaceholder": @"변경 내용이 여기에 표시됩니다.", @"reviewPlaceholder": @"영어 문장 개선을 위한 오류 리뷰가 여기에 표시됩니다."
        },
        @"Arabic": @{
            @"subtitle": @"تنظيف وترجمة النص بالذكاء الاصطناعي من الحافظة.",
            @"source": @"النص الأصلي", @"final": @"النص النهائي", @"review": @"مراجعة الأخطاء", @"diff": @"عرض الفروقات",
            @"recent": @"الأحدث", @"paste": @"لصق", @"copy": @"نسخ النص النهائي", @"copyPaste": @"نسخ ولصق", @"tone": @"النبرة",
            @"noRecent": @"لا توجد عناصر حديثة بعد.", @"finalPlaceholder": @"سيظهر النص النهائي هنا.",
            @"diffPlaceholder": @"ستظهر التغييرات هنا.", @"reviewPlaceholder": @"ستظهر مراجعة أخطاء تحسين الإنجليزية هنا."
        },
        @"Hindi": @{
            @"subtitle": @"क्लिपबोर्ड से AI टेक्स्ट सुधार और अनुवाद.",
            @"source": @"मूल टेक्स्ट", @"final": @"अंतिम टेक्स्ट", @"review": @"त्रुटि समीक्षा", @"diff": @"अंतर दृश्य",
            @"recent": @"हाल का", @"paste": @"पेस्ट", @"copy": @"अंतिम टेक्स्ट कॉपी करें", @"copyPaste": @"कॉपी और पेस्ट", @"tone": @"टोन",
            @"noRecent": @"अभी कोई हाल का आइटम नहीं.", @"finalPlaceholder": @"अंतिम टेक्स्ट यहाँ दिखाई देगा.",
            @"diffPlaceholder": @"बदलाव यहाँ दिखाई देंगे.", @"reviewPlaceholder": @"अंग्रेज़ी सुधार के लिए त्रुटि समीक्षा यहाँ दिखाई देगी."
        }
    };
    return strings[language][key] ?: strings[@"English"][key] ?: key;
}

- (NSImage *)symbolNamed:(NSString *)name size:(CGFloat)size {
    NSImage *image = [NSImage imageWithSystemSymbolName:name accessibilityDescription:nil];
    image.size = NSMakeSize(size, size);
    image.template = YES;
    return image;
}

- (void)decorateButton:(NSButton *)button title:(NSString *)title symbol:(NSString *)symbol iconSize:(CGFloat)iconSize font:(NSFont *)font foreground:(NSColor *)foreground {
    for (NSView *view in button.subviews.copy) {
        [view removeFromSuperview];
    }

    button.title = @"";
    button.image = nil;
    button.contentTintColor = foreground;

    NSStackView *stack = [NSStackView new];
    stack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stack.alignment = NSLayoutAttributeC…19875 tokens truncated…endingShouldCopyResultWhenReady = NO;
        _pendingPasteBackTargetApplication = _pasteBackTargetApplication;
        [_windowController showProcessingPlaceholder];
        [_windowController showReviewPendingPlaceholder];
        return;
    }

    _lastProcessedInput = @"";
    [_windowController showProcessingPlaceholder];
    [_windowController showReviewPendingPlaceholder];
    [self processClipboardText:currentText bringToFront:YES copyWhenReady:NO];
}

- (void)scheduleManualInputProcessingForText:(NSString *)text {
    [_manualInputTimer invalidate];

    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    _lastResultText = @"";
    if (!_isProcessing) {
        [_windowController showIdlePlaceholders];
    }

    if (trimmed.length == 0) {
        return;
    }

    if ([trimmed isEqualToString:_lastProcessedInput]) {
        return;
    }

    __weak ClipboardCoordinator *weakSelf = self;
    _manualInputTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer *timer) {
        (void)timer;
        ClipboardCoordinator *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf->_manualInputTimer = nil;
        [strongSelf processManualInputAfterPause:trimmed];
    }];
}

- (void)processManualInputAfterPause:(NSString *)text {
    NSString *currentText = [[_windowController sourceText] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (currentText.length == 0 || ![currentText isEqualToString:text]) {
        return;
    }
    if ([currentText isEqualToString:_lastProcessedInput]) {
        return;
    }
    if (_isProcessing) {
        _pendingClipboardText = currentText;
        _pendingShouldBringToFront = YES;
        _pendingShouldCopyResultWhenReady = NO;
        return;
    }
    [self processClipboardText:currentText bringToFront:YES copyWhenReady:NO];
}

- (NSDictionary<NSString *, NSString *> *)splitFinalTextAndReviewFromOutput:(NSString *)output {
    NSString *trimmed = [output stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSRange finalMarker = [trimmed rangeOfString:@"FINAL_TEXT:" options:NSCaseInsensitiveSearch];
    NSRange reviewMarker = [trimmed rangeOfString:@"ERROR_REVIEW:" options:NSCaseInsensitiveSearch];
    if (finalMarker.location == NSNotFound || reviewMarker.location == NSNotFound || reviewMarker.location <= finalMarker.location) {
        return @{@"final": trimmed ?: @"", @"review": @""};
    }

    NSUInteger finalStart = finalMarker.location + finalMarker.length;
    NSRange finalRange = NSMakeRange(finalStart, reviewMarker.location - finalStart);
    NSUInteger reviewStart = reviewMarker.location + reviewMarker.length;
    NSRange reviewRange = NSMakeRange(reviewStart, trimmed.length - reviewStart);
    NSString *finalText = [[trimmed substringWithRange:finalRange] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *reviewText = [[trimmed substringWithRange:reviewRange] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return @{@"final": finalText.length > 0 ? finalText : trimmed, @"review": reviewText ?: @""};
}

- (BOOL)textLooksLikeEnglish:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"]].location != NSNotFound) {
        return NO;
    }

    NSCharacterSet *letters = NSCharacterSet.letterCharacterSet;
    NSUInteger latinLetters = 0;
    NSUInteger otherLetters = 0;
    for (NSUInteger index = 0; index < text.length; index++) {
        unichar character = [text characterAtIndex:index];
        if ([letters characterIsMember:character]) {
            if (character < 128) {
                latinLetters++;
            } else {
                otherLetters++;
            }
        }
    }
    return latinLetters >= 3 && latinLetters >= otherLetters;
}

- (BOOL)text:(NSString *)text matchesPattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    return [regex firstMatchInString:text ?: @"" options:0 range:NSMakeRange(0, text.length)] != nil;
}

- (BOOL)numberPassesLuhnCheck:(NSString *)number {
    NSInteger sum = 0;
    BOOL doubleDigit = NO;
    for (NSInteger index = (NSInteger)number.length - 1; index >= 0; index--) {
        unichar character = [number characterAtIndex:(NSUInteger)index];
        if (character < '0' || character > '9') {
            continue;
        }
        NSInteger digit = character - '0';
        if (doubleDigit) {
            digit *= 2;
            if (digit > 9) {
                digit -= 9;
            }
        }
        sum += digit;
        doubleDigit = !doubleDigit;
    }
    return sum > 0 && sum % 10 == 0;
}

- (BOOL)textContainsLikelyPaymentCard:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:\\d[ -]?){13,19}"
                                                                           options:0
                                                                             error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:text ?: @"" options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSString *candidate = [text substringWithRange:match.range];
        NSString *digits = [[candidate componentsSeparatedByCharactersInSet:NSCharacterSet.decimalDigitCharacterSet.invertedSet] componentsJoinedByString:@""];
        if (digits.length >= 13 && digits.length <= 19 && [self numberPassesLuhnCheck:digits]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)textContainsOnlyEmailAddresses:(NSString *)text {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return NO;
    }

    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:@"\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\b"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    NSArray<NSTextCheckingResult *> *matches = [emailRegex matchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
    if (matches.count == 0) {
        return NO;
    }

    NSMutableString *remainder = [trimmed mutableCopy];
    for (NSTextCheckingResult *match in matches.reverseObjectEnumerator) {
        [remainder replaceCharactersInRange:match.range withString:@""];
    }
    [remainder replaceOccurrencesOfString:@"mailto:"
                               withString:@""
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, remainder.length)];

    NSCharacterSet *separatorCharacters = [NSCharacterSet characterSetWithCharactersInString:@" \t\r\n,;:<>[](){}\"'`|/\\.-_"];
    NSString *meaningfulRemainder = [[remainder componentsSeparatedByCharactersInSet:separatorCharacters] componentsJoinedByString:@""];
    return meaningfulRemainder.length == 0;
}

- (NSString *)sensitiveTextReasonForText:(NSString *)text {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return @"";
    }

    NSArray<NSDictionary<NSString *, NSString *> *> *patterns = @[
        @{@"pattern": @"sk-(proj-)?[A-Za-z0-9_-]{20,}", @"reason": @"OpenAI API key"},
        @{@"pattern": @"-----BEGIN [A-Z ]*PRIVATE KEY-----", @"reason": @"private key"},
        @{@"pattern": @"\\beyJ[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}\\b", @"reason": @"JWT token"},
        @{@"pattern": @"\\b(password|passwd|pwd|api[_ -]?key|secret|token|access[_ -]?token|refresh[_ -]?token|client[_ -]?secret)\\b\\s*[:=]", @"reason": @"credential"},
        @{@"pattern": @"\\b[A-Fa-f0-9]{48,}\\b", @"reason": @"long hex token"},
        @{@"pattern": @"\\b[A-Za-z0-9+/]{64,}={0,2}\\b", @"reason": @"long encoded token"}
    ];

    for (NSDictionary<NSString *, NSString *> *item in patterns) {
        if ([self text:trimmed matchesPattern:item[@"pattern"]]) {
            return item[@"reason"] ?: @"sensitive text";
        }
    }

    if ([self textContainsLikelyPaymentCard:trimmed]) {
        return @"payment card number";
    }

    return @"";
}

- (BOOL)textLooksLikeMessageToPerson:(NSString *)text {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return NO;
    }

    NSArray<NSString *> *patterns = @[
        @"^\\s*(hi|hello|hey|dear|good\\s+(morning|afternoon|evening)|привет|здравств(уй|уйте)|доброе\\s+утро|добрый\\s+день|добрый\\s+вечер|уважаем(ый|ая|ые))\\b",
        @"\\b(please|could\\s+you|can\\s+you|would\\s+you|would\\s+it\\s+be\\s+possible|thank\\s+you|thanks|regards|best\\s+regards)\\b",
        @"\\b(пожалуйста|можешь|можете|не\\s+мог(?:ли|ла|бы)|подскажите|посмотри|посмотрите|проверь|проверьте|спасибо|с\\s+уважением)\\b",
        @"@[A-Za-zА-Яа-я0-9_][A-Za-zА-Яа-я0-9_.-]{1,}"
    ];

    for (NSString *pattern in patterns) {
        if ([self text:trimmed matchesPattern:pattern]) {
            return YES;
        }
    }
    return NO;
}

- (void)applyAutomaticToneForTextIfNeeded:(NSString *)text {
    if (![self textLooksLikeMessageToPerson:text]) {
        return;
    }
    if ([[AppSettings selectedToneOption].displayName isEqualToString:@"Polite"]) {
        return;
    }
    [AppSettings setSelectedToneByDisplayName:@"Polite"];
    [_windowController refreshToneControl];
}

- (BOOL)skipStandaloneEmailTextIfNeeded:(NSString *)text bringToFront:(BOOL)bringToFront {
    if (![self textContainsOnlyEmailAddresses:text]) {
        return NO;
    }

    [self clearPasteBackTarget];
    _isProcessing = NO;
    _lastResultText = @"";
    _lastProcessedInput = text ?: @"";
    [_windowController setProcessing:NO];
    [_windowController setSourceText:text ?: @"" resultText:@"Email address skipped."];
    [_windowController setAnalysisText:[[AppSettings interfaceLanguage] isEqualToString:@"Russian"]
        ? @"В буфере обмена только email-адрес без текста. SpeedProof не отправил его в OpenAI."
        : @"The clipboard contains only an email address. SpeedProof did not send it to OpenAI."];
    [_windowController setModeText:@"Text skipped"
                            detail:@"Email addresses without surrounding text are ignored."];
    if (bringToFront) {
        [_windowController show];
    }
    return YES;
}

- (BOOL)pauseForSensitiveTextIfNeeded:(NSString *)text bringToFront:(BOOL)bringToFront {
    NSString *reason = [self sensitiveTextReasonForText:text];
    if (reason.length == 0) {
        return NO;
    }

    [self clearPasteBackTarget];
    _isProcessing = NO;
    _lastResultText = @"";
    _lastProcessedInput = text ?: @"";
    [_windowController setProcessing:NO];

    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *currentSource = [[_windowController sourceText] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    BOOL sourceAlreadyVisible = [currentSource isEqualToString:trimmed];
    NSString *sourceText = sourceAlreadyVisible ? text : @"Sensitive text hidden for privacy.";
    [_windowController setSourceText:sourceText resultText:@"Privacy pause: this text was not sent for processing."];
    [_windowController setAnalysisText:[NSString stringWithFormat:@"Локальная проверка обнаружила %@. SpeedProof не отправил этот текст в OpenAI и не сохранил его в истории.", reason]];
    [_windowController setModeText:@"Privacy pause"
                            detail:[NSString stringWithFormat:@"Skipped locally because the text looks like %@.", reason]];
    if (bringToFront) {
        [_windowController show];
    }
    return YES;
}

- (void)startMonitoring {
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    _lastChangeCount = pasteboard.changeCount;
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                selector:@selector(checkPasteboard)
                                                userInfo:nil
                                                 repeats:YES];
    [_windowController setProcessing:NO];
    [_windowController setHistoryItems:_historyItems];
    [self refreshIdleStatus];
}

- (void)checkPasteboard {
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    if (pasteboard.changeCount == _lastChangeCount) {
        return;
    }
    _lastChangeCount = pasteboard.changeCount;

    NSString *text = [pasteboard stringForType:NSPasteboardTypeString];
    if (text.length == 0) {
        return;
    }

    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return;
    }

    if (_optionHotKeyCapturePending) {
        _lastSeenClipboardText = trimmed;
        return;
    }

    if ([_lastAppWrittenClipboardText isEqualToString:trimmed]) {
        _lastSeenClipboardText = trimmed;
        return;
    }

    if ([_lastSeenClipboardText isEqualToString:trimmed] || [_lastProcessedInput isEqualToString:trimmed]) {
        return;
    }

    _lastSeenClipboardText = trimmed;
    BOOL hasRecentlyCapturedTarget = _pasteBackTargetApplication
        && _pasteBackTargetCapturedAt
        && [[NSDate date] timeIntervalSinceDate:_pasteBackTargetCapturedAt] < 1.2;
    NSRunningApplication *sourceApplication = hasRecentlyCapturedTarget
        ? _pasteBackTargetApplication
        : NSWorkspace.sharedWorkspace.frontmostApplication;
    if (!hasRecentlyCapturedTarget
        && sourceApplication.processIdentifier == NSRunningApplication.currentApplication.processIdentifier) {
        sourceApplication = nil;
    }
    if (!sourceApplication && _pasteBackTargetProvider) {
        sourceApplication = _pasteBackTargetProvider();
    }
    if (_isProcessing) {
        _pendingClipboardText = trimmed;
        _pendingShouldBringToFront = NO;
        _pendingShouldCopyResultWhenReady = NO;
        _pendingPasteBackTargetApplication = sourceApplication;
        return;
    }

    [self setPasteBackTargetApplication:sourceApplication optionHotKeyPending:NO];
    [self processClipboardText:trimmed bringToFront:NO copyWhenReady:NO];
}

- (void)processClipboardText:(NSString *)text bringToFront:(BOOL)bringToFront copyWhenReady:(BOOL)copyWhenReady {
    [_manualInputTimer invalidate];
    _manualInputTimer = nil;

    if ([self skipStandaloneEmailTextIfNeeded:text bringToFront:bringToFront]) {
        return;
    }

    if ([self pauseForSensitiveTextIfNeeded:text bringToFront:bringToFront]) {
        return;
    }

    [self applyAutomaticToneForTextIfNeeded:text];

    TransformMode mode = [self modeForText:text];
    if (mode == TransformModeUnsupported) {
        [self clearPasteBackTarget];
        [_windowController setProcessing:NO];
        [_windowController setModeText:@"Text skipped"
                                detail:@"Copy or type text first, then process it."];
        return;
    }

    _isProcessing = YES;
    _currentMode = mode;
    _processingStartedAt = [NSDate date];
    _lastProcessedInput = text;
    _copyResultWhenReady = copyWhenReady;
    if (_pasteBackTargetApplication && ![_pasteBackTargetApplication isTerminated]) {
        [_windowController setPasteBackAvailable:YES
                                 applicationName:_pasteBackTargetApplication.localizedName ?: @"the previous app"];
    } else if (_pasteBackTargetApplication) {
        [self clearPasteBackTarget];
    }
    [_windowController setProcessing:YES];
    [_windowController setSourceText:text resultText:@"Processing text..."];
    if (mode == TransformModePolishEnglishWithReview) {
        [_windowController showReviewPendingPlaceholder];
    } else {
        [_windowController showReviewUnavailablePlaceholder];
    }
    [self startProcessingTimer];
    if (bringToFront) {
        [_windowController show];
    }

    __weak ClipboardCoordinator *weakSelf = self;
    [_bridge transformText:text mode:mode completion:^(NSString *result, NSError *error) {
        ClipboardCoordinator *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf stopProcessingTimer];
        strongSelf->_isProcessing = NO;
        [strongSelf->_windowController setProcessing:NO];
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:strongSelf->_processingStartedAt ?: [NSDate date]];
        BOOL hasPendingDifferentText = strongSelf->_pendingClipboardText.length > 0 && ![strongSelf->_pendingClipboardText isEqualToString:text];

        if (hasPendingDifferentText) {
            strongSelf->_lastResultText = @"";
            [strongSelf->_windowController showProcessingPlaceholder];
            [strongSelf->_windowController showReviewPendingPlaceholder];
        } else if (error || result.length == 0) {
            [strongSelf clearPasteBackTarget];
            NSString *message = error.localizedDescription ?: @"Couldn't process the text.";
            [strongSelf->_windowController setSourceText:text resultText:message];
            [strongSelf->_windowController setAnalysisText:@"Разбор недоступен, потому что обработка завершилась ошибкой."];
            [strongSelf->_windowController setModeText:@"Processing failed"
                                                detail:[NSString stringWithFormat:@"Error after %.1f s. Check OPENAI_API_KEY and your internet connection.", elapsed]];
        } else {
            NSString *finalText = result;
            NSString *reviewText = @"";
            if (mode == TransformModePolishEnglishWithReview) {
                NSDictionary<NSString *, NSString *> *parts = [strongSelf splitFinalTextAndReviewFromOutput:result];
                finalText = parts[@"final"] ?: result;
                reviewText = parts[@"review"] ?: @"";
            }

            strongSelf->_lastResultText = finalText;
            [strongSelf->_windowController setSourceText:text resultText:finalText];
            [strongSelf->_windowController setAnalysisText:(mode == TransformModePolishEnglishWithReview)
                ? (reviewText.length > 0 ? reviewText : @"- Существенных ошибок нет: текст звучит естественно.")
                : ([[AppSettings interfaceLanguage] isEqualToString:@"Russian"] ? @"Разбор правок доступен для улучшения английского текста." : @"Review is available when improving English text.")];
            [strongSelf->_windowController setModeText:@"Done"
                                                detail:[NSString stringWithFormat:@"Processing took %.1f s. You can copy the final text right away.", elapsed]];
            [strongSelf addHistoryItemWithSource:text result:finalText mode:mode];
            if (strongSelf->_pasteBackWhenReady) {
                [strongSelf pasteResultBack];
            } else if (strongSelf->_copyResultWhenReady) {
                [strongSelf copyResultToPasteboard];
            }
        }

        if (hasPendingDifferentText) {
            NSString *pending = strongSelf->_pendingClipboardText;
            BOOL pendingShouldBringToFront = strongSelf->_pendingShouldBringToFront;
            BOOL pendingShouldCopyResultWhenReady = strongSelf->_pendingShouldCopyResultWhenReady;
            NSRunningApplication *pendingPasteBackTarget = strongSelf->_pendingPasteBackTargetApplication;
            strongSelf->_pendingClipboardText = nil;
            strongSelf->_pendingShouldBringToFront = NO;
            strongSelf->_pendingShouldCopyResultWhenReady = NO;
            strongSelf->_pendingPasteBackTargetApplication = nil;
            [strongSelf setPasteBackTargetApplication:pendingPasteBackTarget
                                  optionHotKeyPending:NO];
            [strongSelf processClipboardText:pending bringToFront:pendingShouldBringToFront copyWhenReady:pendingShouldCopyResultWhenReady];
        } else {
            strongSelf->_pendingClipboardText = nil;
            strongSelf->_pendingShouldBringToFront = NO;
            strongSelf->_pendingShouldCopyResultWhenReady = NO;
            strongSelf->_pendingPasteBackTargetApplication = nil;
            strongSelf->_copyResultWhenReady = NO;
        }
    }];
}

- (void)pasteResultBackWhenReady {
    _pasteBackWhenReady = YES;
    if (_isProcessing) {
        return;
    }

    NSString *clipboardText = [NSPasteboard.generalPasteboard stringForType:NSPasteboardTypeString] ?: @"";
    NSString *trimmed = [clipboardText stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    BOOL resultMatchesClipboard = _lastResultText.length > 0
        && ([_lastProcessedInput isEqualToString:trimmed]
            || [_lastResultText isEqualToString:trimmed]
            || [_lastAppWrittenClipboardText isEqualToString:trimmed]);
    if (resultMatchesClipboard) {
        [self pasteResultBack];
        return;
    }

    if (trimmed.length == 0) {
        _pasteBackWhenReady = NO;
        [_windowController setModeText:@"Clipboard is empty"
                                detail:@"Copy text before pressing Option+V."];
        return;
    }

    _lastSeenClipboardText = trimmed;
    [self processClipboardText:trimmed bringToFront:NO copyWhenReady:NO];
}

- (void)startProcessingTimer {
    [_processingTimer invalidate];
    _processingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                        target:self
                                                      selector:@selector(updateProcessingStatus)
                                                      userInfo:nil
                                                       repeats:YES];
    [self updateProcessingStatus];
}

- (void)stopProcessingTimer {
    [_processingTimer invalidate];
    _processingTimer = nil;
}

- (void)updateProcessingStatus {
    if (!_processingStartedAt) {
        return;
    }
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:_processingStartedAt];
    if (_currentMode == TransformModeTranslateToEnglish || _currentMode == TransformModePolishEnglishWithReview) {
        [_windowController setModeText:@"Correcting and translating to English"
                                detail:[NSString stringWithFormat:@"Processing: %.1f s", elapsed]];
    } else {
        [_windowController setModeText:@"Translating to Russian"
                                detail:[NSString stringWithFormat:@"Processing: %.1f s", elapsed]];
    }
}

- (void)copyResultToPasteboard {
    if (_lastResultText.length == 0) {
        return;
    }
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    [pasteboard clearContents];
    [pasteboard setString:_lastResultText forType:NSPasteboardTypeString];
    _lastAppWrittenClipboardText = _lastResultText;
    _lastChangeCount = pasteboard.changeCount;
    [_windowController showCopiedFeedback];
    [_windowController setModeText:@"Final text copied"
                            detail:@"Clipboard updated. You can paste the result wherever you need it."];
}

- (void)pasteResultBack {
    NSRunningApplication *targetApplication = _pasteBackTargetApplication;
    if ((!targetApplication || [targetApplication isTerminated]) && _pasteBackTargetProvider) {
        targetApplication = _pasteBackTargetProvider();
        if (targetApplication && ![targetApplication isTerminated]) {
            [self setPasteBackTargetApplication:targetApplication optionHotKeyPending:NO];
        }
    }
    if (_lastResultText.length == 0) {
        [_windowController setModeText:@"Nothing to paste"
                                detail:@"Wait for the final text to finish processing."];
        return;
    }
    [self copyResultToPasteboard];
    if (!targetApplication || [targetApplication isTerminated]) {
        [self clearPasteBackTarget];
        [_windowController setModeText:@"Final text copied"
                                detail:@"The original app is unavailable, so the result was copied to the clipboard."];
        return;
    }
    if (!SPHasAutomationAccess(YES)) {
        [_windowController setModeText:@"Accessibility access required"
                                detail:@"Allow SpeedProof in System Settings > Privacy & Security > Accessibility, then click Copy & Paste again."];
        return;
    }

    NSString *applicationName = targetApplication.localizedName ?: @"the previous app";
    [_windowController setModeText:@"Pasting final text"
                            detail:[NSString stringWithFormat:@"Returning to %@ and replacing the selected text.", applicationName]];

    AXUIElementRef targetWindow = _pasteBackTargetWindow
        ? (AXUIElementRef)CFRetain(_pasteBackTargetWindow)
        : NULL;
    AXUIElementRef targetElement = _pasteBackTargetElement
        ? (AXUIElementRef)CFRetain(_pasteBackTargetElement)
        : NULL;
    AXValueRef selectedTextRange = _pasteBackSelectedTextRange
        ? (AXValueRef)CFRetain(_pasteBackSelectedTextRange)
        : NULL;
    NSString *finalText = [_lastResultText copy];

    [targetApplication unhide];
    BOOL didActivate = [targetApplication activateWithOptions:NSApplicationActivateAllWindows];
    if (!didActivate) {
        didActivate = [targetApplication activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
    }
    if (!didActivate) {
        if (targetWindow) {
            CFRelease(targetWindow);
        }
        if (targetElement) {
            CFRelease(targetElement);
        }
        if (selectedTextRange) {
            CFRelease(selectedTextRange);
        }
        [_windowController setModeText:@"Couldn't return to the original app"
                                detail:@"The final text is still copied to the clipboard."];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!targetApplication.active) {
            [self->_windowController setModeText:@"Couldn't focus the original app"
                                          detail:@"The final text is copied. Focus the destination and press Command+V."];
        }

        if (targetWindow) {
            AXUIElementSetAttributeValue(targetWindow, kAXMainAttribute, kCFBooleanTrue);
            AXUIElementSetAttributeValue(targetWindow, kAXFocusedAttribute, kCFBooleanTrue);
        }
        if (targetElement) {
            AXUIElementSetAttributeValue(targetElement, kAXFocusedAttribute, kCFBooleanTrue);
            if (selectedTextRange) {
                AXUIElementSetAttributeValue(targetElement,
                                             kAXSelectedTextRangeAttribute,
                                             selectedTextRange);
            }
        }

        BOOL replacedDirectly = NO;
        if (targetElement) {
            Boolean selectedTextIsSettable = false;
            AXError settableError = AXUIElementIsAttributeSettable(targetElement,
                                                                   kAXSelectedTextAttribute,
                                                                   &selectedTextIsSettable);
            if (settableError == kAXErrorSuccess && selectedTextIsSettable) {
                replacedDirectly = AXUIElementSetAttributeValue(targetElement,
                                                                kAXSelectedTextAttribute,
                                                                (__bridge CFTypeRef)finalText) == kAXErrorSuccess;
            }
        }

        if (!replacedDirectly) {
            CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
            CGEventRef keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, true);
            CGEventRef keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, false);
            if (keyDown && keyUp) {
                CGEventSetFlags(keyDown, kCGEventFlagMaskCommand);
                CGEventSetFlags(keyUp, kCGEventFlagMaskCommand);
                CGEventPost(kCGHIDEventTap, keyDown);
                CGEventPost(kCGHIDEventTap, keyUp);
            }
            if (keyDown) {
                CFRelease(keyDown);
            }
            if (keyUp) {
                CFRelease(keyUp);
            }
            if (source) {
                CFRelease(source);
            }
        }
        if (targetWindow) {
            CFRelease(targetWindow);
        }
        if (targetElement) {
            CFRelease(targetElement);
        }
        if (selectedTextRange) {
            CFRelease(selectedTextRange);
        }
        [self clearPasteBackTarget];
        [self->_windowController setModeText:(replacedDirectly ? @"Text replaced" : @"Paste command sent")
                                      detail:(replacedDirectly
                                          ? [NSString stringWithFormat:@"Replaced the selected text in %@.", applicationName]
                                          : [NSString stringWithFormat:@"Returned to %@ and sent Command+V.", applicationName])];
    });
}

- (void)pasteFromPasteboard {
    if (!_pasteBackTargetApplication || [_pasteBackTargetApplication isTerminated]) {
        NSRunningApplication *sourceApplication = _pasteBackTargetProvider
            ? _pasteBackTargetProvider()
            : nil;
        [self setPasteBackTargetApplication:sourceApplication optionHotKeyPending:NO];
    }
    [self pasteFromPasteboardCopyWhenReady:NO];
}

- (void)pasteFromPasteboardAndCopyWhenReady {
    _optionHotKeyCapturePending = NO;
    [self pasteFromPasteboardCopyWhenReady:YES];
}

- (void)pasteFromPasteboardCopyWhenReady:(BOOL)copyWhenReady {
    NSString *text = [NSPasteboard.generalPasteboard stringForType:NSPasteboardTypeString];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        [self clearPasteBackTarget];
        [_windowController setModeText:@"Clipboard is empty"
                                detail:@"Copy text first, then press Paste."];
        return;
    }
    if (_isProcessing) {
        _pendingClipboardText = trimmed;
        _pendingShouldBringToFront = YES;
        _pendingShouldCopyResultWhenReady = copyWhenReady;
        _pendingPasteBackTargetApplication = _pasteBackTargetApplication;
        [_windowController setSourceText:trimmed resultText:@"Queued. I'll process this as soon as the current text is done."];
        [_windowController showReviewPendingPlaceholder];
        return;
    }
    _lastSeenClipboardText = trimmed;
    [self processClipboardText:trimmed bringToFront:YES copyWhenReady:copyWhenReady];
}

- (NSArray<NSDictionary *> *)loadHistoryItems {
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"SpeedProof.HistoryItems"];
    if (![items isKindOfClass:NSArray.class]) {
        items = [NSUserDefaults.standardUserDefaults arrayForKey:@"GraceAI.HistoryItems"];
    }
    if (![items isKindOfClass:NSArray.class]) {
        return @[];
    }
    return items;
}

- (void)saveHistoryItems {
    [NSUserDefaults.standardUserDefaults setObject:_historyItems ?: @[] forKey:@"SpeedProof.HistoryItems"];
}

- (void)addHistoryItemWithSource:(NSString *)source result:(NSString *)result mode:(TransformMode)mode {
    if (source.length == 0 || result.length == 0) {
        return;
    }

    NSString *modeLabel = (mode == TransformModeTranslateToEnglish || mode == TransformModePolishEnglishWithReview) ? @"EN" : @"RU";

    NSDictionary *item = @{
        @"source": source,
        @"result": result,
        @"mode": modeLabel,
        @"targetLanguage": [AppSettings targetLanguage],
        @"createdAt": @([[NSDate date] timeIntervalSince1970])
    };

    NSMutableArray<NSDictionary *> *items = [NSMutableArray arrayWithObject:item];
    for (NSDictionary *existing in _historyItems ?: @[]) {
        if ([existing[@"source"] isEqualToString:source] && [existing[@"result"] isEqualToString:result]) {
            continue;
        }
        [items addObject:existing];
        if (items.count >= 8) {
            break;
        }
    }
    _historyItems = items;
    [self saveHistoryItems];
    [_windowController setHistoryItems:_historyItems];
}

- (void)openSettings {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Settings";
    alert.informativeText = @"Configure your API key, model, languages, and appearance.";
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Clear"];
    [alert addButtonWithTitle:@"Quit SpeedProof"];

    NSView *accessory = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 360, 350)];
    NSTextField *label = [NSTextField wrappingLabelWithString:@"OpenAI API key"];
    label.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    label.translatesAutoresizingMaskIntoConstraints = NO;

    NSSecureTextField *field = [[NSSecureTextField alloc] initWithFrame:NSZeroRect];
    field.placeholderString = @"sk-...";
    field.stringValue = [APIKeyStore loadAPIKey];
    field.translatesAutoresizingMaskIntoConstraints = NO;

    NSTextField *modelLabel = [NSTextField wrappingLabelWithString:@"Model"];
    modelLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    modelLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSPopUpButton *modelPopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    modelPopup.translatesAutoresizingMaskIntoConstraints = NO;
    for (ModelOption *option in [AppSettings modelOptions]) {
        [modelPopup addItemWithTitle:option.displayName];
    }
    [modelPopup selectItemWithTitle:[AppSettings selectedModelOption].displayName];

    NSTextField *pairLabel = [NSTextField wrappingLabelWithString:@"Translation pair"];
    pairLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    pairLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSPopUpButton *languageAPopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    NSPopUpButton *languageBPopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    languageAPopup.translatesAutoresizingMaskIntoConstraints = NO;
    languageBPopup.translatesAutoresizingMaskIntoConstraints = NO;
    for (LanguageOption *option in [AppSettings languageOptions]) {
        [languageAPopup addItemWithTitle:option.displayName];
        [languageBPopup addItemWithTitle:option.displayName];
    }
    NSArray<NSString *> *pair = [AppSettings translationPair];
    [languageAPopup selectItemWithTitle:pair[0]];
    [languageBPopup selectItemWithTitle:pair[1]];

    NSTextField *interfaceLabel = [NSTextField wrappingLabelWithString:@"Interface & Error Review language"];
    interfaceLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    interfaceLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSPopUpButton *interfacePopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    interfacePopup.translatesAutoresizingMaskIntoConstraints = NO;
    for (LanguageOption *option in [AppSettings languageOptions]) {
        [interfacePopup addItemWithTitle:option.displayName];
    }
    [interfacePopup selectItemWithTitle:[AppSettings interfaceLanguage]];

    NSTextField *themeLabel = [NSTextField wrappingLabelWithString:@"Color scheme"];
    themeLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
    themeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSPopUpButton *themePopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    themePopup.translatesAutoresizingMaskIntoConstraints = NO;
    [themePopup addItemsWithTitles:[AppSettings themeNames]];
    [themePopup selectItemWithTitle:[AppSettings selectedThemeName]];

    [accessory addSubview:label];
    [accessory addSubview:field];
    [accessory addSubview:modelLabel];
    [accessory addSubview:modelPopup];
    [accessory addSubview:pairLabel];
    [accessory addSubview:languageAPopup];
    [accessory addSubview:languageBPopup];
    [accessory addSubview:interfaceLabel];
    [accessory addSubview:interfacePopup];
    [accessory addSubview:themeLabel];
    [accessory addSubview:themePopup];
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [label.topAnchor constraintEqualToAnchor:accessory.topAnchor],
        [field.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [field.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [field.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:8],
        [field.heightAnchor constraintEqualToConstant:28],
        [modelLabel.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [modelLabel.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [modelLabel.topAnchor constraintEqualToAnchor:field.bottomAnchor constant:14],
        [modelPopup.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [modelPopup.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [modelPopup.topAnchor constraintEqualToAnchor:modelLabel.bottomAnchor constant:8],
        [modelPopup.heightAnchor constraintEqualToConstant:28],

        [pairLabel.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [pairLabel.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [pairLabel.topAnchor constraintEqualToAnchor:modelPopup.bottomAnchor constant:14],
        [languageAPopup.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [languageAPopup.topAnchor constraintEqualToAnchor:pairLabel.bottomAnchor constant:8],
        [languageAPopup.heightAnchor constraintEqualToConstant:28],
        [languageBPopup.leadingAnchor constraintEqualToAnchor:languageAPopup.trailingAnchor constant:10],
        [languageBPopup.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [languageBPopup.topAnchor constraintEqualToAnchor:languageAPopup.topAnchor],
        [languageBPopup.heightAnchor constraintEqualToAnchor:languageAPopup.heightAnchor],
        [languageAPopup.widthAnchor constraintEqualToAnchor:languageBPopup.widthAnchor],

        [interfaceLabel.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [interfaceLabel.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [interfaceLabel.topAnchor constraintEqualToAnchor:languageAPopup.bottomAnchor constant:14],
        [interfacePopup.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [interfacePopup.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [interfacePopup.topAnchor constraintEqualToAnchor:interfaceLabel.bottomAnchor constant:8],
        [interfacePopup.heightAnchor constraintEqualToConstant:28],

        [themeLabel.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [themeLabel.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [themeLabel.topAnchor constraintEqualToAnchor:interfacePopup.bottomAnchor constant:14],
        [themePopup.leadingAnchor constraintEqualToAnchor:accessory.leadingAnchor],
        [themePopup.trailingAnchor constraintEqualToAnchor:accessory.trailingAnchor],
        [themePopup.topAnchor constraintEqualToAnchor:themeLabel.bottomAnchor constant:8],
        [themePopup.heightAnchor constraintEqualToConstant:28]
    ]];
    alert.accessoryView = accessory;

    NSWindow *window = [_windowController window];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSError *error = nil;
            NSString *value = [field.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            [AppSettings setSelectedModelByDisplayName:modelPopup.selectedItem.title ?: [AppSettings modelOptions].firstObject.displayName];
            [AppSettings setTranslationLanguageA:languageAPopup.selectedItem.title ?: @"English"
                                       languageB:languageBPopup.selectedItem.title ?: @"Russian"];
            [AppSettings setInterfaceLanguage:interfacePopup.selectedItem.title ?: @"English"];
            [AppSettings setSelectedThemeName:themePopup.selectedItem.title ?: @"Electric"];
            [self->_windowController applyTheme];
            [self->_windowController refreshLanguageControls];
            if (value.length == 0) {
                [self->_windowController setModeText:@"Settings updated"
                                              detail:@"Model, languages, and appearance were saved. Add your OpenAI API key when you're ready."];
                return;
            }
            if ([APIKeyStore saveAPIKey:value error:&error]) {
                [self->_windowController setModeText:@"Settings saved"
                                              detail:[NSString stringWithFormat:@"API key saved. SpeedProof will process text using %@.", [AppSettings selectedModelOption].displayName]];
            } else {
                [self->_windowController setModeText:@"Couldn't save key"
                                              detail:error.localizedDescription ?: @"Please try again."];
            }
            [self refreshIdleStatus];
            [self processCurrentSourceAfterOptionChange];
            return;
        }

        if (returnCode == NSAlertThirdButtonReturn) {
            NSError *error = nil;
            if ([APIKeyStore deleteAPIKey:&error]) {
                [self->_windowController setModeText:@"Key cleared"
                                              detail:@"Your OpenAI API key was removed from app settings."];
            } else {
                [self->_windowController setModeText:@"Couldn't clear key"
                                              detail:error.localizedDescription ?: @"Please try again."];
            }
            [self refreshIdleStatus];
            return;
        }

        if (returnCode == NSAlertThirdButtonReturn + 1) {
            [NSApp terminate:nil];
        }
    }];
}

- (void)refreshIdleStatus {
    if (_isProcessing) {
        return;
    }
    BOOL hasAPIKey = [APIKeyStore loadAPIKey].length > 0 || [NSProcessInfo.processInfo.environment[@"OPENAI_API_KEY"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length > 0;
    [_windowController setAPIKeyAvailable:hasAPIKey];
    if (hasAPIKey) {
        [_windowController setModeText:@"Watching the clipboard"
                                detail:@"Copy text or type it manually in the original text field."];
    } else {
        [_windowController setModeText:@"OpenAI API key required"
                                detail:@"Click the gear in the top-right corner and add your key so I can process text."];
    }
}

- (TransformMode)modeForText:(NSString *)text {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        return TransformModeUnsupported;
    }
    if ([[AppSettings targetLanguage] isEqualToString:@"English"]) {
        return [self textLooksLikeEnglish:trimmed] ? TransformModePolishEnglishWithReview : TransformModeTranslateToEnglish;
    }
    return TransformModeTranslateToRussian;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
- (void)handleHotKey;
- (void)handlePasteHotKey;
@end

static OSStatus SpeedProofHotKeyHandler(EventHandlerCallRef nextHandler, EventRef event, void *userData) {
    (void)nextHandler;
    EventHotKeyID hotKeyID;
    OSStatus status = GetEventParameter(event,
                                        kEventParamDirectObject,
                                        typeEventHotKeyID,
                                        NULL,
                                        sizeof(hotKeyID),
                                        NULL,
                                        &hotKeyID);
    if (status != noErr || hotKeyID.signature != SpeedProofHotKeySignature) {
        return eventNotHandledErr;
    }

    AppDelegate *delegate = (__bridge AppDelegate *)userData;
    if (hotKeyID.id == SpeedProofCopyHotKeyID) {
        [delegate handleHotKey];
    } else if (hotKeyID.id == SpeedProofPasteHotKeyID) {
        [delegate handlePasteHotKey];
    } else {
        return eventNotHandledErr;
    }
    return noErr;
}

@implementation AppDelegate {
    ClipboardWindowController *_windowController;
    ClipboardCoordinator *_coordinator;
    NSStatusItem *_statusItem;
    EventHotKeyRef _hotKeyRef;
    EventHotKeyRef _pasteHotKeyRef;
    EventHandlerRef _hotKeyHandlerRef;
    id _globalCopyMonitor;
    BOOL _isPostingSyntheticCopy;
    NSRunningApplication *_lastExternalApplication;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self
                                                       selector:@selector(workspaceDidActivateApplication:)
                                                           name:NSWorkspaceDidActivateApplicationNotification
                                                         object:nil];
    _windowController = [ClipboardWindowController new];
    _coordinator = [[ClipboardCoordinator alloc] initWithWindowController:_windowController];
    __weak AppDelegate *weakSelf = self;
    [_coordinator setPasteBackTargetProvider:^NSRunningApplication *{
        return [weakSelf pasteBackSourceApplication];
    }];
    [self configureStatusItem];
    [_windowController show];
    [_coordinator startMonitoring];
    [self registerHotKey];
    [self registerCommandCopyMonitor];
}

- (void)workspaceDidActivateApplication:(NSNotification *)notification {
    NSRunningApplication *application = notification.userInfo[NSWorkspaceApplicationKey];
    if (!application
        || application.processIdentifier == NSRunningApplication.currentApplication.processIdentifier) {
        return;
    }
    _lastExternalApplication = application;
}

- (NSRunningApplication *)pasteBackSourceApplication {
    NSRunningApplication *application = NSWorkspace.sharedWorkspace.frontmostApplication;
    if (!application
        || application.processIdentifier == NSRunningApplication.currentApplication.processIdentifier) {
        application = _lastExternalApplication;
    }
    return application.isTerminated ? nil : application;
}

- (void)registerCommandCopyMonitor {
    __weak AppDelegate *weakSelf = self;
    _globalCopyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                                               handler:^(NSEvent *event) {
        AppDelegate *strongSelf = weakSelf;
        if (!strongSelf || strongSelf->_isPostingSyntheticCopy) {
            return;
        }
        NSEventModifierFlags modifiers = event.modifierFlags & NSEventModifierFlagDeviceIndependentFlagsMask;
        BOOL isCommandCopy = event.keyCode == kVK_ANSI_C
            && (modifiers & NSEventModifierFlagCommand) != 0
            && (modifiers & NSEventModifierFlagOption) == 0;
        if (!isCommandCopy) {
            return;
        }
        NSRunningApplication *sourceApplication = [strongSelf pasteBackSourceApplication];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf->_coordinator setPasteBackTargetApplication:sourceApplication
                                                optionHotKeyPending:NO];
        });
    }];
}

- (NSImage *)statusBarIcon {
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(22, 22)];
    image.template = NO;
    [image lockFocus];

    NSBezierPath *outline = [NSBezierPath bezierPath];
    [outline moveToPoint:NSMakePoint(12.8, 1.9)];
    [outline lineToPoint:NSMakePoint(18.6, 9.1)];
    [outline lineToPoint:NSMakePoint(13.7, 9.1)];
    [outline lineToPoint:NSMakePoint(16.5, 20.2)];
    [outline lineToPoint:NSMakePoint(4.4, 7.8)];
    [outline lineToPoint:NSMakePoint(9.8, 7.8)];
    [outline lineToPoint:NSMakePoint(7.6, 1.9)];
    [outline closePath];

    [[NSColor colorWithWhite:0 alpha:0.42] setStroke];
    outline.lineWidth = 3.2;
    [outline stroke];

    [[NSColor colorWithRed:1.0 green:0.80 blue:0.10 alpha:1] setFill];
    [outline fill];

    [[NSColor colorWithRed:1.0 green:0.93 blue:0.36 alpha:1] setStroke];
    outline.lineWidth = 0.8;
    [outline stroke];

    [image unlockFocus];
    return image;
}

- (void)configureStatusItem {
    _statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    NSStatusBarButton *button = _statusItem.button;
    button.toolTip = @"SpeedProof";
    button.image = nil;
    button.title = @"⚡ SpeedProof";
    button.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    button.contentTintColor = [NSColor colorWithRed:1.0 green:0.80 blue:0.10 alpha:1];

    NSMenu *menu = [NSMenu new];
    NSMenuItem *titleItem = [[NSMenuItem alloc] initWithTitle:@"SpeedProof" action:nil keyEquivalent:@""];
    titleItem.enabled = NO;
    [menu addItem:titleItem];
    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open SpeedProof"
                                                      action:@selector(openWindowFromMenuBar:)
                                               keyEquivalent:@""];
    openItem.target = self;
    [menu addItem:openItem];

    NSMenuItem *pasteItem = [[NSMenuItem alloc] initWithTitle:@"Paste & Process"
                                                       action:@selector(pasteFromMenuBar:)
                                                keyEquivalent:@"c"];
    pasteItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
    pasteItem.target = self;
    [menu addItem:pasteItem];

    NSMenuItem *pasteResultItem = [[NSMenuItem alloc] initWithTitle:@"Paste Result in Previous App"
                                                             action:@selector(pasteResultFromMenuBar:)
                                                      keyEquivalent:@"v"];
    pasteResultItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
    pasteResultItem.target = self;
    [menu addItem:pasteResultItem];

    NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy Final Text"
                                                      action:@selector(copyFromMenuBar:)
                                               keyEquivalent:@""];
    copyItem.target = self;
    [menu addItem:copyItem];

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                                          action:@selector(openSettingsFromMenuBar:)
                                                   keyEquivalent:@","];
    settingsItem.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    settingsItem.target = self;
    [menu addItem:settingsItem];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit SpeedProof"
                                                      action:@selector(terminate:)
                                               keyEquivalent:@"q"];
    quitItem.target = NSApp;
    [menu addItem:quitItem];

    _statusItem.menu = menu;
}

- (void)openWindowFromMenuBar:(id)sender {
    (void)sender;
    [_windowController show];
}

- (void)pasteFromMenuBar:(id)sender {
    (void)sender;
    [_windowController show];
    [_coordinator pasteFromPasteboard];
}

- (void)copyFromMenuBar:(id)sender {
    (void)sender;
    [_coordinator copyResultToPasteboard];
}

- (void)pasteResultFromMenuBar:(id)sender {
    (void)sender;
    NSRunningApplication *sourceApplication = [self pasteBackSourceApplication];
    [_coordinator setPasteBackTargetApplication:sourceApplication optionHotKeyPending:NO];
    [_coordinator pasteResultBackWhenReady];
}

- (void)openSettingsFromMenuBar:(id)sender {
    (void)sender;
    [_windowController show];
    [_coordinator openSettings];
}

- (void)registerHotKey {
    EventTypeSpec eventType = {
        .eventClass = kEventClassKeyboard,
        .eventKind = kEventHotKeyPressed
    };
    OSStatus handlerStatus = InstallApplicationEventHandler(&SpeedProofHotKeyHandler,
                                                            1,
                                                            &eventType,
                                                            (__bridge void *)self,
                                                            &_hotKeyHandlerRef);
    if (handlerStatus != noErr) {
        [_windowController setModeText:@"Hotkey unavailable"
                                detail:@"Couldn't register Option+C handler."];
        return;
    }

    EventHotKeyID hotKeyID = {
        .signature = SpeedProofHotKeySignature,
        .id = SpeedProofCopyHotKeyID
    };
    OSStatus hotKeyStatus = RegisterEventHotKey(kVK_ANSI_C,
                                                optionKey,
                                                hotKeyID,
                                                GetApplicationEventTarget(),
                                                0,
                                                &_hotKeyRef);
    if (hotKeyStatus != noErr) {
        if (_hotKeyHandlerRef) {
            RemoveEventHandler(_hotKeyHandlerRef);
            _hotKeyHandlerRef = NULL;
        }
        [_windowController setModeText:@"Hotkey unavailable"
                                detail:@"Option+C is already used by another app or system shortcut."];
        return;
    }

    EventHotKeyID pasteHotKeyID = {
        .signature = SpeedProofHotKeySignature,
        .id = SpeedProofPasteHotKeyID
    };
    OSStatus pasteHotKeyStatus = RegisterEventHotKey(kVK_ANSI_V,
                                                     optionKey,
                                                     pasteHotKeyID,
                                                     GetApplicationEventTarget(),
                                                     0,
                                                     &_pasteHotKeyRef);
    if (pasteHotKeyStatus != noErr) {
        [_windowController setModeText:@"Paste hotkey unavailable"
                                detail:@"Option+V is already used by another app or system shortcut."];
    }
}

- (void)unregisterHotKey {
    if (_hotKeyRef) {
        UnregisterEventHotKey(_hotKeyRef);
        _hotKeyRef = NULL;
    }
    if (_pasteHotKeyRef) {
        UnregisterEventHotKey(_pasteHotKeyRef);
        _pasteHotKeyRef = NULL;
    }
    if (_hotKeyHandlerRef) {
        RemoveEventHandler(_hotKeyHandlerRef);
        _hotKeyHandlerRef = NULL;
    }
}

- (void)copySelectionToPasteboard {
    _isPostingSyntheticCopy = YES;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, true);
    CGEventRef keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, false);
    CGEventSetFlags(keyDown, kCGEventFlagMaskCommand);
    CGEventSetFlags(keyUp, kCGEventFlagMaskCommand);
    CGEventPost(kCGHIDEventTap, keyDown);
    CGEventPost(kCGHIDEventTap, keyUp);
    if (keyDown) {
        CFRelease(keyDown);
    }
    if (keyUp) {
        CFRelease(keyUp);
    }
    if (source) {
        CFRelease(source);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isPostingSyntheticCopy = NO;
    });
}

- (void)handleHotKey {
    NSRunningApplication *sourceApplication = [self pasteBackSourceApplication];
    if (!SPHasAutomationAccess(YES)) {
        [_coordinator setPasteBackTargetApplication:sourceApplication optionHotKeyPending:NO];
        [_windowController show];
        [_windowController setModeText:@"Accessibility access required"
                                detail:@"Allow SpeedProof in System Settings > Privacy & Security > Accessibility, then press Option+C again."];
        return;
    }
    NSInteger pasteboardChangeCount = NSPasteboard.generalPasteboard.changeCount;
    [_coordinator setPasteBackTargetApplication:sourceApplication optionHotKeyPending:YES];
    [self copySelectionToPasteboard];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.18 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_windowController show];
        if (NSPasteboard.generalPasteboard.changeCount == pasteboardChangeCount) {
            [self->_coordinator clearPasteBackTarget];
            [self->_windowController setModeText:@"Couldn't copy the selection"
                                          detail:@"Select editable text in another app, then press Option+C again."];
            return;
        }
        [self->_coordinator pasteFromPasteboardAndCopyWhenReady];
    });
}

- (void)handlePasteHotKey {
    NSRunningApplication *sourceApplication = [self pasteBackSourceApplication];
    [_coordinator setPasteBackTargetApplication:sourceApplication optionHotKeyPending:NO];
    if (!SPHasAutomationAccess(YES)) {
        [_windowController setModeText:@"Accessibility access required"
                                detail:@"Allow SpeedProof in System Settings > Privacy & Security > Accessibility, then press Option+V again."];
        return;
    }
    [_coordinator pasteResultBackWhenReady];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    (void)sender;
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    (void)sender;
    (void)flag;
    [_windowController show];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
    [self unregisterHotKey];
    if (_globalCopyMonitor) {
        [NSEvent removeMonitor:_globalCopyMonitor];
        _globalCopyMonitor = nil;
    }
    if (_statusItem) {
        [NSStatusBar.systemStatusBar removeStatusItem:_statusItem];
        _statusItem = nil;
    }
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        return NSApplicationMain(argc, argv);
    }
}

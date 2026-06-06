#import <AppKit/AppKit.h>
@interface RoundedView : NSView
- (instancetype)initWithColor:(NSColor *)color radius:(CGFloat)radius;
@property(nonatomic, strong) NSColor *fillColor;
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
        self.layer.borderColor = [NSColor colorWithRed:0.20 green:0.18 blue:0.14 alpha:1].CGColor;
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
@end

@interface GraceLogoView : NSView
@end

@implementation GraceLogoView
- (instancetype)init {
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(150, 40);
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSMutableAttributedString *logo = [[NSMutableAttributedString alloc] initWithString:@"Grace"];
    [logo addAttributes:@{
        NSFontAttributeName: [NSFont fontWithName:@"Georgia" size:30] ?: [NSFont systemFontOfSize:30 weight:NSFontWeightLight],
        NSForegroundColorAttributeName: [NSColor colorWithRed:0.96 green:0.94 blue:0.90 alpha:1]
    } range:NSMakeRange(0, logo.length)];

    NSAttributedString *accent = [[NSAttributedString alloc] initWithString:@" AI"
                                                                 attributes:@{
        NSFontAttributeName: [NSFont fontWithName:@"Georgia Italic" size:30] ?: [NSFont systemFontOfSize:30 weight:NSFontWeightLight],
        NSForegroundColorAttributeName: [NSColor colorWithRed:0.42 green:0.57 blue:0.95 alpha:1]
    }];
    [logo appendAttributedString:accent];
    [logo drawAtPoint:NSMakePoint(0, 1)];
}
@end

@interface TextCardView : RoundedView
- (instancetype)initWithTitle:(NSString *)title tintColor:(NSColor *)tintColor editable:(BOOL)editable;
- (void)setBodyText:(NSString *)text;
- (NSString *)bodyText;
@end

@implementation TextCardView {
    NSTextField *_titleLabel;
    NSTextView *_textView;
    NSScrollView *_scrollView;
    BOOL _editable;
}

- (instancetype)initWithTitle:(NSString *)title tintColor:(NSColor *)tintColor editable:(BOOL)editable {
    self = [super initWithColor:tintColor radius:16];
    if (self) {
        _editable = editable;
        _titleLabel = [NSTextField wrappingLabelWithString:title];
        _titleLabel.font = [NSFont systemFontOfSize:10.5 weight:NSFontWeightBold];
        _titleLabel.textColor = [NSColor colorWithRed:0.53 green:0.49 blue:0.43 alpha:1];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _textView = [NSTextView new];
        _textView.editable = editable;
        _textView.selectable = YES;
        _textView.drawsBackground = NO;
        _textView.backgroundColor = NSColor.clearColor;
        _textView.textColor = [NSColor colorWithRed:0.86 green:0.82 blue:0.75 alpha:1];
        _textView.font = [NSFont systemFontOfSize:15 weight:NSFontWeightRegular];
        _textView.textContainerInset = NSMakeSize(0, 3);
        _textView.textContainer.widthTracksTextView = YES;
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.horizontallyResizable = NO;
        _textView.verticallyResizable = YES;
        _textView.minSize = NSMakeSize(0, 0);
        _textView.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        _textView.autoresizingMask = NSViewWidthSizable;
        _textView.frame = NSMakeRect(0, 0, 300, 120);
        _textView.insertionPointColor = [NSColor colorWithRed:0.42 green:0.57 blue:0.95 alpha:1];

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

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:14],

            [_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-14],
            [_scrollView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:9],
            [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-14]
        ]];
    }
    return self;
}

- (void)setBodyText:(NSString *)text {
    _textView.string = text ?: @"";
    [self refreshLayout];
}

- (NSString *)bodyText {
    return _textView.string ?: @"";
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
    TransformModePolishPreserveLanguage,
};

@interface TranslationLanguageOption : NSObject
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, copy) NSString *promptName;
+ (instancetype)optionWithDisplayName:(NSString *)displayName promptName:(NSString *)promptName;
@end

@implementation TranslationLanguageOption
+ (instancetype)optionWithDisplayName:(NSString *)displayName promptName:(NSString *)promptName {
    TranslationLanguageOption *option = [TranslationLanguageOption new];
    option.displayName = displayName;
    option.promptName = promptName;
    return option;
}
@end

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
            *error = [NSError errorWithDomain:@"GraceAI" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't save the key."}];
        }
        return NO;
    }

    NSString *directory = [self storageDirectory];
    NSError *directoryError = nil;
    if (![NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&directoryError]) {
        if (error) {
            *error = directoryError ?: [NSError errorWithDomain:@"GraceAI" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't prepare the app settings folder."}];
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
                *error = writeError ?: [NSError errorWithDomain:@"GraceAI" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't write the key to app settings."}];
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
        *error = removeError ?: [NSError errorWithDomain:@"GraceAI" code:4 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't remove the key from app settings."}];
    }
    return NO;
}

+ (NSString *)storageDirectory {
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *baseURL = urls.firstObject ?: [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *directoryURL = [baseURL URLByAppendingPathComponent:@"Grace AI" isDirectory:YES];
    return directoryURL.path;
}

+ (NSString *)storagePath {
    return [[self storageDirectory] stringByAppendingPathComponent:@"openai_api_key.txt"];
}
@end

@interface AppSettings : NSObject
+ (NSArray<TranslationLanguageOption *> *)translationLanguageOptions;
+ (TranslationLanguageOption *)defaultTranslationLanguage;
+ (void)setDefaultTranslationLanguageByDisplayName:(NSString *)displayName;
+ (NSArray<ModelOption *> *)modelOptions;
+ (ModelOption *)selectedModelOption;
+ (void)setSelectedModelByDisplayName:(NSString *)displayName;
+ (BOOL)translateToEnglish;
+ (void)setTranslateToEnglish:(BOOL)enabled;
@end

@implementation AppSettings
+ (NSString *)translationLanguageDefaultsKey {
    return @"GraceAI.DefaultTranslationLanguage";
}

+ (NSString *)modelDefaultsKey {
    return @"GraceAI.SelectedModel";
}

+ (NSString *)translateToEnglishDefaultsKey {
    return @"GraceAI.TranslateToEnglish";
}

+ (NSArray<TranslationLanguageOption *> *)translationLanguageOptions {
    static NSArray<TranslationLanguageOption *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = @[
            [TranslationLanguageOption optionWithDisplayName:@"English" promptName:@"English"],
            [TranslationLanguageOption optionWithDisplayName:@"Spanish" promptName:@"Spanish"],
            [TranslationLanguageOption optionWithDisplayName:@"French" promptName:@"French"],
            [TranslationLanguageOption optionWithDisplayName:@"German" promptName:@"German"],
            [TranslationLanguageOption optionWithDisplayName:@"Italian" promptName:@"Italian"],
            [TranslationLanguageOption optionWithDisplayName:@"Portuguese" promptName:@"Portuguese"]
        ];
    });
    return options;
}

+ (TranslationLanguageOption *)defaultTranslationLanguage {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self translationLanguageDefaultsKey]];
    for (TranslationLanguageOption *option in [self translationLanguageOptions]) {
        if ([option.displayName isEqualToString:saved]) {
            return option;
        }
    }
    return [self translationLanguageOptions].firstObject;
}

+ (void)setDefaultTranslationLanguageByDisplayName:(NSString *)displayName {
    if (displayName.length == 0) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[self translationLanguageDefaultsKey]];
        return;
    }
    [NSUserDefaults.standardUserDefaults setObject:displayName forKey:[self translationLanguageDefaultsKey]];
}

+ (NSArray<ModelOption *> *)modelOptions {
    static NSArray<ModelOption *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = @[
            [ModelOption optionWithDisplayName:@"Fastest (GPT-5.4 nano)" modelID:@"gpt-5.4-nano"],
            [ModelOption optionWithDisplayName:@"Balanced (GPT-5 mini)" modelID:@"gpt-5-mini"],
            [ModelOption optionWithDisplayName:@"Stronger (GPT-5.4 mini)" modelID:@"gpt-5.4-mini"]
        ];
    });
    return options;
}

+ (ModelOption *)selectedModelOption {
    NSString *saved = [NSUserDefaults.standardUserDefaults stringForKey:[self modelDefaultsKey]];
    for (ModelOption *option in [self modelOptions]) {
        if ([option.displayName isEqualToString:saved]) {
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

+ (BOOL)translateToEnglish {
    if ([NSUserDefaults.standardUserDefaults objectForKey:[self translateToEnglishDefaultsKey]] == nil) {
        return YES;
    }
    return [NSUserDefaults.standardUserDefaults boolForKey:[self translateToEnglishDefaultsKey]];
}

+ (void)setTranslateToEnglish:(BOOL)enabled {
    [NSUserDefaults.standardUserDefaults setBool:enabled forKey:[self translateToEnglishDefaultsKey]];
}
@end

@interface ClipboardWindowController : NSObject <NSWindowDelegate>
- (void)show;
- (void)setProcessing:(BOOL)isProcessing;
- (void)setModeText:(NSString *)modeText detail:(NSString *)detail;
- (void)setSourceText:(NSString *)sourceText resultText:(NSString *)resultText;
- (void)setConnected:(BOOL)isConnected;
- (void)setHistoryItems:(NSArray<NSDictionary *> *)items;
- (void)setCopyHandler:(void (^)(void))handler;
- (void)setProcessHandler:(void (^)(void))handler;
- (void)setPasteHandler:(void (^)(void))handler;
- (void)setSettingsHandler:(void (^)(void))handler;
- (void)setHistorySelectionHandler:(void (^)(NSInteger index))handler;
- (void)showCopiedFeedback;
- (NSString *)sourceText;
- (void)refreshCopyButton;
- (NSWindow *)window;
@end

@implementation ClipboardWindowController {
    NSWindow *_window;
    GraceLogoView *_titleLabel;
    NSTextField *_subtitleLabel;
    RoundedView *_connectionPill;
    NSView *_connectionDot;
    NSTextField *_connectionLabel;
    NSView *_bottomBar;
    NSTextField *_statusLabel;
    NSTextField *_detailLabel;
    RoundedView *_statusPill;
    NSButton *_translateCheckbox;
    NSTextField *_recentLabel;
    NSStackView *_recentStack;
    NSButton *_pasteButton;
    NSButton *_processButton;
    NSButton *_copyButton;
    NSButton *_settingsButton;
    TextCardView *_sourceCard;
    TextCardView *_resultCard;
    void (^_copyHandler)(void);
    void (^_processHandler)(void);
    void (^_pasteHandler)(void);
    void (^_settingsHandler)(void);
    void (^_historySelectionHandler)(NSInteger index);
    BOOL _isProcessing;
    BOOL _didPlaceWindow;
    NSTimer *_copyFeedbackTimer;
}

- (NSColor *)accentColor {
    return [NSColor colorWithRed:0.82 green:0.50 blue:0.18 alpha:1];
}

- (NSColor *)surfaceColor {
    return [NSColor colorWithRed:0.13 green:0.12 blue:0.09 alpha:1];
}

- (NSColor *)surface2Color {
    return [NSColor colorWithRed:0.11 green:0.10 blue:0.07 alpha:1];
}

- (NSColor *)borderColor {
    return [NSColor colorWithRed:0.20 green:0.18 blue:0.14 alpha:1];
}

- (NSColor *)textColor {
    return [NSColor colorWithRed:0.95 green:0.92 blue:0.86 alpha:1];
}

- (NSColor *)mutedColor {
    return [NSColor colorWithRed:0.62 green:0.58 blue:0.52 alpha:1];
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
    stack.alignment = NSLayoutAttributeCenterY;
    stack.spacing = title.length > 0 ? 8 : 0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    if (symbol.length > 0) {
        NSImageView *iconView = [NSImageView imageViewWithImage:[self symbolNamed:symbol size:iconSize]];
        iconView.contentTintColor = foreground;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [iconView.widthAnchor constraintEqualToConstant:iconSize].active = YES;
        [iconView.heightAnchor constraintEqualToConstant:iconSize].active = YES;
        [stack addArrangedSubview:iconView];
    }

    if (title.length > 0) {
        NSTextField *label = [NSTextField labelWithString:title];
        label.font = font;
        label.textColor = foreground;
        label.alignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [stack addArrangedSubview:label];
    }

    [button addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:button.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:button.centerYAnchor],
        [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:button.leadingAnchor constant:12],
        [stack.trailingAnchor constraintLessThanOrEqualToAnchor:button.trailingAnchor constant:-12]
    ]];
}

- (void)styleButton:(NSButton *)button background:(NSColor *)background foreground:(NSColor *)foreground border:(NSColor *)border radius:(CGFloat)radius {
    button.bordered = NO;
    button.bezelStyle = NSBezelStyleRegularSquare;
    button.imageScaling = NSImageScaleProportionallyDown;
    button.wantsLayer = YES;
    button.layer.cornerRadius = radius;
    button.layer.cornerCurve = kCACornerCurveContinuous;
    button.layer.backgroundColor = background.CGColor;
    button.layer.borderColor = border.CGColor;
    button.layer.borderWidth = 0.7;
    button.layer.shadowColor = [NSColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.16;
    button.layer.shadowRadius = 8;
    button.layer.shadowOffset = NSMakeSize(0, -1);
    button.contentTintColor = foreground;

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:button.title ?: @""];
    if (title.length > 0) {
        [title addAttributes:@{
            NSForegroundColorAttributeName: foreground,
            NSFontAttributeName: button.font ?: [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]
        } range:NSMakeRange(0, title.length)];
    }
    button.attributedTitle = title;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSRect frame = NSMakeRect(0, 0, 390, 650);
        _window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable | NSWindowStyleMaskFullSizeContentView)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
        _window.title = @"Grace AI";
        _window.minSize = NSMakeSize(390, 650);
        [_window setFrameAutosaveName:@""];
        _window.titlebarAppearsTransparent = YES;
        _window.movableByWindowBackground = YES;
        _window.backgroundColor = NSColor.clearColor;
        _window.opaque = NO;
        _window.delegate = self;

        NSView *content = _window.contentView;
        NSView *background = [NSView new];
        background.translatesAutoresizingMaskIntoConstraints = NO;
        background.wantsLayer = YES;
        background.layer.cornerRadius = 20;
        background.layer.cornerCurve = kCACornerCurveContinuous;
        background.layer.backgroundColor = [NSColor colorWithRed:0.09 green:0.08 blue:0.06 alpha:1].CGColor;
        [content addSubview:background positioned:NSWindowBelow relativeTo:nil];

        _titleLabel = [GraceLogoView new];

        _subtitleLabel = [NSTextField wrappingLabelWithString:@"Corrects text from your clipboard and can translate it to English."];
        _subtitleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
        _subtitleLabel.textColor = [NSColor colorWithRed:0.64 green:0.60 blue:0.54 alpha:1];
        _subtitleLabel.maximumNumberOfLines = 2;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _connectionPill = [[RoundedView alloc] initWithColor:[NSColor colorWithRed:0.12 green:0.13 blue:0.09 alpha:1] radius:15];
        _connectionPill.translatesAutoresizingMaskIntoConstraints = NO;

        _connectionDot = [NSView new];
        _connectionDot.wantsLayer = YES;
        _connectionDot.layer.cornerRadius = 5;
        _connectionDot.layer.cornerCurve = kCACornerCurveContinuous;
        _connectionDot.translatesAutoresizingMaskIntoConstraints = NO;

        _connectionLabel = [NSTextField wrappingLabelWithString:@"Connected"];
        _connectionLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightSemibold];
        _connectionLabel.textColor = [NSColor colorWithRed:0.74 green:0.72 blue:0.67 alpha:1];
        _connectionLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [_connectionPill addSubview:_connectionDot];
        [_connectionPill addSubview:_connectionLabel];

        _statusPill = [[RoundedView alloc] initWithColor:[NSColor colorWithRed:0.14 green:0.12 blue:0.09 alpha:0.96] radius:20];
        _statusPill.translatesAutoresizingMaskIntoConstraints = NO;

        _statusLabel = [NSTextField wrappingLabelWithString:@"Watching the clipboard"];
        _statusLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
        _statusLabel.textColor = [NSColor colorWithRed:0.95 green:0.93 blue:0.89 alpha:1];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _detailLabel = [NSTextField wrappingLabelWithString:@"Copy Russian or English text and I'll process it."];
        _detailLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
        _detailLabel.textColor = [NSColor colorWithRed:0.60 green:0.56 blue:0.50 alpha:1];
        _detailLabel.maximumNumberOfLines = 2;
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _sourceCard = [[TextCardView alloc] initWithTitle:@"ORIGINAL TEXT" tintColor:[NSColor colorWithRed:0.13 green:0.12 blue:0.09 alpha:1] editable:YES];
        _sourceCard.translatesAutoresizingMaskIntoConstraints = NO;

        _resultCard = [[TextCardView alloc] initWithTitle:@"FINAL TEXT" tintColor:[NSColor colorWithRed:0.13 green:0.12 blue:0.09 alpha:1] editable:NO];
        _resultCard.translatesAutoresizingMaskIntoConstraints = NO;

        _pasteButton = [NSButton buttonWithTitle:@"Paste" target:self action:@selector(pasteFromClipboard:)];
        _pasteButton.bezelStyle = NSBezelStyleRegularSquare;
        _pasteButton.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
        _pasteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self styleButton:_pasteButton background:[self surface2Color] foreground:[self textColor] border:[self borderColor] radius:9];
        [self decorateButton:_pasteButton
                       title:@"Paste"
                      symbol:@"clipboard"
                    iconSize:14
                        font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
                  foreground:[self textColor]];

        _translateCheckbox = [NSButton checkboxWithTitle:@"Translate to English" target:self action:@selector(changeTranslateCheckbox:)];
        _translateCheckbox.state = [AppSettings translateToEnglish] ? NSControlStateValueOn : NSControlStateValueOff;
        _translateCheckbox.font = [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold];
        _translateCheckbox.contentTintColor = [NSColor colorWithRed:0.42 green:0.57 blue:0.95 alpha:1];
        _translateCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *checkboxTitle = [[NSMutableAttributedString alloc] initWithString:@"Translate to English"];
        [checkboxTitle addAttributes:@{
            NSForegroundColorAttributeName: [self mutedColor],
            NSFontAttributeName: _translateCheckbox.font
        } range:NSMakeRange(0, checkboxTitle.length)];
        _translateCheckbox.attributedTitle = checkboxTitle;

        _recentLabel = [NSTextField wrappingLabelWithString:@"RECENT"];
        _recentLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightBold];
        _recentLabel.textColor = [NSColor colorWithRed:0.53 green:0.49 blue:0.43 alpha:1];
        _recentLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _recentStack = [NSStackView new];
        _recentStack.orientation = NSUserInterfaceLayoutOrientationVertical;
        _recentStack.spacing = 6;
        _recentStack.alignment = NSLayoutAttributeLeading;
        _recentStack.distribution = NSStackViewDistributionFill;
        _recentStack.translatesAutoresizingMaskIntoConstraints = NO;

        _processButton = [NSButton buttonWithTitle:@"Process text" target:self action:@selector(processSource:)];
        _processButton.bezelStyle = NSBezelStyleRegularSquare;
        _processButton.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold];
        _processButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self styleButton:_processButton background:[self surfaceColor] foreground:[self mutedColor] border:[self borderColor] radius:12];
        [self decorateButton:_processButton
                       title:@"Process text"
                      symbol:@"wand.and.stars"
                    iconSize:15
                        font:[NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]
                  foreground:[self mutedColor]];

        _copyButton = [NSButton buttonWithTitle:@"Copy final text" target:self action:@selector(copyResult:)];
        _copyButton.bezelStyle = NSBezelStyleRegularSquare;
        _copyButton.font = [NSFont systemFontOfSize:14 weight:NSFontWeightSemibold];
        _copyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self styleButton:_copyButton background:[self accentColor] foreground:[NSColor colorWithRed:0.10 green:0.08 blue:0.05 alpha:1] border:[NSColor colorWithRed:0.93 green:0.64 blue:0.30 alpha:0.7] radius:12];
        [self decorateButton:_copyButton
                       title:@"Copy final text"
                      symbol:@"doc.on.doc.fill"
                    iconSize:15
                        font:[NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]
                  foreground:[NSColor colorWithRed:0.10 green:0.08 blue:0.05 alpha:1]];

        _settingsButton = [NSButton buttonWithTitle:@"" target:self action:@selector(openSettings:)];
        _settingsButton.bezelStyle = NSBezelStyleRegularSquare;
        _settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingsButton.toolTip = @"Settings";
        [self styleButton:_settingsButton background:[self surfaceColor] foreground:[self mutedColor] border:[self borderColor] radius:9];
        [self decorateButton:_settingsButton
                       title:@""
                      symbol:@"gearshape.fill"
                    iconSize:15
                        font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]
                  foreground:[self mutedColor]];

        _bottomBar = [NSView new];
        _bottomBar.wantsLayer = YES;
        _bottomBar.layer.backgroundColor = [NSColor colorWithRed:0.08 green:0.07 blue:0.05 alpha:1].CGColor;
        _bottomBar.layer.borderColor = [NSColor colorWithRed:0.19 green:0.17 blue:0.14 alpha:1].CGColor;
        _bottomBar.layer.borderWidth = 0.8;
        _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;

        NSArray<NSView *> *views = @[_titleLabel, _subtitleLabel, _connectionPill, _sourceCard, _pasteButton, _translateCheckbox, _resultCard, _recentLabel, _recentStack, _bottomBar, _processButton, _copyButton, _settingsButton];
        for (NSView *view in views) {
            [content addSubview:view];
        }

        [NSLayoutConstraint activateConstraints:@[
            [background.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
            [background.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
            [background.topAnchor constraintEqualToAnchor:content.topAnchor],
            [background.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24],
            [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_settingsButton.leadingAnchor constant:-12],
            [_titleLabel.topAnchor constraintEqualToAnchor:content.topAnchor constant:35],

            [_subtitleLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_subtitleLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24],
            [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:6],

            [_settingsButton.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24],
            [_settingsButton.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor],
            [_settingsButton.widthAnchor constraintEqualToConstant:30],
            [_settingsButton.heightAnchor constraintEqualToConstant:30],

            [_connectionPill.trailingAnchor constraintEqualToAnchor:_settingsButton.leadingAnchor constant:-8],
            [_connectionPill.centerYAnchor constraintEqualToAnchor:_settingsButton.centerYAnchor],
            [_connectionPill.heightAnchor constraintEqualToConstant:28],
            [_connectionPill.widthAnchor constraintLessThanOrEqualToConstant:122],

            [_connectionDot.leadingAnchor constraintEqualToAnchor:_connectionPill.leadingAnchor constant:12],
            [_connectionDot.centerYAnchor constraintEqualToAnchor:_connectionPill.centerYAnchor],
            [_connectionDot.widthAnchor constraintEqualToConstant:10],
            [_connectionDot.heightAnchor constraintEqualToConstant:10],

            [_connectionLabel.leadingAnchor constraintEqualToAnchor:_connectionDot.trailingAnchor constant:8],
            [_connectionLabel.trailingAnchor constraintEqualToAnchor:_connectionPill.trailingAnchor constant:-14],
            [_connectionLabel.centerYAnchor constraintEqualToAnchor:_connectionPill.centerYAnchor],

            [_sourceCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
            [_sourceCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-22],
            [_sourceCard.topAnchor constraintEqualToAnchor:_subtitleLabel.bottomAnchor constant:16],
            [_sourceCard.heightAnchor constraintEqualToConstant:150],

            [_pasteButton.trailingAnchor constraintEqualToAnchor:_sourceCard.trailingAnchor constant:-14],
            [_pasteButton.topAnchor constraintEqualToAnchor:_sourceCard.topAnchor constant:14],
            [_pasteButton.widthAnchor constraintEqualToConstant:92],
            [_pasteButton.heightAnchor constraintEqualToConstant:30],

            [_translateCheckbox.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
            [_translateCheckbox.trailingAnchor constraintLessThanOrEqualToAnchor:content.trailingAnchor constant:-22],
            [_translateCheckbox.topAnchor constraintEqualToAnchor:_sourceCard.bottomAnchor constant:14],
            [_translateCheckbox.heightAnchor constraintEqualToConstant:28],

            [_resultCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
            [_resultCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-22],
            [_resultCard.topAnchor constraintEqualToAnchor:_translateCheckbox.bottomAnchor constant:14],
            [_resultCard.heightAnchor constraintEqualToConstant:136],

            [_recentLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
            [_recentLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-22],
            [_recentLabel.topAnchor constraintEqualToAnchor:_resultCard.bottomAnchor constant:14],

            [_recentStack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
            [_recentStack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-22],
            [_recentStack.topAnchor constraintEqualToAnchor:_recentLabel.bottomAnchor constant:8],
            [_recentStack.bottomAnchor constraintEqualToAnchor:_bottomBar.topAnchor constant:-14],

            [_bottomBar.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
            [_bottomBar.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
            [_bottomBar.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
            [_bottomBar.heightAnchor constraintEqualToConstant:72],

            [_processButton.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
            [_processButton.widthAnchor constraintEqualToConstant:242],
            [_processButton.heightAnchor constraintEqualToConstant:42],
            [_processButton.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-15],

            [_copyButton.centerXAnchor constraintEqualToAnchor:content.centerXAnchor],
            [_copyButton.widthAnchor constraintEqualToConstant:242],
            [_copyButton.heightAnchor constraintEqualToConstant:42],
            [_copyButton.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-15]
        ]];

        [self setSourceText:@"" resultText:@"The corrected text will appear here."];
        [self setConnected:NO];
        [self setHistoryItems:@[]];
        [self refreshCopyButton];
    }
    return self;
}

- (void)show {
    if (!_didPlaceWindow) {
        NSScreen *screen = NSScreen.mainScreen ?: NSScreen.screens.firstObject;
        if (screen) {
        NSRect visibleFrame = screen.visibleFrame;
        NSRect frame = _window.frame;
        if (frame.size.width > 450 || frame.size.height > 720) {
            frame.size = NSMakeSize(390, 650);
        }
        CGFloat margin = 24;
        frame.origin.x = NSMaxX(visibleFrame) - frame.size.width - margin;
        frame.origin.y = NSMinY(visibleFrame) + margin;
        [_window setFrame:frame display:NO];
        }
        _didPlaceWindow = YES;
    }
    [_window makeKeyAndOrderFront:nil];
}

- (void)setProcessing:(BOOL)isProcessing {
    _isProcessing = isProcessing;
    _statusPill.fillColor = isProcessing
        ? [NSColor colorWithRed:0.21 green:0.18 blue:0.08 alpha:1]
        : [NSColor colorWithRed:0.14 green:0.12 blue:0.09 alpha:0.96];
    [self refreshCopyButton];
}

- (void)setModeText:(NSString *)modeText detail:(NSString *)detail {
    _statusLabel.stringValue = modeText ?: @"";
    _detailLabel.stringValue = detail ?: @"";
}

- (void)setSourceText:(NSString *)sourceText resultText:(NSString *)resultText {
    [_sourceCard setBodyText:sourceText];
    [_resultCard setBodyText:resultText];
    [self refreshCopyButton];
}

- (void)setConnected:(BOOL)isConnected {
    _connectionPill.fillColor = isConnected
        ? [NSColor colorWithRed:0.12 green:0.15 blue:0.10 alpha:1]
        : [NSColor colorWithRed:0.14 green:0.12 blue:0.09 alpha:1];
    _connectionDot.layer.backgroundColor = (isConnected
        ? [NSColor colorWithRed:0.33 green:0.74 blue:0.43 alpha:1]
        : [NSColor colorWithRed:0.47 green:0.45 blue:0.41 alpha:1]).CGColor;
    _connectionLabel.stringValue = isConnected ? @"Connected" : @"No API key";
}

- (void)setHistoryItems:(NSArray<NSDictionary *> *)items {
    for (NSView *view in _recentStack.arrangedSubviews.copy) {
        [_recentStack removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    NSUInteger count = MIN(items.count, 2);
    if (count == 0) {
        NSTextField *emptyLabel = [NSTextField wrappingLabelWithString:@"No recent items yet."];
        emptyLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
        emptyLabel.textColor = [NSColor colorWithRed:0.47 green:0.44 blue:0.39 alpha:1];
        [_recentStack addArrangedSubview:emptyLabel];
        return;
    }

    for (NSUInteger index = 0; index < count; index++) {
        NSDictionary *item = items[index];
        NSString *badge = item[@"mode"] ?: @"Edit";
        NSString *result = item[@"result"] ?: @"";
        NSString *singleLine = [[result componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet] componentsJoinedByString:@" "];
        NSString *trimmed = singleLine.length > 42 ? [[singleLine substringToIndex:42] stringByAppendingString:@"..."] : singleLine;
        NSButton *button = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@   %@", badge, trimmed]
                                              target:self
                                              action:@selector(selectHistoryItem:)];
        button.bezelStyle = NSBezelStyleRegularSquare;
        button.bordered = NO;
        button.alignment = NSTextAlignmentLeft;
        button.font = [NSFont systemFontOfSize:11.5 weight:NSFontWeightRegular];
        button.cell.lineBreakMode = NSLineBreakByTruncatingTail;
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:button.title];
        [title addAttributes:@{
            NSForegroundColorAttributeName: [NSColor colorWithRed:0.63 green:0.59 blue:0.53 alpha:1],
            NSFontAttributeName: button.font
        } range:NSMakeRange(0, title.length)];
        NSRange badgeRange = [button.title rangeOfString:badge];
        if (badgeRange.location != NSNotFound) {
            [title addAttributes:@{
                NSForegroundColorAttributeName: [self accentColor],
                NSFontAttributeName: [NSFont systemFontOfSize:11 weight:NSFontWeightBold]
            } range:badgeRange];
        }
        button.attributedTitle = title;
        button.tag = (NSInteger)index;
        button.wantsLayer = YES;
        button.layer.cornerRadius = 8;
        button.layer.cornerCurve = kCACornerCurveContinuous;
        button.layer.backgroundColor = [NSColor clearColor].CGColor;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.heightAnchor constraintEqualToConstant:20].active = YES;
        [_recentStack addArrangedSubview:button];
    }
}

- (void)setCopyHandler:(void (^)(void))handler {
    _copyHandler = [handler copy];
}

- (void)setProcessHandler:(void (^)(void))handler {
    _processHandler = [handler copy];
}

- (void)setPasteHandler:(void (^)(void))handler {
    _pasteHandler = [handler copy];
}

- (void)setSettingsHandler:(void (^)(void))handler {
    _settingsHandler = [handler copy];
}

- (void)setHistorySelectionHandler:(void (^)(NSInteger index))handler {
    _historySelectionHandler = [handler copy];
}

- (NSString *)sourceText {
    return _sourceCard.bodyText;
}

- (NSWindow *)window {
    return _window;
}

- (void)copyResult:(id)sender {
    (void)sender;
    if (_copyHandler) {
        _copyHandler();
    }
}

- (void)showCopiedFeedback {
    [_copyFeedbackTimer invalidate];
    [self styleButton:_copyButton
           background:[NSColor colorWithRed:0.29 green:0.63 blue:0.34 alpha:1]
           foreground:[NSColor colorWithRed:0.06 green:0.10 blue:0.05 alpha:1]
               border:[NSColor colorWithRed:0.50 green:0.84 blue:0.52 alpha:0.75]
               radius:12];
    [self decorateButton:_copyButton
                   title:@"Copied"
                  symbol:@"checkmark"
                iconSize:15
                    font:[NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]
              foreground:[NSColor colorWithRed:0.06 green:0.10 blue:0.05 alpha:1]];

    __weak ClipboardWindowController *weakSelf = self;
    _copyFeedbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 repeats:NO block:^(NSTimer *timer) {
        (void)timer;
        ClipboardWindowController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf styleButton:strongSelf->_copyButton
                     background:[strongSelf accentColor]
                     foreground:[NSColor colorWithRed:0.10 green:0.08 blue:0.05 alpha:1]
                         border:[NSColor colorWithRed:0.93 green:0.64 blue:0.30 alpha:0.7]
                         radius:12];
        [strongSelf decorateButton:strongSelf->_copyButton
                             title:@"Copy final text"
                            symbol:@"doc.on.doc.fill"
                          iconSize:15
                              font:[NSFont systemFontOfSize:14 weight:NSFontWeightSemibold]
                        foreground:[NSColor colorWithRed:0.10 green:0.08 blue:0.05 alpha:1]];
        strongSelf->_copyFeedbackTimer = nil;
    }];
}

- (void)processSource:(id)sender {
    (void)sender;
    if (_processHandler) {
        _processHandler();
    }
}

- (void)pasteFromClipboard:(id)sender {
    (void)sender;
    if (_pasteHandler) {
        _pasteHandler();
    }
}

- (void)changeTranslateCheckbox:(NSButton *)sender {
    [AppSettings setTranslateToEnglish:(sender.state == NSControlStateValueOn)];
}

- (void)openSettings:(id)sender {
    (void)sender;
    if (_settingsHandler) {
        _settingsHandler();
    }
}

- (void)selectHistoryItem:(NSButton *)sender {
    if (_historySelectionHandler) {
        _historySelectionHandler(sender.tag);
    }
}

- (void)refreshCopyButton {
    BOOL hasResult = _resultCard.bodyText.length > 0;
    BOOL hasSource = [[_sourceCard.bodyText stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] > 0;
    BOOL placeholderResult = [_resultCard.bodyText isEqualToString:@"The corrected text will appear here."] || [_resultCard.bodyText isEqualToString:@"The translation or polished English version will appear here."] || [_resultCard.bodyText isEqualToString:@"Processing text..."];
    BOOL canCopy = hasResult && !placeholderResult;

    _processButton.hidden = canCopy;
    _copyButton.hidden = !canCopy;

    _processButton.enabled = !_isProcessing && hasSource;
    _processButton.alphaValue = _processButton.enabled ? 1.0 : 0.48;
    _processButton.layer.shadowOpacity = _processButton.enabled ? 0.16 : 0;
    _copyButton.enabled = canCopy;
    _copyButton.alphaValue = canCopy ? 1.0 : 0.42;
    _copyButton.layer.shadowOpacity = canCopy ? 0.18 : 0;
}

- (void)windowDidResize:(NSNotification *)notification {
    (void)notification;
    [_sourceCard layoutSubtreeIfNeeded];
    [_resultCard layoutSubtreeIfNeeded];
}
@end

@interface TransformBridge : NSObject
- (void)transformText:(NSString *)text mode:(TransformMode)mode completion:(void (^)(NSString *result, NSError *error))completion;
@end

@implementation TransformBridge
- (NSURLSession *)sharedSession {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.timeoutIntervalForRequest = 20.0;
        configuration.timeoutIntervalForResource = 25.0;
        configuration.HTTPMaximumConnectionsPerHost = 2;
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    return session;
}

- (void)transformText:(NSString *)text mode:(TransformMode)mode completion:(void (^)(NSString *result, NSError *error))completion {
    NSString *apiKey = [APIKeyStore loadAPIKey];
    if (apiKey.length == 0) {
        apiKey = [NSProcessInfo.processInfo.environment[@"OPENAI_API_KEY"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    if (apiKey.length == 0) {
        completion(nil, [NSError errorWithDomain:@"GraceAI"
                                            code:1
                                        userInfo:@{NSLocalizedDescriptionKey: @"OpenAI API key not found. Add it in the app settings."}]);
        return;
    }

    NSURL *url = [NSURL URLWithString:@"https://api.openai.com/v1/responses"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    request.timeoutInterval = 25.0;

    NSDictionary *payload = @{
        @"model": [self modelName],
        @"instructions": [self instructionsForMode:mode],
        @"max_output_tokens": @120,
        @"input": text ?: @""
    };

    NSError *jsonError = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&jsonError];
    if (!body || jsonError) {
        completion(nil, jsonError ?: [NSError errorWithDomain:@"GraceAI"
                                                         code:2
                                                     userInfo:@{NSLocalizedDescriptionKey: @"Couldn't prepare the OpenAI request."}]);
        return;
    }
    request.HTTPBody = body;

    [[self.sharedSession dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        void (^finish)(NSString *, NSError *) = ^(NSString *result, NSError *finishError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, finishError);
            });
        };

        if (error) {
            finish(nil, [NSError errorWithDomain:@"GraceAI"
                                            code:3
                                        userInfo:@{NSLocalizedDescriptionKey: @"Couldn't reach OpenAI. Check your internet connection and API key."}]);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *json = nil;
        if (data.length > 0) {
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }

        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSString *apiMessage = [self errorMessageFromResponseObject:json];
            NSString *message = apiMessage.length > 0 ? apiMessage : [NSString stringWithFormat:@"OpenAI returned error %ld.", (long)httpResponse.statusCode];
            finish(nil, [NSError errorWithDomain:@"GraceAI" code:4 userInfo:@{NSLocalizedDescriptionKey: message}]);
            return;
        }

        NSString *outputText = [self outputTextFromResponseObject:json];
        if (outputText.length == 0) {
            finish(nil, [NSError errorWithDomain:@"GraceAI"
                                            code:5
                                        userInfo:@{NSLocalizedDescriptionKey: @"OpenAI didn't return final text."}]);
            return;
        }

        finish(outputText, nil);
    }] resume];
}

- (NSString *)modelName {
    NSString *override = [NSProcessInfo.processInfo.environment[@"GRACE_AI_OPENAI_MODEL"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return override.length > 0 ? override : [AppSettings selectedModelOption].modelID;
}

- (NSString *)instructionsForMode:(TransformMode)mode {
    if (mode == TransformModeTranslateToEnglish) {
        return @"Correct spelling, punctuation, grammar, and style in the input text, then translate the final result into natural English. Preserve the original meaning. Return only the final English text with no explanation.";
    }
    return @"Correct spelling, punctuation, grammar, and style in the input text while preserving the original language and meaning. Do not translate. Return only the corrected text with no explanation.";
}

- (NSString *)outputTextFromResponseObject:(id)responseObject {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return @"";
    }

    NSDictionary *response = (NSDictionary *)responseObject;
    id directOutputText = response[@"output_text"];
    if ([directOutputText isKindOfClass:NSString.class]) {
        return [((NSString *)directOutputText) stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }

    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    NSArray *outputItems = response[@"output"];
    if ([outputItems isKindOfClass:NSArray.class]) {
        for (id item in outputItems) {
            if (![item isKindOfClass:NSDictionary.class]) {
                continue;
            }
            NSArray *contentItems = ((NSDictionary *)item)[@"content"];
            if (![contentItems isKindOfClass:NSArray.class]) {
                continue;
            }
            for (id contentItem in contentItems) {
                if (![contentItem isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                NSDictionary *content = (NSDictionary *)contentItem;
                if ([content[@"type"] isEqual:@"output_text"] && [content[@"text"] isKindOfClass:NSString.class]) {
                    NSString *text = [content[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                    if (text.length > 0) {
                        [parts addObject:text];
                    }
                }
            }
        }
    }

    return [[parts componentsJoinedByString:@"\n\n"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)errorMessageFromResponseObject:(id)responseObject {
    if (![responseObject isKindOfClass:NSDictionary.class]) {
        return @"";
    }

    NSDictionary *response = (NSDictionary *)responseObject;
    NSDictionary *error = response[@"error"];
    if ([error isKindOfClass:NSDictionary.class]) {
        NSString *message = error[@"message"];
        if ([message isKindOfClass:NSString.class]) {
            return [message stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        }
    }
    return @"";
}
@end

@interface ClipboardCoordinator : NSObject
- (instancetype)initWithWindowController:(ClipboardWindowController *)windowController;
- (void)startMonitoring;
- (void)copyResultToPasteboard;
- (void)pasteFromPasteboard;
- (void)openSettings;
@end

@implementation ClipboardCoordinator {
    ClipboardWindowController *_windowController;
    TransformBridge *_bridge;
    NSTimer *_pollTimer;
    NSTimer *_processingTimer;
    NSInteger _lastChangeCount;
    NSString *_lastSeenClipboardText;
    NSString *_lastProcessedInput;
    NSString *_lastResultText;
    NSString *_pendingClipboardText;
    NSString *_lastAppWrittenClipboardText;
    NSArray<NSDictionary *> *_historyItems;
    NSDate *_processingStartedAt;
    TransformMode _currentMode;
    BOOL _isProcessing;
}

- (instancetype)initWithWindowController:(ClipboardWindowController *)windowController {
    self = [super init];
    if (self) {
        _windowController = windowController;
        _bridge = [TransformBridge new];
        _lastSeenClipboardText = @"";
        _lastProcessedInput = @"";
        _lastResultText = @"";
        _pendingClipboardText = nil;
        _lastAppWrittenClipboardText = @"";
        _historyItems = [self loadHistoryItems];
        __weak ClipboardCoordinator *weakSelf = self;
        [_windowController setCopyHandler:^{
            [weakSelf copyResultToPasteboard];
        }];
        [_windowController setPasteHandler:^{
            [weakSelf pasteFromPasteboard];
        }];
        [_windowController setProcessHandler:^{
            ClipboardCoordinator *strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSString *manualText = [[strongSelf->_windowController sourceText] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (manualText.length > 0 && !strongSelf->_isProcessing) {
                [strongSelf processClipboardText:manualText];
            }
        }];
        [_windowController setSettingsHandler:^{
            [weakSelf openSettings];
        }];
        [_windowController setHistorySelectionHandler:^(NSInteger index) {
            ClipboardCoordinator *strongSelf = weakSelf;
            if (!strongSelf || index < 0 || index >= (NSInteger)strongSelf->_historyItems.count) {
                return;
            }
            NSDictionary *item = strongSelf->_historyItems[(NSUInteger)index];
            strongSelf->_lastResultText = item[@"result"] ?: @"";
            [strongSelf->_windowController setSourceText:item[@"source"] ?: @"" resultText:strongSelf->_lastResultText];
            [strongSelf->_windowController setModeText:@"Recent item opened"
                                                detail:@"You can edit the original text, process it again, or copy the saved result."];
        }];
    }
    return self;
}

- (void)startMonitoring {
    NSPasteboard *pasteboard = NSPasteboard.generalPasteboard;
    _lastChangeCount = pasteboard.changeCount;
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.8
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

    if ([_lastAppWrittenClipboardText isEqualToString:trimmed]) {
        _lastSeenClipboardText = trimmed;
        return;
    }

    if ([_lastSeenClipboardText isEqualToString:trimmed] || [_lastProcessedInput isEqualToString:trimmed]) {
        return;
    }

    _lastSeenClipboardText = trimmed;
    if (_isProcessing) {
        _pendingClipboardText = trimmed;
        return;
    }

    [self processClipboardText:trimmed];
}

- (void)processClipboardText:(NSString *)text {
    TransformMode mode = [self modeForText:text];
    if (mode == TransformModeUnsupported) {
        [_windowController setProcessing:NO];
        [_windowController setModeText:@"Text skipped"
                                detail:@"Copy or type text first, then process it."];
        return;
    }

    _isProcessing = YES;
    _currentMode = mode;
    _processingStartedAt = [NSDate date];
    _lastProcessedInput = text;
    [_windowController setProcessing:YES];
    [_windowController setSourceText:text resultText:@"Processing text..."];
    [self startProcessingTimer];
    [_windowController show];

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

        if (error || result.length == 0) {
            NSString *message = error.localizedDescription ?: @"Couldn't process the text.";
            [strongSelf->_windowController setSourceText:text resultText:message];
            [strongSelf->_windowController setModeText:@"Processing failed"
                                                detail:[NSString stringWithFormat:@"Error after %.1f s. Check OPENAI_API_KEY and your internet connection.", elapsed]];
        } else {
            strongSelf->_lastResultText = result;
            [strongSelf->_windowController setSourceText:text resultText:result];
            [strongSelf->_windowController setModeText:@"Done"
                                                detail:[NSString stringWithFormat:@"Processing took %.1f s. You can copy the final text right away.", elapsed]];
            [strongSelf addHistoryItemWithSource:text result:result mode:mode];
        }

        if (strongSelf->_pendingClipboardText.length > 0 && ![strongSelf->_pendingClipboardText isEqualToString:text]) {
            NSString *pending = strongSelf->_pendingClipboardText;
            strongSelf->_pendingClipboardText = nil;
            [strongSelf processClipboardText:pending];
        } else {
            strongSelf->_pendingClipboardText = nil;
        }
    }];
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
    if (_currentMode == TransformModeTranslateToEnglish) {
        [_windowController setModeText:@"Correcting and translating to English"
                                detail:[NSString stringWithFormat:@"Processing: %.1f s", elapsed]];
    } else {
        [_windowController setModeText:@"Correcting text"
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

- (void)pasteFromPasteboard {
    NSString *text = [NSPasteboard.generalPasteboard stringForType:NSPasteboardTypeString];
    NSString *trimmed = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        [_windowController setModeText:@"Clipboard is empty"
                                detail:@"Copy text first, then press Paste."];
        return;
    }
    if (_isProcessing) {
        _pendingClipboardText = trimmed;
        [_windowController setSourceText:trimmed resultText:@"Queued. I'll process this as soon as the current text is done."];
        return;
    }
    _lastSeenClipboardText = trimmed;
    [self processClipboardText:trimmed];
}

- (NSArray<NSDictionary *> *)loadHistoryItems {
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"GraceAI.HistoryItems"];
    if (![items isKindOfClass:NSArray.class]) {
        return @[];
    }
    return items;
}

- (void)saveHistoryItems {
    [NSUserDefaults.standardUserDefaults setObject:_historyItems ?: @[] forKey:@"GraceAI.HistoryItems"];
}

- (void)addHistoryItemWithSource:(NSString *)source result:(NSString *)result mode:(TransformMode)mode {
    if (source.length == 0 || result.length == 0) {
        return;
    }

    NSString *modeLabel = mode == TransformModeTranslateToEnglish ? @"EN" : @"EDIT";

    NSDictionary *item = @{
        @"source": source,
        @"result": result,
        @"mode": modeLabel,
        @"translateToEnglish": @([AppSettings translateToEnglish]),
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
    alert.informativeText = @"Add your OpenAI API key and pick the model you want to use.";
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Clear"];

    NSView *accessory = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 360, 142)];
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

    [accessory addSubview:label];
    [accessory addSubview:field];
    [accessory addSubview:modelLabel];
    [accessory addSubview:modelPopup];
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
        [modelPopup.heightAnchor constraintEqualToConstant:28]
    ]];
    alert.accessoryView = accessory;

    NSWindow *window = [_windowController window];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSError *error = nil;
            NSString *value = [field.stringValue stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            [AppSettings setSelectedModelByDisplayName:modelPopup.selectedItem.title ?: [AppSettings modelOptions].firstObject.displayName];
            if (value.length == 0) {
                [self->_windowController setModeText:@"Settings updated"
                                              detail:@"Model was saved. Add your OpenAI API key when you're ready."];
                return;
            }
            if ([APIKeyStore saveAPIKey:value error:&error]) {
                [self->_windowController setModeText:@"Settings saved"
                                              detail:[NSString stringWithFormat:@"API key saved. Grace AI will process text using %@.", [AppSettings selectedModelOption].displayName]];
            } else {
                [self->_windowController setModeText:@"Couldn't save key"
                                              detail:error.localizedDescription ?: @"Please try again."];
            }
            [self refreshIdleStatus];
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
        }
    }];
}

- (void)refreshIdleStatus {
    if (_isProcessing) {
        return;
    }
    BOOL hasAPIKey = [APIKeyStore loadAPIKey].length > 0 || [NSProcessInfo.processInfo.environment[@"OPENAI_API_KEY"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length > 0;
    [_windowController setConnected:hasAPIKey];
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
    return [AppSettings translateToEnglish] ? TransformModeTranslateToEnglish : TransformModePolishPreserveLanguage;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate {
    ClipboardWindowController *_windowController;
    ClipboardCoordinator *_coordinator;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    _windowController = [ClipboardWindowController new];
    _coordinator = [[ClipboardCoordinator alloc] initWithWindowController:_windowController];
    [NSApp activateIgnoringOtherApps:YES];
    [_windowController show];
    [_coordinator startMonitoring];
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

#import "DFRPrivateWrapper.h"
#import "DFRPrivateHeader.h"

static BOOL DFRClassRespondsToSelector(Class cls, SEL selector) {
    if (![cls respondsToSelector:selector]) {
        NSLog(@"[TouchBarHelper] private selector unavailable: %@ on %@", NSStringFromSelector(selector), NSStringFromClass(cls));
        return NO;
    }
    return YES;
}

@implementation NSTouchBarItem (DFRAccess)

- (void)addToSystemTray {
    SEL selector = @selector(addSystemTrayItem:);
    if (DFRClassRespondsToSelector([NSTouchBarItem class], selector)) {
        [NSTouchBarItem addSystemTrayItem:self];
    }
}

- (void)removeFromSystemTray {
    SEL selector = @selector(removeSystemTrayItem:);
    if (DFRClassRespondsToSelector([NSTouchBarItem class], selector)) {
        [NSTouchBarItem removeSystemTrayItem:self];
    }
}

+ (void)setControlStripPresence:(BOOL)present for:(NSTouchBarItemIdentifier)identifier {
    DFRElementSetControlStripPresenceForIdentifier_(identifier, present);
}

- (void)setControlStripPresence:(BOOL)present {
    DFRElementSetControlStripPresenceForIdentifier_(self.identifier, present);
}

@end

@implementation NSTouchBar (DFRAccess)

- (void)presentAsSystemModalForItem:(NSTouchBarItem *)item {
    [self presentAsSystemModalForItemIdentifier:item.identifier];
}

- (void)presentAsSystemModalForItemIdentifier:(NSTouchBarItemIdentifier)identifier {
    if (@available(macOS 10.14, *)) {
        SEL selector = @selector(presentSystemModalTouchBar:systemTrayItemIdentifier:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar presentSystemModalTouchBar:self
                          systemTrayItemIdentifier:identifier];
        }
    } else {
        SEL selector = @selector(presentSystemModalFunctionBar:systemTrayItemIdentifier:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar presentSystemModalFunctionBar:self
                             systemTrayItemIdentifier:identifier];
        }
    }
}

- (void)presentAsSystemModalForItemIdentifier:(NSTouchBarItemIdentifier)identifier placement:(BOOL)placement {
    long long hideControlStrip = placement ? 1 : 0;
    if (@available(macOS 10.14, *)) {
        SEL selector = @selector(presentSystemModalTouchBar:placement:systemTrayItemIdentifier:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar presentSystemModalTouchBar:self
                                         placement:hideControlStrip
                          systemTrayItemIdentifier:identifier];
        }
    } else {
        SEL selector = @selector(presentSystemModalFunctionBar:placement:systemTrayItemIdentifier:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar presentSystemModalFunctionBar:self
                                            placement:hideControlStrip
                             systemTrayItemIdentifier:identifier];
        }
    }
}

- (void)dismissSystemModal {
    if (@available(macOS 10.14, *)) {
        SEL selector = @selector(dismissSystemModalTouchBar:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar dismissSystemModalTouchBar:self];
        }
    } else {
        SEL selector = @selector(dismissSystemModalFunctionBar:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar dismissSystemModalFunctionBar:self];
        }
    }
}

- (void)minimizeSystemModal {
    if (@available(macOS 10.14, *)) {
        SEL selector = @selector(minimizeSystemModalTouchBar:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar minimizeSystemModalTouchBar:self];
        }
    } else {
        SEL selector = @selector(minimizeSystemModalFunctionBar:);
        if (DFRClassRespondsToSelector([NSTouchBar class], selector)) {
            [NSTouchBar minimizeSystemModalFunctionBar:self];
        }
    }
}

+ (void)setSystemModalShowsCloseBoxWhenFrontMost:(BOOL)show {
    DFRSystemModalShowsCloseBoxWhenFrontMost_(show);
}

@end

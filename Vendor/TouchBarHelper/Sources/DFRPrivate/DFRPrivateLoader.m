#import "DFRPrivateHeader.h"
#import <dlfcn.h>

#define kDFRFoundationPath "/System/Library/PrivateFrameworks/DFRFoundation.framework/DFRFoundation"
#define kDFRElementSetControlStripPresenceForIdentifierSymbol "DFRElementSetControlStripPresenceForIdentifier"
#define kDFRSystemModalShowsCloseBoxWhenFrontMostSymbol "DFRSystemModalShowsCloseBoxWhenFrontMost"

static void (*pDFRElementSetControlStripPresenceForIdentifier)(NSTouchBarItemIdentifier, BOOL);
static void (*pDFRSystemModalShowsCloseBoxWhenFrontMost)(BOOL);

void DFRElementSetControlStripPresenceForIdentifier_(NSTouchBarItemIdentifier identifier, BOOL present) {
    if (pDFRElementSetControlStripPresenceForIdentifier) {
        pDFRElementSetControlStripPresenceForIdentifier(identifier, present);
    } else {
        NSLog(@"[TouchBarHelper] DFR symbol unavailable: DFRElementSetControlStripPresenceForIdentifier");
    }
}

void DFRSystemModalShowsCloseBoxWhenFrontMost_(BOOL show) {
    if (pDFRSystemModalShowsCloseBoxWhenFrontMost) {
        pDFRSystemModalShowsCloseBoxWhenFrontMost(show);
    } else {
        NSLog(@"[TouchBarHelper] DFR symbol unavailable: DFRSystemModalShowsCloseBoxWhenFrontMost");
    }
}

__attribute__((constructor)) static void loadDFRFoundation() {
    void *handle = dlopen(kDFRFoundationPath, RTLD_LAZY);
    if (handle == NULL) {
        NSLog(@"[TouchBarHelper] DFRFoundation unavailable: %s", dlerror());
        return;
    }
    pDFRElementSetControlStripPresenceForIdentifier = dlsym(handle, kDFRElementSetControlStripPresenceForIdentifierSymbol);
    pDFRSystemModalShowsCloseBoxWhenFrontMost = dlsym(handle, kDFRSystemModalShowsCloseBoxWhenFrontMostSymbol);
    if (pDFRElementSetControlStripPresenceForIdentifier == NULL) {
        NSLog(@"[TouchBarHelper] dlsym failed: %s", kDFRElementSetControlStripPresenceForIdentifierSymbol);
    }
    if (pDFRSystemModalShowsCloseBoxWhenFrontMost == NULL) {
        NSLog(@"[TouchBarHelper] dlsym failed: %s", kDFRSystemModalShowsCloseBoxWhenFrontMostSymbol);
    }
    dlclose(handle);
}

// Ripped from https://github.com/andres-guzman/grayscale-graphite/blob/e42c8c706b0182985827e198bfbd994dc016566a/config/.config/quickshell/ii/modules/common/Appearance.qml

import QtQuick
import Quickshell
import qs.modules.common.functions
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes
    property string syntaxHighlightingTheme

    // Transparency. The quadratic functions were derived from analysis of hand-picked transparency values.
    ColorQuantizer {
        id: wallColorQuant
        property string wallpaperPath: Config.options.background.wallpaperPath
        property bool wallpaperIsVideo: wallpaperPath.endsWith(".mp4") || wallpaperPath.endsWith(".webm") || wallpaperPath.endsWith(".mkv") || wallpaperPath.endsWith(".avi") || wallpaperPath.endsWith(".mov")
        source: Qt.resolvedUrl(wallpaperIsVideo ? Config.options.background.thumbnailPath : Config.options.background.wallpaperPath)
        depth: 0 // 2^0 = 1 color
        rescaleSize: 10
    }
    property real wallpaperVibrancy: (wallColorQuant.colors[0]?.hslSaturation + wallColorQuant.colors[0]?.hslLightness) / 2
    property real autoBackgroundTransparency: { // y = 0.5768x^2 - 0.759x + 0.2896
        let x = wallpaperVibrancy
        let y = 0.5768 * (x * x) - 0.759 * (x) + 0.2896
        return Math.max(0, Math.min(0.20, y)) - 0.12 * (m3colors.darkmode ? 0 : 1)
    }
    property real autoContentTransparency: 0.2
    property real backgroundTransparency: Config?.options.appearance.transparency.enable ? Config?.options.appearance.transparency.automatic ? autoBackgroundTransparency : Config?.options.appearance.transparency.backgroundTransparency : 0
    property real contentTransparency: Config?.options.appearance.transparency.automatic ? autoContentTransparency : Config?.options.appearance.transparency.contentTransparency

        m3colors: QtObject {
        property bool darkmode: true
        property bool transparent: false

        // ====================================================
        // Base surfaces and backgrounds
        // ====================================================

        property color m3background: "#141415"
        property color m3backgroundBar: "#141415"
        property color m3onBackground: "#d1d0d2"

        property color m3surface: "#19191a"
        property color m3surfaceDim: "#141415"
        property color m3surfaceBright: "#2d2d2f"

        property color m3surfaceContainerLowest: "#141415"
        property color m3surfaceContainerLow: "#19191a"
        property color m3surfaceContainer: "#19191a"
        property color m3surfaceContainerHigh: "#2d2d2f"
        property color m3surfaceContainerHighest: "#383739"

        property color m3onSurface: "#e0e0e1"

        // ====================================================
        // Surface variants, dividers, borders and shadows
        // ====================================================

        property color m3surfaceVariant: "#2d2d2f"
        property color m3onSurfaceVariant: "#7a787d"

        property color m3outline: "#4d4b4e"
        property color m3outlineVariant: "#2d2d2f"

        property color m3shadow: "#000000"
        property color m3scrim: "#000000"

        // ====================================================
        // Primary
        //
        // The theme has no chromatic accent. Primary emphasis is
        // represented by a brighter neutral tone.
        // ====================================================

        property color m3surfaceTint: "#99979b"

        property color m3primary: "#99979b"
        property color m3onPrimary: "#141415"

        property color m3primaryContainer: "#383739"
        property color m3onPrimaryContainer: "#e0e0e1"

        property color m3inversePrimary: "#7a787d"
        property color m3inverseSurface: "#e0e0e1"
        property color m3inverseOnSurface: "#141415"

        // ====================================================
        // Secondary
        // ====================================================

        property color m3secondary: "#8a878c"
        property color m3onSecondary: "#141415"

        property color m3secondaryContainer: "#2d2d2f"
        property color m3onSecondaryContainer: "#d1d0d2"

        // ====================================================
        // Tertiary
        // ====================================================

        property color m3tertiary: "#99979b"
        property color m3onTertiary: "#141415"

        property color m3tertiaryContainer: "#383739"
        property color m3onTertiaryContainer: "#e0e0e1"

        // ====================================================
        // Error and success
        //
        // These remain monochrome. They differ through brightness,
        // not hue.
        // ====================================================

        property color m3error: "#aba9ad"
        property color m3onError: "#141415"

        property color m3errorContainer: "#383739"
        property color m3onErrorContainer: "#e0e0e1"

        property color m3success: "#8a878c"
        property color m3onSuccess: "#141415"

        property color m3successContainer: "#2d2d2f"
        property color m3onSuccessContainer: "#d1d0d2"

        // ====================================================
        // Fixed tones
        // ====================================================

        property color m3primaryFixed: "#e0e0e1"
        property color m3primaryFixedDim: "#99979b"
        property color m3onPrimaryFixed: "#141415"
        property color m3onPrimaryFixedVariant: "#4d4b4e"

        property color m3secondaryFixed: "#d1d0d2"
        property color m3secondaryFixedDim: "#8a878c"
        property color m3onSecondaryFixed: "#141415"
        property color m3onSecondaryFixedVariant: "#4d4b4e"

        property color m3tertiaryFixed: "#d1d0d2"
        property color m3tertiaryFixedDim: "#99979b"
        property color m3onTertiaryFixed: "#141415"
        property color m3onTertiaryFixedVariant: "#4d4b4e"

        // ====================================================
        // Terminal palette — exact Kitty grayscale mapping
        // ====================================================

        property color term0:  "#141415"
        property color term1:  "#383739"
        property color term2:  "#474649"
        property color term3:  "#4d4b4e"
        property color term4:  "#474649"
        property color term5:  "#4d4b4e"
        property color term6:  "#565558"
        property color term7:  "#d1d0d2"

        property color term8:  "#4d4b4e"
        property color term9:  "#7a787d"
        property color term10: "#8a878c"
        property color term11: "#99979b"
        property color term12: "#8a878c"
        property color term13: "#99979b"
        property color term14: "#aba9ad"
        property color term15: "#e0e0e1"
        property color error_dark: "#792a52"
        property color error_light: "#c7487a"
    }

    colors: QtObject {
        property color colSubtext: m3colors.m3onSurfaceVariant
        // Layer 0
        property color colLayer0: m3colors.m3background
        property color colLayer0BarBackground: ColorUtils.transparentize(m3colors.m3backgroundBar, 0.10)
        property color colLayer0Base: ColorUtils.mix(m3colors.m3background, Config.options.appearance.extraBackgroundTint ? 1 : 1)
        property color colOnLayer0: m3colors.m3onSurface
        property color colOnLayer0transparent: m3colors.term1
        property color colLayer0Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.9, root.contentTransparency))
        property color colLayer0Active: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.8, root.contentTransparency))
        property color colLayer0Border: m3colors.term9
        // Layer 1
        property color colLayer1Base: m3colors.m3surfaceContainerLow
        property color colLayer1: ColorUtils.solveOverlayColor(colLayer0Base, colLayer1Base, 1 - root.contentTransparency);
        property color colOnLayer1: m3colors.m3onSurfaceVariant;
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45);
        property color colLayer1Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.92), root.contentTransparency)
        property color colLayer1Active: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.85), root.contentTransparency);
        // Layer 2
        property color colLayer2Base: m3colors.m3surfaceContainer
        property color colLayer2: ColorUtils.solveOverlayColor(colLayer1Base, colLayer2Base, 1 - root.contentTransparency)
        property color colLayer2Hover: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.90), 1 - root.contentTransparency)
        property color colLayer2Active: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.80), 1 - root.contentTransparency);
        property color colLayer2Disabled: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, m3colors.m3background, 0.8), 1 - root.contentTransparency);
        property color colOnLayer2: m3colors.m3onSurface;
        property color colOnLayer2Disabled: ColorUtils.mix(colOnLayer2, m3colors.m3background, 0.4);
        // Layer 3
        property color colLayer3Base: m3colors.m3surfaceContainerHigh
        property color colLayer3: ColorUtils.solveOverlayColor(colLayer2Base, colLayer3Base, 1 - root.contentTransparency)
        property color colLayer3Hover: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.90), 1 - root.contentTransparency)
        property color colLayer3Active: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.80), 1 - root.contentTransparency);
        property color colOnLayer3: m3colors.m3onSurface;
        // Layer 4
        property color colLayer4Base: m3colors.m3surfaceContainerHighest
        property color colLayer4: ColorUtils.solveOverlayColor(colLayer3Base, colLayer4Base, 1 - root.contentTransparency)
        property color colLayer4Hover: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.90), 1 - root.contentTransparency)
        property color colLayer4Active: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.80), 1 - root.contentTransparency);
        property color colOnLayer4: m3colors.m3onSurface;
        // Primary
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colPrimaryHover: ColorUtils.mix(colors.colPrimary, colLayer1Hover, 0.87)
        property color colPrimaryActive: ColorUtils.mix(colors.colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: m3colors.m3primaryContainer
        property color colPrimaryContainerHover: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.9)
        property color colPrimaryContainerActive: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.8)
        property color colOnPrimaryContainer: m3colors.m3onPrimaryContainer
        // Secondary
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryHover: ColorUtils.mix(m3colors.m3secondary, colLayer1Hover, 0.85)
        property color colSecondaryActive: ColorUtils.mix(m3colors.m3secondary, colLayer1Active, 0.4)
        property color colOnSecondary: m3colors.m3onSecondary
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colSecondaryContainerHover: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.90)
        property color colSecondaryContainerActive: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.54)
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        // Tertiary
        property color colTertiary: m3colors.m3tertiary
        property color colTertiaryHover: ColorUtils.mix(m3colors.m3tertiary, colLayer1Hover, 0.85)
        property color colTertiaryActive: ColorUtils.mix(m3colors.m3tertiary, colLayer1Active, 0.4)
        property color colTertiaryContainer: m3colors.m3tertiaryContainer
        property color colTertiaryContainerHover: ColorUtils.mix(m3colors.m3tertiaryContainer, m3colors.m3onTertiaryContainer, 0.90)
        property color colTertiaryContainerActive: ColorUtils.mix(m3colors.m3tertiaryContainer, colLayer1Active, 0.54)
        property color colOnTertiary: m3colors.m3onTertiary
        property color colOnTertiaryContainer: m3colors.m3onTertiaryContainer
        // Surface
        property color colBackgroundSurfaceContainer: ColorUtils.transparentize(m3colors.m3surfaceContainer, root.backgroundTransparency)
        property color colSurfaceContainerLow: ColorUtils.solveOverlayColor(m3colors.m3background, m3colors.m3surfaceContainerLow, 1 - root.contentTransparency)
        property color colSurfaceContainer: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerLow, m3colors.m3surfaceContainer, 1 - root.contentTransparency)
        property color colSurfaceContainerHigh: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainer, m3colors.m3surfaceContainerHigh, 1 - root.contentTransparency)
        property color colSurfaceContainerHighest: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerHigh, m3colors.m3surfaceContainerHighest, 1 - root.contentTransparency)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.85)
        property color colOnSurface: m3colors.m3onSurface
        property color colOnSurfaceVariant: m3colors.m3onSurfaceVariant
        // Misc
        property color colTooltip: m3colors.m3inverseSurface
        property color colOnTooltip: m3colors.m3inverseOnSurface
        property color colScrim: ColorUtils.transparentize(m3colors.m3scrim, 0.5)
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutline: m3colors.m3outline
        property color colOutlineVariant: m3colors.m3outlineVariant
        property color colError: m3colors.m3error
        property color colErrorHover: ColorUtils.mix(m3colors.m3error, colLayer1Hover, 0.85)
        property color colErrorActive: ColorUtils.mix(m3colors.m3error, colLayer1Active, 0.7)
        property color colOnError: m3colors.error_dark
        property color colErrorContainer: m3colors.m3errorContainer
        property color colErrorContainerHover: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.90)
        property color colErrorContainerActive: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.70)
        property color colOnErrorContainer: m3colors.m3onErrorContainer
        // Error colors
        property color colLayerError: m3colors.error_light
    }

    // Bar rounding values
    rounding: QtObject {
        property int unsharpen: 2
        property int unsharpenmore: 6
        property int verysmall: 7
        property int small: 8
        property int normal: 7
        property int large: 11
        property int verylarge: 12
        property int full: 9999
        property int windowRounding: large
        property int screenRounding: verylarge
    }

    font: QtObject {
        // Global font families
        property QtObject family: QtObject {
            property string main: Config.options.appearance.fonts.main
            property string numbers: Config.options.appearance.fonts.numbers
            property string title: Config.options.appearance.fonts.title
            property string iconMaterial: "Material Symbols Rounded"
            property string iconNerd: Config.options.appearance.fonts.iconNerd
            property string monospace: Config.options.appearance.fonts.monospace
            property string reading: Config.options.appearance.fonts.reading
            property string expressive: Config.options.appearance.fonts.expressive
        }

        property QtObject variableAxes: QtObject {
            property var main: ({
                "wght": 700,
                // "wdth": 100,
            })
            property var numbers: ({
                "wght": 700,
            })
            property var title: ({ // Slightly bold weight for title
                "wght": 800, // Weight (Lowered to compensate for increased grade)
            })
        }
        // Global font sizes
        property QtObject pixelSize: QtObject {
            property int smallest: 8
            property int smaller: 9
            property int smallie: 10
            property int small: 11
            property int normal: 12
            property int large: 13
            property int larger: 14
            property int huge: 15
            property int hugeass: 16
            property int title: normal
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 560
        readonly property real expressiveDefaultSpatialDuration: 700
        readonly property real expressiveSlowSpatialDuration: 850
        readonly property real expressiveEffectsDuration: 500
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standard
            property int velocity: 500
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveEnter: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
            property int velocity: 500
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        property QtObject elementMoveExit: QtObject {
            property int duration: 600
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 600
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                alwaysRunToEnd: true
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }

        property QtObject elementResize: QtObject {
            property int duration: 500
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasized
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementResize.duration
                    easing.type: root.animation.elementResize.type
                    easing.bezierCurve: root.animation.elementResize.bezierCurve
                }
            }
        }

        property QtObject clickBounce: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                alwaysRunToEnd: true
                duration: root.animation.clickBounce.duration
                easing.type: root.animation.clickBounce.type
                easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }

        property QtObject scroll: QtObject {
            property int duration: 300
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }

        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }

    sizes: QtObject {
        property real baseBarHeight: 38
        property real barHeight: Config.options.bar.cornerStyle === 1 ?
            (baseBarHeight + root.sizes.hyprlandGapsOut * 2) : baseBarHeight
        property real barCenterSideModuleWidth: Config.options?.bar.verbose ? 360 : 140
        property real barCenterSideModuleWidthShortened: 280
        property real barCenterSideModuleWidthHellaShortened: 190
        property real barShortenScreenWidthThreshold: 1200 // Shorten if screen width is at most this value
        property real barHellaShortenScreenWidthThreshold: 1000 // Shorten even more...
        property real elevationMargin: 10
        property real fabShadowRadius: 5
        property real fabHoveredShadowRadius: 6
        property real hyprlandGapsOut: 12
        property real mediaControlsWidth: 440
        property real mediaControlsHeight: 160
        property real notificationPopupWidth: 480
        property real osdWidth: 380
        property real searchWidthCollapsed: 525
        property real searchWidth: 525
        property real sidebarWidth: 460
        property real sidebarWidthExtended: 790
        property real baseVerticalBarWidth: 46
        property real verticalBarWidth: Config.options.bar.cornerStyle === 1 ? (baseVerticalBarWidth + root.sizes.hyprlandGapsOut * 2) : baseVerticalBarWidth
        property real wallpaperSelectorWidth: 1920
        property real wallpaperSelectorHeight: 1200
        property real wallpaperSelectorItemMargins: 8
        property real wallpaperSelectorItemPadding: 6
    }

    syntaxHighlightingTheme: root.m3colors.darkmode ? "Google Sans Flex" : "ayu Light"
}

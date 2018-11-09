//
//  InnoRangeSelectionSlider.swift
//  swift-custom-ui
//
//  Created by Tejasree Marthy on 01/11/17.
//  Copyright © 2017 Innominds Mobility. All rights reserved.
//

import UIKit
import QuartzCore

// MARK: Class: Drawing for Range selection slider Track layer

/// This class draws rectangle for track layer on a bezier path and fills color to it.
/// curvaceousness defines the cornerradius for track layer.
/// And changes the selected tarck/range with a different color i.e trackHighlightTintColor.
class RangeSelectionSliderTrackLayer: CALayer {
    /// The InnoRangeSelectionSlider for Range slider.
    weak var rangeSlider: InnoRangeSelectionSlider?
    /// Performing custom drawing for Range selection slider.
    ///
    /// - Parameter contex: The portion of the Layer context that needs to be updated.
    override func draw(in contex: CGContext) {
        /// Checking for Range slider.
        guard let slider = rangeSlider else {
            return
        }
            /// Track layer corner radius.
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            /// Track layer path.
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            contex.addPath(path.cgPath)

            // Fill the track.
            contex.setFillColor(slider.trackTintColor.cgColor)
            contex.addPath(path.cgPath)
            contex.fillPath()

            // Fill the highlighted range.
            contex.setFillColor(slider.trackHighlightTintColor.cgColor)
            /// Lower value position for range selector.
            let lowerValPosition = CGFloat(slider.positionForValue(value: slider.lowerValue))
            /// Upper value position for range selector.
            let upperValPosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            /// Range/Track layer position bounds.
            let rect = CGRect(x: lowerValPosition, y: 0.0,
                              width: upperValPosition - lowerValPosition,
                              height: bounds.height)
            contex.fill(rect)

    }

}

// MARK: Class: Drawing for Range Indicator layer
///  This class draws rectangle
/// [In the form of circle or square] for track indicator layer on a bezier path and fills color to it.
/// curvaceousness defines the cornerradius for indicator layer.
/// And changes indicator color when it is highlighted.
class RangeSliderIndicatorLayer: CALayer {
    /// Indicator highlight boolean.
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    /// The InnoRangeSelectionSlider for Range slider.
    weak var rangeSlider: InnoRangeSelectionSlider?
    /// Stroke color for outline indicator.
    var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    /// Line width for Indicator.
    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Performing custom drawing for Indicator.
    ///
    /// - Parameter ctx: The portion of the Layer context that needs to be updated.
    override func draw(in ctx: CGContext) {
        /// Check for Range slider
        guard let slider = rangeSlider else {
         return
        }
            /// Frame for Indicator.
            let indicatorFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            /// Corner radius value for indicator.
            let cornerRadius = indicatorFrame.height * slider.curvaceousness / 2.0
            /// Path for Indicator.
            let indicatorPath = UIBezierPath(roundedRect: indicatorFrame, cornerRadius: cornerRadius)

            // Fill indicator.
            ctx.setFillColor(slider.indicatorTintColor.cgColor)
            ctx.addPath(indicatorPath.cgPath)
            ctx.fillPath()

            // Outline indicator.
            ctx.setStrokeColor(strokeColor.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.addPath(indicatorPath.cgPath)
            ctx.strokePath()

            if highlighted {
                ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                ctx.addPath(indicatorPath.cgPath)
                ctx.fillPath()
            }
    }
}

// MARK: Class: Range Selection Slider.

/// This class combines track layer and indicators layer to form a selection slider for selecting a range.
/// Defines different properties to change the UI dynamically.
@IBDesignable public class InnoRangeSelectionSlider: UIControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /// IBInspectable for Minimum value of InnoRangeSelectionSlider.
    @IBInspectable public var minValue: Double = 0.0 {
        didSet {
            updateRangeSliderLayerFrames()
        }
    }
    /// IBInspectable for Maximum value of InnoRangeSelectionSlider.
    @IBInspectable public var maxValue: Double = 1.0 {
        didSet {
            updateRangeSliderLayerFrames()
        }
    }

    /// IBInspectable for Lower value of InnoRangeSelectionSlider.
    @IBInspectable public var lowerValue: Double = 0.3 {
        didSet {
            if lowerValue < minValue {
                lowerValue = minValue
            }
            updateRangeSliderLayerFrames()
        }
    }

    /// IBInspectable for Upper value of InnoRangeSelectionSlider.
    @IBInspectable public var upperValue: Double = 0.9 {
        didSet {
            if upperValue > maxValue {
                upperValue = maxValue
            }
            updateRangeSliderLayerFrames()
        }
    }
    /// Calculates gap between the indicators.
    var gapBetweenIndicators: Double {
        return 0.5 * Double(indicatorWidth) * (maxValue - minValue) / Double(bounds.width)
    }

    /// IBInspectable for Track tint color of InnoRangeSelectionSlider.
    @IBInspectable public var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    /// IBInspectable for Track highlight color of InnoRangeSelectionSlider.
    @IBInspectable public var
    trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    /// IBInspectable for Indicator tint color of InnoRangeSelectionSlider.
    @IBInspectable public var indicatorTintColor: UIColor = UIColor.white {
        didSet {
            lowerIndicatorLayer.setNeedsDisplay()
            upperIndicatorLayer.setNeedsDisplay()
        }
    }
    /// IBInspectable for curvaceousness of InnoRangeSelectionSlider.
    /// To change curve/cornerradius for indicator.
    @IBInspectable public var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 { //Forms square shape, with corner radius
                curvaceousness = 0.0
            }

            if curvaceousness > 1.0 {// Circle
                curvaceousness = 1.0
            }
            trackLayer.setNeedsDisplay() // Changing the track with corner radius
            lowerIndicatorLayer.setNeedsDisplay() // Changing the indicator with corner radius
            upperIndicatorLayer.setNeedsDisplay() // Changing the indicator with corner radius
        }
    }

    /// Previous location point of indicator.
    fileprivate var previusLocPoint = CGPoint()
    /// RangeSelectionSliderTrackLayer for track.
    fileprivate let trackLayer = RangeSelectionSliderTrackLayer()
    /// RangeSliderIndicatorLayer for Lower indicator.
    fileprivate let lowerIndicatorLayer = RangeSliderIndicatorLayer()
    /// RangeSliderIndicatorLayer for Upper indicator.
    fileprivate let upperIndicatorLayer = RangeSliderIndicatorLayer()

   /// Get Indicator width.
   fileprivate var indicatorWidth: CGFloat {
        return CGFloat(bounds.height)
    }

    /// Updates Range Slider frame.
    override public var frame: CGRect {
        didSet {
            updateRangeSliderLayerFrames()
        }
    }
    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the view that needs to be initialised.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()

        }

    /// Initializes and returns a newly allocated view object with the specified frame rectangle
    ///
    /// - Parameter coder: coder
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
        initializeLayers()
    }

    /// Initializing Track layer, Lower Indicator layer, Upper Indicator layer.
    fileprivate func initializeLayers() {
        lowerIndicatorLayer.rangeSlider = self
        upperIndicatorLayer.rangeSlider = self
        trackLayer.rangeSlider = self

        layer.backgroundColor = UIColor.clear.cgColor

        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)

        lowerIndicatorLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerIndicatorLayer)

        upperIndicatorLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperIndicatorLayer)
    }
    /// Tells the layer to update its layout.
    ///
    /// - Parameter ofLayer: The Layer that needs to be updated.
    override public func layoutSublayers(of ofLayer: CALayer) {
        super.layoutSublayers(of:layer)
        updateRangeSliderLayerFrames()
    }

    // MARK: Updating the UI for Range slider 

    /// Updating the UI for Range slider.
    func updateRangeSliderLayerFrames() {

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()

        /// Point for Lower Indicator center.
        let lowerIndicatorCenter = CGFloat(positionForValue(value: lowerValue))

        lowerIndicatorLayer.frame = CGRect(x: lowerIndicatorCenter - indicatorWidth / 2.0,
                                           y: 0.0,
                                           width: indicatorWidth,
                                           height: indicatorWidth)
        lowerIndicatorLayer.setNeedsDisplay()

        /// Point for Upper Indicator center.
        let upperIndicatorCenter = CGFloat(positionForValue(value: upperValue))
        upperIndicatorLayer.frame = CGRect(x: upperIndicatorCenter - indicatorWidth / 2.0,
                                           y: 0.0,
                                           width: indicatorWidth,
                                           height: indicatorWidth)
        upperIndicatorLayer.setNeedsDisplay()

        CATransaction.commit()
    }

    /// Determining the position for Range selection indicator.
    ///
    /// - Parameter value: It may be Lower Indicator value or Upper Indicator value.
    /// - Returns: Position for Indicator.
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - indicatorWidth) * (value - minValue) /
            (maxValue - minValue) + Double(indicatorWidth / 2.0)
    }

    //UIControl provides several methods for tracking touches

    // MARK: UIControl "beginTracking" method for starting the movement

    /// This is called when a touch event enters the control’s bounds. When indicator is touched.
    ///
    /// - Parameters:
    ///   - touch: The object containing information about the touch event.
    ///   - event: The event object containing the touch event.
    /// - Returns: True if the control should continue tracking touch events or false if it should stop. 
    /// This value is used to update the isTracking property of the control.
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previusLocPoint = touch.location(in: self)

        // Hit test the Indicator layers
        if lowerIndicatorLayer.frame.contains(previusLocPoint) {
            lowerIndicatorLayer.highlighted = true
        } else if upperIndicatorLayer.frame.contains(previusLocPoint) {
            upperIndicatorLayer.highlighted = true
        }

        return lowerIndicatorLayer.highlighted || upperIndicatorLayer.highlighted
    }

    /// Used to calculate Minimum from lower & upper.
    ///
    /// - Parameters:
    ///   - value: Selected indicator value.
    ///   - lowerValue: Lower Indicator value.
    ///   - upperValue: Upper Indicator value.
    /// - Returns: Minimum value.
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }

     // MARK: UIControl "continueTracking" method to continue movement

    /// This is called when a touch event associated with the control is updated.
    ///
    /// - Parameters:
    ///   - touch: The touch object containing updated information.
    ///   - event: The event object containing the touch event.
    /// - Returns: True if the control should continue tracking touch events or false if it should stop. 
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        /// Touch location
        let location = touch.location(in: self)

        /// Determine how much the user has dragged the indicator
        let deltaLocation = Double(location.x - previusLocPoint.x)
        /// Determine dragged location
        let deltaValue = (maxValue - minValue) * deltaLocation / Double(bounds.width - indicatorWidth)

        previusLocPoint = location

        // Update the values of indicators
        if lowerIndicatorLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue,
                                    toLowerValue: minValue,
                                    upperValue: upperValue - gapBetweenIndicators)
        } else if upperIndicatorLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue,
                                    toLowerValue: lowerValue+gapBetweenIndicators,
                                    upperValue:maxValue)
        }

        sendActions(for: .valueChanged)
        return true
    }

    // MARK: UIControl "endTracking" method to end touch/movement

    /// This is called when a touch event associated with the control ends.
    ///
    /// - Parameters:
    ///   - touch: The touch object containing the final touch information.
    ///   - event: The event object containing the touch event.
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerIndicatorLayer.highlighted = false
        upperIndicatorLayer.highlighted = false
    }

}

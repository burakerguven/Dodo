
import UIKit

class DodoButtonView: UIImageView {
  private let style: DodoButtonStyle
  var onTap: OnTap?
  
  init(style: DodoButtonStyle) {
    self.style = style
    
    super.init(frame: CGRect())
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Create button views for given button styles.
  static func createMany(styles: [DodoButtonStyle]) -> [DodoButtonView] {
    if !haveButtons(styles) { return [] }
    
    return styles.map { style in
      let view = DodoButtonView(style: style)
      view.setup()
      return view
    }
  }
  
  static func haveButtons(styles: [DodoButtonStyle]) -> Bool {
    let hasImages = styles.filter({ $0.image != nil }).count > 0
    return hasImages
  }
  
  func doLayout(#onLeftSide: Bool) {
    setTranslatesAutoresizingMaskIntoConstraints(false)
    
    // Set button's size
    TegAutolayoutConstraints.width(self, value: style.size.width)
    TegAutolayoutConstraints.height(self, value: style.size.height)
    
    if let superview = superview {
      let alignAttribute = onLeftSide ? NSLayoutAttribute.Left : NSLayoutAttribute.Right
      
      let marginHorizontal = onLeftSide ? style.horizontalMarginToBar : -style.horizontalMarginToBar
      
      // Align the button to the left/right of the view
      TegAutolayoutConstraints.alignSameAttributes(self, toItem: superview,
        constraintContainer: superview,
        attribute: alignAttribute, margin: marginHorizontal)
      
      // Center the button verticaly
      TegAutolayoutConstraints.centerY(self, viewTwo: superview, constraintContainer: superview)
    }
  }
  
  func setup() {
    style.image.map { applyStyle($0) }
    setupTap()
  }
  
  /// Increase the hitsize of the image view if it's less than 44px for easier tapping.
  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    let oprimizedBounds = DodoTouchTarget.optimize(bounds)
    return oprimizedBounds.contains(point)
  }
  
  private func applyStyle(imageIn: UIImage) {
    var imageToShow = imageIn
    if let tintColorToShow = style.tintColor {
      // Replace image colors with the specified tint color
      imageToShow = imageToShow.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      tintColor = tintColorToShow
    }
    
    image = imageToShow
    contentMode = UIViewContentMode.ScaleAspectFit
    
    // Make button accessible
    if let accessibilityLabelToShow = style.accessibilityLabel {
      isAccessibilityElement = true
      accessibilityLabel = accessibilityLabelToShow
      accessibilityTraits = UIAccessibilityTraitButton
    }
  }
  
  private func setupTap() {
    if let tapCallback = style.onTap {
      onTap = OnTap(view: self, gesture: UITapGestureRecognizer(), closure: tapCallback)
    }
  }
}
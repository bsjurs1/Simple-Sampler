//
//  WhitePianoKeyView.swift
//  Simple Sampler
//
//  Created by Bjarte Sjursen on 16/11/2019.
//  Copyright © 2019 Sjursen Software. All rights reserved.
//

import UIKit

@IBDesignable
class WhitePianoKeyView: CustomizableView {
    
    let whiteTopLayer = CALayer()
    var touchesBeganAction: (() -> Void)?
    var touchesEndedAction: (() -> Void)?
    
    override var bounds: CGRect {
        willSet {
            let whiteTopLayerFrame = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height - 8.0)
            whiteTopLayer.frame = whiteTopLayerFrame
        }
    }
    
    override var frame: CGRect {
        willSet {
            let whiteTopLayerFrame = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height - 8.0)
            whiteTopLayer.frame = whiteTopLayerFrame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor(red: 0.4000, green: 0.4039, blue: 0.4000, alpha: 1.0)
        cornerRadius = 8.0
        let whiteTopLayerFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 8.0)
        whiteTopLayer.frame = whiteTopLayerFrame
        whiteTopLayer.backgroundColor = UIColor.white.cgColor
        whiteTopLayer.cornerRadius = 8.0
        layer.insertSublayer(whiteTopLayer, at: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganAction?()
        whiteTopLayer.backgroundColor = UIColor(red: 0.6824,
                                                green: 0.6824,
                                                blue: 0.6824,
                                                alpha: 1.0).cgColor
        whiteTopLayer.frame = CGRect(x: whiteTopLayer.frame.origin.x,
                                     y: whiteTopLayer.frame.origin.y,
                                     width: whiteTopLayer.bounds.width,
                                     height: whiteTopLayer.bounds.height + 6.0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endButtonPress()
    }
    
    private func endButtonPress() {
        touchesEndedAction?()
        whiteTopLayer.backgroundColor = UIColor.white.cgColor
        whiteTopLayer.frame = CGRect(x: whiteTopLayer.frame.origin.x,
                                     y: whiteTopLayer.frame.origin.y,
                                     width: whiteTopLayer.bounds.width,
                                     height: whiteTopLayer.bounds.height - 6.0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        endButtonPress()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    deinit {
        touchesBeganAction = nil
        touchesEndedAction = nil
    }
    
}

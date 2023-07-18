//
//  extendwindow.swift
//  OperantChamberApp
//
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import UIKit


class ExtendVirtualWindow: NSObject {
    // bring subview時に反転して通知
    dynamic var bringingView: Bool = false

    var terminatorSize: CGSize
    var popPoint: CGPoint
    // innnerViewの回転許可
    var isWindowPort: Bool

    var masterWindow: UIView!
    var frameWindow: UIView!
    var barView: UIView!
    var pan: UIPanGestureRecognizer!
    var innerWindow: UIView!
    var parentView: UIView

    init(parentView: UIView, terminatorSize: CGSize, popPoint: CGPoint, isWindowPort: Bool) {
        self.parentView = parentView
        self.terminatorSize = terminatorSize
        self.popPoint = popPoint
        self.isWindowPort = isWindowPort

        super.init()

        isFullscreen = false

        drawWindow()
        parentView.addSubview(masterWindow)
    }

    var button1: UIButton!
    var button2: UIButton!
    var button3: UIButton!
    var isFullscreen: Bool = false

    let barLength: CGFloat = 30.0
    let frameLength: CGFloat = 1.5

    func drawWindow() {
        let borderColor: CGColor = UIColor(white: 0.3, alpha: 0.9).cgColor

        masterWindow = UIView(frame: CGRect(x: 0, y: 0, width: terminatorSize.width, height: terminatorSize.height))
        masterWindow.backgroundColor = UIColor.white
        masterWindow.layer.borderColor = borderColor
        masterWindow.layer.borderWidth = frameLength
        masterWindow.layer.cornerRadius = 7
        masterWindow.isUserInteractionEnabled = true
        masterWindow.layer.shadowOpacity = 0.5
        masterWindow.layer.shadowOffset = CGSize(width: 0, height: 10)
        masterWindow.layer.shadowRadius = 10.0
        masterWindow.layer.shadowColor = UIColor.black.cgColor

        frameWindow = UIView(frame: masterWindow.bounds)
        frameWindow.center = masterWindow.center
        frameWindow.backgroundColor = UIColor.white
        frameWindow.layer.borderColor = borderColor
        frameWindow.layer.borderWidth = frameLength
        frameWindow.layer.cornerRadius = 7
        frameWindow.clipsToBounds = true
        frameWindow.isUserInteractionEnabled = true
        masterWindow.addSubview(frameWindow)
        frameWindow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            frameWindow.leadingAnchor.constraint(equalTo: masterWindow.leadingAnchor),
            frameWindow.trailingAnchor.constraint(equalTo: masterWindow.trailingAnchor),
            frameWindow.topAnchor.constraint(equalTo: masterWindow.topAnchor),
            frameWindow.bottomAnchor.constraint(equalTo: masterWindow.bottomAnchor)
        ])


        innerWindow = UIView(frame: masterWindow.frame)
        innerWindow.center = CGPoint(
            x: masterWindow.center.x,
            y: masterWindow.center.y + barLength / 2 - frameLength / 2
        )
        innerWindow.isUserInteractionEnabled = true
        innerWindow.transform = CGAffineTransform(
            scaleX: (masterWindow.bounds.width - masterWindow.layer.borderWidth * 2) / terminatorSize.width,
            y: (masterWindow.bounds.height - masterWindow.layer.borderWidth - barLength)/terminatorSize.height
        )
        frameWindow.addSubview(innerWindow)
        innerWindow.backgroundColor = UIColor.black

        barView = UIView(frame: CGRect(x: 0, y: 0, width: masterWindow.bounds.width, height: barLength))
        barView.clipsToBounds = true
        let layer = CAGradientLayer()
        var colors: [CGColor] = []
        for i in 1...5 {
            colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.1 * (0.8 + CGFloat(i / 3))).cgColor)
        }
        layer.colors = colors
        layer.frame = barView.bounds
        barView.layer.addSublayer(layer)
        barView.layer.borderColor = borderColor
        barView.layer.borderWidth = frameLength
        pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle))
        barView.addGestureRecognizer(pan)

        for i in 0...2 {
            let button = UIButton(frame: CGRect(x: barLength / 6 + (barLength / 12 + barLength) * CGFloat(i), y: 0, width: barLength, height: barLength))
            let circle = UIView(frame: CGRect(x: 0, y: 0, width: barLength / 10 * 5, height: barLength / 10 * 5))
            circle.layer.cornerRadius = circle.bounds.width / 2
            circle.center = button.center
            switch i {
            case 0:
                circle.backgroundColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 0.9)
                button.addTarget(self, action: #selector(barButtonTap), for: .touchUpInside)
                break
            case 1:
                circle.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.0, alpha: 0.9)
                button.addTarget(self, action: #selector(barButtonTap), for: .touchUpInside)
                break
            case 2:
                circle.backgroundColor = UIColor(red: 0.6, green: 1.0, blue: 0.0, alpha: 0.9)
                button.addTarget(self, action: #selector(barButtonTap), for: .touchUpInside)
                break
            default:
                break
            }
            barView.addSubview(circle)

            switch i {
            case 0:
                button1 = button
                barView.addSubview(button1)
                break
            case 1:
                button2 = button
                barView.addSubview(button2)
                break
            case 2:
                button3 = button
                barView.addSubview(button3)
                break
            default:
                break
            }
        }

        barView.isUserInteractionEnabled = true
        frameWindow.addSubview(barView)

        masterWindow.frame = CGRect(x: 0, y: 0, width: 0, height: barLength)
        masterWindow.center = popPoint
    }

    @IBAction func barButtonTap(_ sender: UIButton) {
        switch sender {
        case button1:
            removeWindow()
        case button2:
            resizeWindow(delay: 0, duration: 1.0, scale: 0.5)
        case button3:
            let scale: CGFloat = isFullscreen ? 0.5 : 1.0
            resizeWindow(delay: 0, duration: 0.5, scale: scale)
            isFullscreen = !isFullscreen
        default:
            break
        }
    }

    @IBAction func panHandle(sender: UIPanGestureRecognizer) {
        if !isFullscreen && sender == pan {
            bringView()
            let move: CGPoint = sender.translation(in: masterWindow)
            masterWindow.center.x += move.x
            masterWindow.center.y += move.y
            sender.setTranslation(CGPoint.zero, in: masterWindow)
            if masterWindow.center.y - masterWindow.bounds.height / 2 < 0 {
                masterWindow.center.y = masterWindow.bounds.height / 2
            }

            maxMove()
        }
    }
    func bringView() {
        bringingView = !bringingView
        parentView.bringSubviewToFront(masterWindow)
    }
    func maxMove() {
        if masterWindow.center.y + masterWindow.bounds.height / 2 > terminatorSize.height {
            masterWindow.center.y = terminatorSize.height - masterWindow.bounds.height / 2
        }
        if masterWindow.center.x - masterWindow.bounds.width / 2 < 0 {
            masterWindow.center.x = masterWindow.bounds.width / 2
        }
        if masterWindow.center.x + masterWindow.bounds.width / 2 > terminatorSize.width {
            masterWindow.center.x = terminatorSize.width - masterWindow.bounds.width / 2
        }
    }
    func layoutSubView(_ size: CGSize) {
        terminatorSize = size
        maxMove()
    }

    func popWindow() {
        resizeWindow(delay: 0, duration: 0.5, scale: 0.5)
    }
    func resizeWindow(delay: Double, duration: Double, scale: CGFloat) {
        bringView()
        DispatchQueue.main.async {
            self.masterWindow.layer.borderWidth = self.frameLength
            self.masterWindow.layer.cornerRadius = 7
            self.frameWindow.layer.borderWidth = self.frameLength
            self.frameWindow.layer.cornerRadius = 7
        }
        masterWindow.isUserInteractionEnabled = false
        frameWindow.isHidden = true

        let centerPoint = CGPoint(x: parentView.center.x, y: parentView.center.y + barLength / 2)


        var now: Date!

        let prevScale: CGFloat = masterWindow.frame.width / terminatorSize.width
        enum comparison {
            case less, equal, grater
        }
        var scaleCheck: comparison
        if scale < prevScale {
            scaleCheck = .less
        } else if scale > prevScale {
            scaleCheck = .grater
        } else {
            scaleCheck = .equal
        }

        let terminatorSize = self.terminatorSize
        DispatchQueue.global().async {
            // delay処理
            if delay > 0 {
                now = Date()
                while true {
                    let nowDur = Date().timeIntervalSince(now)
                    if delay - nowDur <= 0 {
                        break
                    }
                }
            }

            //duration処置
            if duration >= 0.5 {
                now = Date()
                switch scaleCheck {
                case .less:
                    while true {
                        let nowDur = Date().timeIntervalSince(now)
                        let prop: CGFloat = CGFloat(nowDur/duration)
                        let size: CGSize = CGSize(width: prevScale * terminatorSize.width - ((prevScale - scale) * terminatorSize.width) * prop, height: prevScale * terminatorSize.height - ((prevScale - scale) * terminatorSize.height) * prop + self.barLength)
                        DispatchQueue.main.async {
                            self.masterWindow.frame = CGRect(x: self.parentView.center.x - size.width / 2, y: self.parentView.center.y - size.height / 2, width: size.width, height: size.height)
                        }
                        if duration - nowDur <= 0 {
                            break
                        }
                    }
                    break
                case .equal:
                    DispatchQueue.main.async {
                        self.masterWindow.frame = CGRect(x: 0, y: 0, width: (scale * self.terminatorSize.width), height: (scale * self.terminatorSize.height) + self.barLength)
                        self.masterWindow.center = centerPoint
                    }
                    while true {
                        let nowDur = Date().timeIntervalSince(now)
                        if duration - nowDur <= 0 {
                            break
                        }
                    }
                    break
                case .grater:
                    while true {
                        let nowDur = Date().timeIntervalSince(now)
                        let prop: CGFloat = CGFloat(nowDur / duration)
                        let size: CGSize = CGSize(
                            width: prevScale * terminatorSize.width + ((scale - prevScale) * terminatorSize.width) * prop,
                            height: prevScale * terminatorSize.height + ((scale - prevScale) * terminatorSize.height) * prop + self.barLength
                        )

                        DispatchQueue.main.sync {
                            self.masterWindow.frame = CGRect(
                                x: self.parentView.center.x - size.width / 2,
                                y: self.parentView.center.y - size.height / 2,
                                width: size.width,
                                height: size.height
                            )
                        }

                        if duration - nowDur <= 0 {
                            break
                        }
                    }
                    break
                }
            }

            // loopでずれるため，どの場合でも呼ぶ
            DispatchQueue.main.async {
                self.masterWindow.frame = CGRect(x: 0, y: 0, width: scale * terminatorSize.width, height: scale * terminatorSize.height + self.barLength)
                self.masterWindow.center = centerPoint
            }

            DispatchQueue.main.async {
                self.masterWindow.center = centerPoint
                if scale == 1.0 {
                    self.masterWindow.layer.borderWidth = 0
                    self.masterWindow.layer.cornerRadius = 0
                    self.frameWindow.layer.borderWidth = 0
                    self.frameWindow.layer.cornerRadius = 0
                }

                self.innerWindow.transform = CGAffineTransform(
                    scaleX: (self.masterWindow.bounds.width - self.masterWindow.layer.borderWidth * 2) / terminatorSize.width,
                    y: (self.masterWindow.bounds.height - self.masterWindow.layer.borderWidth - self.barLength) / terminatorSize.height
                )
                self.innerWindow.frame.origin = CGPoint(x: self.masterWindow.layer.borderWidth, y: self.barLength)
                self.frameWindow.isHidden = false

                self.masterWindow.isUserInteractionEnabled = true
            }
        }
    }

    func endResizeLoop() {}

    func removeWindow() {
        masterWindow.removeFromSuperview()
    }
}

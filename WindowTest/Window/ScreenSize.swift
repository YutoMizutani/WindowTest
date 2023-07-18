//
//  ScreenSize.swift
//  WindowTest
//
//  Created by Yuto Mizutani on 2023/07/19.
//

import UIKit

struct ScreenSize {
    static func bounds() -> CGRect {
        return UIScreen.main.bounds
    }
    static func size() -> CGSize {
        return UIScreen.main.bounds.size
    }
    static func height() -> CGFloat {
        return size().height
    }
    static func width() -> CGFloat {
        return size().width
    }
    static func long() -> CGFloat {
        let size = self.size()
        return size.height > size.width ? size.height : size.width
    }
    static func short() -> CGFloat {
        let size = self.size()
        return size.height > size.width ? size.width : size.height
    }

    static func bounds(_ view:UIView) -> CGRect {
        return view.bounds
    }
    static func size(_ view:UIView) -> CGSize {
        return bounds(view).size
    }
    static func height(_ view:UIView) -> CGFloat {
        return size(view).height
    }
    static func width(_ view:UIView) -> CGFloat {
        return size(view).width
    }
    static func long(_ view:UIView) -> CGFloat {
        let size = self.size(view)
        return size.height > size.width ? size.height : size.width
    }
    static func short(_ view:UIView) -> CGFloat {
        let size = self.size(view)
        return size.height > size.width ? size.width : size.height
    }
}

//
//  Viewswift
//  WindowTest
//
//  Created by Yuto Mizutani on 2023/07/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!

    var popViews:[ExtendVirtualWindow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func addNewWindow() {
        popViews.append(
            ExtendVirtualWindow(
                parentView: view,
                terminatorSize: ScreenSize.size(view),
                popPoint: view.center,
                isWindowPort: false
            )
        )

        popViews[popViews.count-1].popWindow()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.addCountUpLabel(self.popViews[self.popViews.count-1])
        }
    }

    private func addCountUpLabel(_ window: ExtendVirtualWindow) {
        let date = Date()
        let label = {
            let label = UILabel(frame: window.innerWindow.bounds)
            label.font = UIFont.systemFont(ofSize: 100, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .white
            return label
        }()

        window.innerWindow.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: window.innerWindow.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: window.innerWindow.centerYAnchor)
        ])

        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            let duration = Date().timeIntervalSince(date)
            label.text = "\(Double(Int(duration * 10)) / 10)"
        })
        timer.fire()
    }
}


//
//  MenuDataSource.swift
//  ExampleOfiOSLiDAR
//
//  Created by TokyoYoshida on 2021/01/31.
//

import UIKit

struct MenuItem {
    let title: String
    let description: String
    let prefix: String
    
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: prefix, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        vc.title = title

        return vc
    }
}

class MenuViewModel {
    private let dataSource = [
        MenuItem (
            title: "Simple Recording",
            description: "Recording video.",
            prefix: "SimpleRecording"
        ),
        MenuItem (
            title: "Frame Recording",
            description: "Frame-by-frame recording using AVAssetsWriter.",
            prefix: "FrameRecording"
        )
    ]
    
    var count: Int {
        dataSource.count
    }
    
    func item(row: Int) -> MenuItem {
        dataSource[row]
    }
    
    func viewController(row: Int) -> UIViewController {
        dataSource[row].viewController()
    }
}

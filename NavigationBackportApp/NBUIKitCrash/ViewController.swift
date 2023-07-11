//
//  ViewController.swift
//  Test3
//
//  Created by Eric Jubber on 7/8/23.
//

import NavigationBackport
import SwiftUI
import UIKit

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    embedView()
    navigationController?.navigationBar.isHidden = true
    // Do any additional setup after loading the view.
  }

  func embedView() {
    let v = ContentView()
    let hostingController = UIHostingController(rootView: v)
    addChild(hostingController)
    hostingController.view.backgroundColor = UIColor.white
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

//
//  ViewController.swift
//  YangSliderView
//
//  Created by xilankong on 08/24/2018.
//  Copyright (c) 2018 xilankong. All rights reserved.
//

import UIKit
import SnapKit
import YangSliderView
class ViewController: UIViewController {

    
    var vcs = [UIViewController & YangSliderViewContainerDelegate]()
    var titles = [String]()
    let slideMenu = YangSliderView(frame: CGRect.zero, indicatorType: .stretch, titles: [], childControllers: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        slideMenu.tabBarWidth = 230.0
        slideMenu.indicatorWidth = 73.0
        view.backgroundColor = UIColor.white
        
        let vc1 = YangSliderViewContainerViewController()
        vc1.view.backgroundColor = UIColor.green
        let vc2 = YangSliderViewContainerViewController()
        vc2.view.backgroundColor = UIColor.yellow
        let vc3 = YangSliderViewContainerViewController()
        vc3.view.backgroundColor = UIColor.black
        let vc4 = YangSliderViewContainerViewController()
        vc4.view.backgroundColor = UIColor.purple
        let vc5 = YangSliderViewContainerViewController()
        vc5.view.backgroundColor = UIColor.gray
        vcs = [vc1, vc2]
        
        titles = ["tab-1", "tab-2"]
        
        slideMenu.reloadView(titles: titles, controllers: vcs)
        view.addSubview(slideMenu)
        automaticallyAdjustsScrollViewInsets = false
        slideMenu.snp.makeConstraints {
            $0.left.right.bottom.equalTo(self.view)
            $0.top.equalTo(self.view).offset(120)
        }
 
    }
    
    @objc func change() {
        let index = (slideMenu.currentIndex + 1) > titles.count - 1 ? 0 : (slideMenu.currentIndex + 1)
        slideMenu.currentIndex = index
    }

}


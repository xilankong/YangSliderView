//
//  YangSliderView.swift
//  Masonry
//
//  Created by yanghuang on 2018/1/11.
//

import Foundation
import UIKit

enum YangSliderViewIndicatorType {
    case normal
    case stretch
    case stretchAndMove
}

@objc public protocol YangSliderViewContainerDelegate: NSObjectProtocol {
    @objc optional func reloadView()
}

@objc public protocol YangSliderViewDelegate: NSObjectProtocol {
    @objc optional func sliderView_switchToTab(currentIndex: Int)
}

@objc public class YangSliderView: UIView {
    
    //MARK: - properties
    
    @objc public weak var delegate: YangSliderViewDelegate?
    
    private var titles: [String] = []
    
    private var controllers: [UIViewController & YangSliderViewContainerDelegate] = []
    
    private var tabScrollView: UIScrollView = UIScrollView()
    
    private var mainScrollView: UIScrollView = UIScrollView()
    
    private var line: UIView = UIView()
    
    private var leftIndex = 0
    
    private var rightIndex = 0
    //tab的边距
    private var itemMargin: CGFloat = 0.0
    
    private var itemWidth: CGFloat = 80.0
    
    private var items: [UILabel] = []
    
    private let indicatorView: UIView = UIView()
    
    var tabBarHeight: CGFloat = 45.0
    
    var indicatorWidth: CGFloat = 60.0
    
    var indicatorType: YangSliderViewIndicatorType = .normal
    
    //伸缩动画的偏移量
    fileprivate let indicatorAnimatePadding: CGFloat = 8.0
    
    //标题字体
    @objc public var itemFont: UIFont = UIFont.systemFont(ofSize: 15)
    
    //选中颜色
    @objc public var itemSelectedColor: UIColor = UIColor.red
    
    //未选中颜色
    @objc public var itemUnselectedColor: UIColor = UIColor.gray
    
    //下标距离底部距离
    var bottomPadding: CGFloat = 0.0
    
    //下标高度
    var indicatorHeight: CGFloat = 2.0
    
    private var _currentIndex: Int = 0
    public var currentIndex: Int {
        get { return _currentIndex }
        set {
            if newValue != _currentIndex {
                goToTab(fromIndex: _currentIndex, toIndex: newValue)
                _currentIndex = newValue
            }
        }
    }
    
    //MARK: - xib初始化
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    //MARK: - frame初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    //MARK: - 参数初始化
    public init(frame: CGRect,titles: [String],childControllers: [UIViewController & YangSliderViewContainerDelegate]) {
        
        super.init(frame: frame)
        initUI()
        self.titles = titles
        self.controllers = childControllers
    }
    
    //MARK: - 基础UI初始化
    private func initUI() {
        self.backgroundColor = UIColor.white
        
        line.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        line.frame = CGRect(x: 0, y: self.tabBarHeight - 0.5, width: self.bounds.size.width, height: 0.5)
        addSubview(line)
        
        tabScrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: tabBarHeight)
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.backgroundColor = .clear
        addSubview(tabScrollView)
        
        mainScrollView.frame = CGRect(x: 0, y: tabBarHeight, width: self.bounds.size.width, height: self.bounds.size.height - tabBarHeight)
        mainScrollView.bounces = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.delegate = self
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        addSubview(mainScrollView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.frame.size.width != 0 {
            reloadView(titles: self.titles, controllers: self.controllers)
        }
    }
    
    
    //MARK: - 内容UI更新
    public func reloadView(titles: [String],controllers: [UIViewController & YangSliderViewContainerDelegate] ) {
        self.titles = titles
        self.controllers = controllers
        line.frame = CGRect(x: 0, y: self.tabBarHeight - 0.5, width: self.bounds.size.width, height: 0.5)
        tabScrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: tabBarHeight)
        mainScrollView.frame = CGRect(x: 0, y: tabBarHeight, width: self.bounds.size.width, height: self.bounds.size.height - tabBarHeight)
        setupTabScrollView()
        setupChildControllers()
        self.controllers[_currentIndex].reloadView?()
    }
    
    //MARK: - tab切换
    private func goToTab(fromIndex: Int, toIndex: Int) {
        if toIndex >= items.count {
            return
        }
        let item = items[toIndex]
        
        changeItemTitle(fromIndex, to: toIndex)
        resetTabScrollViewContentOffset(item)
        resetMainScrollViewContentOffset(toIndex)
        delegate?.sliderView_switchToTab?(currentIndex: toIndex)
        self.controllers[toIndex].reloadView?()
    }
    
    //MARK: - 配置滑块栏
    private func setupTabScrollView() {
        
        //clean
        _ = self.tabScrollView.subviews.map {
            $0.removeFromSuperview()
        }
        self.items.removeAll()
        
        var originX = itemMargin
        for (index,title) in titles.enumerated() {
            
            let item = UILabel()
            item.isUserInteractionEnabled = true
            //计算title长度
            item.frame = CGRect(x: originX, y: 0, width: itemWidth, height: tabScrollView.bounds.height)
            //设置属性
            item.text = title
            item.textAlignment = .center
            item.font = itemFont
            item.textColor = index == _currentIndex ? itemSelectedColor : itemUnselectedColor
            //添加tap手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemDidClicked(_:)))
            item.addGestureRecognizer(tap)
            
            items.append(item)
            tabScrollView.addSubview(item)
            
            originX = item.frame.maxX + itemMargin * 2
        }
        
        tabScrollView.contentSize = CGSize(width: originX - itemMargin, height: tabScrollView.bounds.height)
        
        if tabScrollView.contentSize.width < self.bounds.width {
            //如果item的长度小于self的width，就重新计算margin排版
            updateLabelsFrame()
        }
        setupIndicatorView()
    }
    
    //MARK: - 配置子控制器
    private func setupChildControllers() {
        _ = mainScrollView.subviews.map {
            $0.removeFromSuperview()
        }
        for (index,vc) in controllers.enumerated() {
            mainScrollView.addSubview(vc.view)
            vc.view.frame = CGRect(x: CGFloat(index) * mainScrollView.bounds.width, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height)
        }
        mainScrollView.contentSize = CGSize(width: CGFloat(controllers.count) * mainScrollView.bounds.width, height: 0)
        mainScrollView.contentOffset = CGPoint(x: CGFloat(_currentIndex) * mainScrollView.bounds.width, y: 0)
    }
    
    //MARK: - 配置滑块下标
    private func setupIndicatorView() {
        indicatorView.removeFromSuperview()
        tabScrollView.addSubview(indicatorView)
        var frame = items[_currentIndex].frame
        frame.origin.y = tabScrollView.bounds.height - bottomPadding - indicatorHeight
        frame.origin.x = frame.origin.x + (frame.size.width - indicatorWidth) / 2.0
        frame.size.height = indicatorHeight
        frame.size.width = indicatorWidth > frame.size.width ? frame.size.width : indicatorWidth
        
        indicatorView.frame = frame
        indicatorView.backgroundColor = itemSelectedColor
        
        indicatorView.layer.cornerRadius = frame.height * 0.5
        indicatorView.layer.masksToBounds = true
    }
    
    //MARK: - 当item过少时，更新item位置，多滚动，少重新布局
    private func updateLabelsFrame() {
        let newMargin = itemMargin + (self.bounds.width - tabScrollView.contentSize.width) / CGFloat(items.count * 2)
        var originX = newMargin
        for item in items {
            var frame = item.frame
            frame.origin.x = originX
            item.frame = frame
            originX = frame.maxX + 2 * newMargin
        }
        tabScrollView.contentSize = CGSize(width: originX - newMargin, height: tabBarHeight)
    }
    
    //MARK: - item点击事件
    @objc private func itemDidClicked(_ gesture: UITapGestureRecognizer) {
        
        let item = gesture.view as! UILabel
        if item == items[_currentIndex] { return }
        let fromIndex = _currentIndex
        _currentIndex = items.index(of: item)!
        
        goToTab(fromIndex: fromIndex, toIndex: _currentIndex)
    }
    
    //MARK: - 改变itemTitle颜色
    private func changeItemTitle(_ from: Int, to: Int) {
        items[from].textColor = itemUnselectedColor
        items[to].textColor = itemSelectedColor
    }
    
    //MARK: - 点击item 修改滑块栏的偏移量
    private func resetTabScrollViewContentOffset(_ item: UILabel) {
        var destinationX: CGFloat = 0
        let itemCenterX = item.center.x
        let scrollHalfWidth = tabScrollView.bounds.width / 2
        //item中心点超过最高滚动范围时
        if tabScrollView.contentSize.width - itemCenterX < scrollHalfWidth {
            destinationX = tabScrollView.contentSize.width - scrollHalfWidth * 2
            tabScrollView.setContentOffset(CGPoint(x: destinationX, y: 0), animated: true)
            return
        }
        //item中心点低于最低滚动范围时
        if itemCenterX > scrollHalfWidth{
            destinationX = itemCenterX - scrollHalfWidth
            tabScrollView.setContentOffset(CGPoint(x: destinationX, y: 0), animated: true)
            return
        }
        tabScrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
    }
    
    //MARK: - 修改mainScrollView的偏移量
    private func resetMainScrollViewContentOffset(_ index: Int) {
        mainScrollView.setContentOffset(CGPoint(x: CGFloat(index) * mainScrollView.bounds.width, y: 0), animated: true)
    }
    
}

//MARK: - UIScrollViewDelegate
extension YangSliderView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        switch indicatorType {
        case .normal:
            dealNormalIndicatorType(offsetX)
        case .stretch:
            dealFollowTextIndicatorType(offsetX)
        case .stretchAndMove:
            dealFollowTextIndicatorType(offsetX)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeItemStatusBecauseDealNormalIndicatorType()
    }
    
    //MARK: - 手动滑动scrollView跳转处理
    fileprivate func changeItemStatusBecauseDealNormalIndicatorType() {
        let to = Int(mainScrollView.contentOffset.x / mainScrollView.bounds.width)
        let toItem = items[to]
        
        let fromIndex = _currentIndex
        _currentIndex = items.index(of: toItem)!
        goToTab(fromIndex: fromIndex, toIndex: _currentIndex)
    }
    
    //MARK: - 处理normal状态的 indicatorView
    fileprivate func dealNormalIndicatorType(_ offsetX: CGFloat) {
        if offsetX <= 0 {
            //左边界
            leftIndex = 0
            rightIndex = 0
            
        } else if offsetX >= mainScrollView.contentSize.width {
            //右边界
            leftIndex = items.count - 1
            rightIndex = leftIndex
        } else {
            //中间
            leftIndex = Int(offsetX / mainScrollView.bounds.width)
            rightIndex = leftIndex + 1
        }
        
        let ratio = offsetX / mainScrollView.bounds.width - CGFloat(leftIndex)
        if ratio == 0 { return }
        
        let leftItem = items[leftIndex]
        let rightItem = items[rightIndex]
        
        let totalSpace = rightItem.center.x - leftItem.center.x
        indicatorView.center = CGPoint(x:leftItem.center.x + totalSpace * ratio, y: indicatorView.center.y)
    }
    
    //MARK: - 处理followText状态的 indicatorView
    fileprivate func dealFollowTextIndicatorType(_ offsetX: CGFloat) {
        if offsetX <= 0 {
            //左边界
            leftIndex = 0
            rightIndex = 0
            
        } else if offsetX >= mainScrollView.contentSize.width {
            //右边界
            leftIndex = items.count - 1
            rightIndex = leftIndex
        } else {
            //中间
            leftIndex = Int(offsetX / mainScrollView.bounds.width)
            rightIndex = leftIndex + 1
        }
        
        let ratio = offsetX / mainScrollView.bounds.width - CGFloat(leftIndex)
        if ratio == 0 { return }
        
        let leftItem = items[leftIndex]
        let rightItem = items[rightIndex]
        
        let distance: CGFloat = indicatorType == .stretch ? 0 : indicatorAnimatePadding
        var frame = self.indicatorView.frame
        let maxWidth = rightItem.frame.maxX - leftItem.frame.minX - distance * 2
        
        if ratio <= 0.5 {
            frame.size.width = leftItem.frame.width + (maxWidth - leftItem.frame.width) * (ratio / 0.5)
            frame.origin.x = leftItem.frame.minX + distance * (ratio / 0.5)
        } else {
            frame.size.width = rightItem.frame.width + (maxWidth - rightItem.frame.width) * ((1 - ratio) / 0.5)
            frame.origin.x = rightItem.frame.maxX - frame.size.width - distance * ((1 - ratio) / 0.5)
        }
        
        self.indicatorView.frame = frame
    }
}

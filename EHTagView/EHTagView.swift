//
//  EHTagView.swift
//  EasyAtHome
//
//  Created by samuelandkevin on 2024/10/19.
//  Copyright © 2024 Easy Healthcare Corporation. All rights reserved.
//

import Foundation
import SnapKit

enum EHTagViewLayout {
    /// 一行显示，超出可以滚动
    case oneRowScroll
    /// wrap
    case wrap
}

enum EHTagStatus:Int {
    /// 正常
    case normal = 0
    /// 选中
    case selected = 1
    /// 禁止
    case disabled = 2
}

class EHTagModel {
    var status: EHTagStatus = .normal
    var title: String = ""
    var imageName: String = ""
}

class EHTagView: UIView {
    
    ///标签数组
    var tags: [EHTagModel] = [] {
        didSet {
            relaodData()
        }
    }
    ///展示方向 左右展示(可滑动) 上下展示(不可滑动)
    var layout: EHTagViewLayout = .wrap
    ///字体颜色
    var titleColor: UIColor = "#383838".color
    ///选中字体颜色
    var selectedTitleColor: UIColor = "#9E3CF8".color
    
    ///文字字体
    var titleFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    ///标签离背景左右间距
    var padding: CGFloat = 0 {
        didSet {
            titleBtnX = padding
        }
    }
    /// 标签之间左右间距
    var minimumInteritemSpacing: CGFloat = 12
    /// 标签之间上下间距
    var minimumLineSpacing: CGFloat = 10
    /// 标签背景颜色
    var bgColor: UIColor = "#F5F3F7".color
    /// 选中标签背景颜色
    var selectedBgColor: UIColor = "#F5EBFE".color
    /// 文字离标签间距
    var tagInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
    /// 标签圆角
    var radius: CGFloat = 18
    /// 标签的高度
    var titleBtnH: CGFloat = 36
    /// 图片宽
    var imageWidth: CGFloat = 32
    /// 图片高
    var imageHeight: CGFloat = 32
    /// 图片和文字之间的距离
    var imageAndTitleSpace: CGFloat = 12
    /// 按钮最大宽度
    var maxButtonWidth: CGFloat = 0
    /*
     * 只有上下排列才需要
     */
    ///view的宽度 (如果使用SnapKit布局必须给定TagView的宽度)
    var tagViewW: CGFloat = 0
    
    
    // 第一个标签的开始x
    private var titleBtnX: CGFloat = 0
    // 标签的y
    private var titleBtnY: CGFloat = 0
    /// 获取上下排列时 view的高度
    private (set) var viewH: CGFloat = 0
    
    //view上的ScrollView
    private var bgScrollView: UIScrollView?
    //标签views
    private var tagViews: [UIView] = []
    
    typealias selectTagBlack = (_ index: Int) -> ()
    private var selectTag: selectTagBlack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///标签点击回调
    func didSelectTagCallback(selectTag: @escaping selectTagBlack) {
        self.selectTag = selectTag
    }
    
    //刷新数据
    private func relaodData() {
        setupSubViews(tags: tags)
    }
    
    // MARK: 设置话题
    private func setupSubViews(tags: [EHTagModel]) {
        bgScrollView?.removeFromSuperview()
        bgScrollView = UIScrollView()
        bgScrollView?.backgroundColor = .clear
        bgScrollView?.showsVerticalScrollIndicator = false
        bgScrollView?.showsHorizontalScrollIndicator = false
        addSubview(bgScrollView!)
        bgScrollView?.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        addButton(tags: tags)
    }
    
    
    private func addButton(tags: [EHTagModel]) {
        tagViews.removeAll()
        if tags.count == 0 {
            return
        }
        if tags.count > 0 {
            for i in 0..<tags.count {
                let selected: Bool = tags[i].status == .selected
                let bgView = UIView()
                let tap = UITapGestureRecognizer(target: self, action: #selector(titleBtnClick(_:)))
                bgView.addGestureRecognizer(tap)
                
                let imageIsEmpty: Bool = tags[i].imageName.isEmpty
                let imageV = UIImageView()
                imageV.image = UIImage(named: tags[i].imageName)
                imageV.tag = i + 1000
                bgView.addSubview(imageV)
                
               
                let titleBtn = UILabel.createLabel(text: tags[i].title, textAlignment: .left, textColor: selected ? selectedTitleColor : titleColor, font: titleFont)
                //设置按钮的样式
                titleBtn.tag = i
                titleBtn.sizeToFit()
                
                var titleBtnWidth = titleBtn.frame.width
                var bgViewWidth = titleBtn.frame.width + tagInsets.left + tagInsets.right + (imageIsEmpty ? 0 : (imageWidth + imageAndTitleSpace))
                
                if layout == .wrap {
                    // 默认最大按钮的宽度
                    var _maxButtonWidth = self.frame.width - 2*padding
                    if maxButtonWidth > 0 {
                        _maxButtonWidth = maxButtonWidth
                    }
                    if bgViewWidth >= _maxButtonWidth {
                        bgViewWidth = _maxButtonWidth
                        titleBtn.numberOfLines = 0
                        titleBtn.adjustsFontSizeToFitWidth = true
                    } else {
                        titleBtn.numberOfLines = 1
                        titleBtn.adjustsFontSizeToFitWidth = false
                    }
                }
                
                bgView.tag = i
                bgView.frame.size.height = titleBtnH
                bgView.frame.origin.y = 0
                bgView.layer.cornerRadius = radius
                bgView.layer.masksToBounds = true
                bgView.backgroundColor = selected ? selectedBgColor : bgColor
                bgView.layer.borderColor = selected ? selectedTitleColor.cgColor : nil
                bgView.layer.borderWidth = selected ? 1 : 0
                bgView.frame.size.width = bgViewWidth
                
                if layout == .oneRowScroll {
                    if i == 0 {
                        bgView.frame.origin.x = padding
                    } else {
                        bgView.frame.origin.x = tagViews[i - 1].frame.maxX + minimumInteritemSpacing
                    }
                } else {
                    //判断按钮是否超过屏幕的宽
                    if titleBtnX + bgViewWidth > (tagViewW == 0 ? frame.width : tagViewW) - padding {
                        titleBtnX = padding
                        if i != 0 {
                            titleBtnY += titleBtnH + minimumLineSpacing
                        }
                        
                    }
                    //设置按钮的位置
                    bgView.frame = CGRect(x: titleBtnX, y: titleBtnY, width: bgViewWidth, height: titleBtnH)
                    titleBtnX += bgViewWidth + minimumInteritemSpacing
                }
                
                bgView.addSubview(titleBtn)
                titleBtn.snp.makeConstraints { make in
                    make.centerY.equalTo(bgView)
                    if imageIsEmpty {
                        make.leading.equalTo(bgView).inset(tagInsets.left)
                    } else {
                        make.leading.equalTo(imageV.snp.trailing).offset(imageAndTitleSpace)
                    }
                    make.trailing.equalTo(bgView).inset(tagInsets.right)
                    
                }
                if !imageIsEmpty {
                    imageV.snp.makeConstraints { make in
                        make.leading.equalTo(bgView)
                        make.centerY.equalTo(bgView)
                        make.width.equalTo(imageWidth)
                        make.height.equalTo(imageHeight)
                    }
                }
                imageV.isHidden = imageIsEmpty
                tagViews.append(bgView)
                bgScrollView?.addSubview(bgView)
            }
        }
        bgScrollView?.contentSize = CGSize(width: (tagViews.last?.frame.maxX ?? 0) + padding, height: 0)
        frame.size.height = tagViews.last?.frame.maxY ?? 0
        viewH = tagViews.last?.frame.maxY ?? 0
    }
    
    
    func updateSelected(_ selected: Bool, index: Int) {
        guard index < tagViews.count else {
            return
        }
        let bgView = tagViews[index]
        bgView.backgroundColor = selected ? selectedBgColor : bgColor
        bgView.layer.borderColor = selected ? selectedTitleColor.cgColor : nil
        bgView.layer.borderWidth = selected ? 1 : 0
        let titleBtn = getTitleBtn(index)
        titleBtn?.textColor = selected ? selectedTitleColor : titleColor
    }
    
    private func getImageView(_ index: Int) -> UIImageView? {
        guard index < tagViews.count else {
            return nil
        }
        let bgView = tagViews[index]
        guard let imageV = bgView.viewWithTag(index+1000) as? UIImageView else {
            return nil
        }
        return imageV
    }
    
    private func getTitleBtn(_ index: Int) -> UILabel? {
        guard index < tagViews.count else {
            return nil
        }
        let bgView = tagViews[index]
        guard let titleBtn = bgView.viewWithTag(index) as? UILabel else {
            return nil
        }
        return titleBtn
    }
    
    ///标签点击
    @objc private func titleBtnClick(_ ges: UIGestureRecognizer) {
        if let view = ges.view {
            selectTag?(view.tag)
        }
        
    }

}


extension UILabel {
    
    /// 创建UILabel
    public class func createLabel(text:String?,textAlignment:NSTextAlignment,textColor:UIColor,font:UIFont) -> UILabel {
        let v = UILabel()
        v.text = text
        v.textAlignment = textAlignment
        v.font = font
        v.textColor = textColor
        v.textAlignment = textAlignment
        return v
    }
}

public extension String {
    /// 获取颜色值 #fff, fff, #f0f0f0, f0f0f0
    var color: UIColor {
        get {
            var cacheString = self
            if cacheString.hasPrefix("#") {
                let startIndex = cacheString.index(cacheString.startIndex, offsetBy: 1)
                cacheString = String(cacheString[startIndex...])
            }
            if cacheString.count == 3 {
                
                let redString = cacheString.prefix(1)
                let startIndex = cacheString.index(cacheString.startIndex, offsetBy: 1)
                let endIndex = cacheString.index(cacheString.startIndex, offsetBy: 2)
                let greenString = cacheString[startIndex..<endIndex]
                let blueString = cacheString.suffix(1)
                var red: UInt32 = 0
                var green: UInt32 = 0
                var blue: UInt32 = 0
                Scanner(string: "\(redString)\(redString)").scanHexInt32(&red)
                Scanner(string: "\(greenString)\(greenString)").scanHexInt32(&green)
                Scanner(string: "\(blueString)\(blueString)").scanHexInt32(&blue)
                
                return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
                
            } else if cacheString.count == 6 {
                
                let redString = cacheString.prefix(2)
                let startIndex = cacheString.index(cacheString.startIndex, offsetBy: 2)
                let endIndex = cacheString.index(cacheString.startIndex, offsetBy: 4)
                let greenString = cacheString[startIndex..<endIndex]
                let blueString = cacheString.suffix(2)
                var red: UInt32 = 0
                var green: UInt32 = 0
                var blue: UInt32 = 0
                
                Scanner(string: "\(redString)").scanHexInt32(&red)
                Scanner(string: "\(greenString)").scanHexInt32(&green)
                Scanner(string: "\(blueString)").scanHexInt32(&blue)
                return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
            }
            return UIColor.black
        }
    }
}

//
//  ViewController.swift
//  EHTagView
//
//  Created by samuelandkevin on 2024/10/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tags = tags()
        //上下排列 不可滑动
        let viewTag = EHTagView(frame: CGRect(x: 0, y: 300, width: view.frame.width, height: 30))
        viewTag.layout = .wrap //展示方向
        viewTag.didSelectTagCallback { index in //标签点击回调
            print("index: \(index)")
            let selected = tags[index].status == .selected
            tags[index].status = selected ? .normal : .selected
            viewTag.updateSelected(!selected, index: index)
        }
        viewTag.padding = 0
        viewTag.backgroundColor = .yellow
        view.addSubview(viewTag)
        viewTag.tags = tags //给标签数组赋值
        //给view设置高度为标签总高度
        viewTag.frame.size.height = viewTag.viewH
        viewTag.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.top.equalTo(300)
            make.trailing.equalTo(0)
            make.height.equalTo(viewTag.viewH)
        }
    }
    
    private func tags() -> [EHTagModel] {
        var tags = [EHTagModel]()
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_cm"
            m.title = "這是每當朋友抱怨著 ddsa en dl dl sadlk saldkf slkdsaldkf salkdf"
            return m
        }())
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_kg"
            m.title = "個真實的"
            return m
        }())
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_cm"
            m.title = "故事"
            return m
        }())
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_ai"
            m.title = "每當朋友抱怨著 ddd dddds sfsd"
            return m
        }())
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_moods"
            m.title = "婚姻"
            return m
        }())
        tags.append({
            let m = EHTagModel()
            m.imageName = "dailylog_ic_bbt"
            m.title = "如何讓"
            return m
        }())
        return tags
    }


}


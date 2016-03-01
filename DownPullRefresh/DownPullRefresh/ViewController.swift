//
//  ViewController.swift
//  DownPullRefresh
//
//  Created by 李斌 on 16/3/1.
//  Copyright © 2016年 xiaoyungo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private lazy var datas: [Int] = [Int]();
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置UI
        setupUI();
        //加载数据
        loadData();
    }
    
//MARK:- 设置UI
    private func setupUI(){
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell_ID");
        tableView.dataSource = self;
        tableView.addSubview(lb_RefreshControl);
        
    }
//MARK:- 加载数据
    @objc private func loadData(){
        for var i = 0; i < 5; i++ {
            self.datas.append(i);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2.0 * CGFloat(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData();
            //将刷新控件停止动画
            self.lb_RefreshControl.endRefreshing();
        }
        
    }
    
//MARK:- 懒加载下拉刷新控件
    private lazy var lb_RefreshControl: LBRefreshControl = {
        let control = LBRefreshControl();
        //在这里添加方法后，可以通过sendActionsForControlEvents(.ValueChanged);去调用注册的action
        control.addTarget(self, action: "loadData", forControlEvents: .ValueChanged);
        return control;
    }();
    
   
    
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell_ID", forIndexPath: indexPath);
        cell.textLabel?.text = "\(self.datas[indexPath.row])";
        return cell;
    }
    
}







import UIKit
enum LBRefreshState: Int {
    case Normal = 0//默认状态
    case Pulling = 1//松手就可刷新的状态
    case Refreshing = 2//刷新中的状态
    
}

private let LBRefreshControlH: CGFloat = 50;

class LBRefreshControl: UIControl {
//MARK:- 属性
    let SCREENW = UIScreen.mainScreen().bounds.size.width;
    //父控件，LBRefreshControl所在的scrollView
    var scrollView: UIScrollView?

    //当前控件的状态，
    var lb_state: LBRefreshState = .Normal {
        didSet{
            switch lb_state {
            case .Pulling:
                //箭头反转
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.iconView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
                });
                //更改文字
                messageLabel.text = "放开加载";
            case .Normal:
                iconView.hidden = false;
                indicatorView.stopAnimating();
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.iconView.transform = CGAffineTransformMakeRotation(CGFloat(0));
                })
                messageLabel.text = "下拉加载";
                //如果之前的状态是Refreshing，
                if oldValue == .Refreshing {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIView.animateWithDuration(0.25, animations: { () -> Void in
                            self.scrollView?.contentInset.top = self.scrollView!.contentInset.top - LBRefreshControlH;
                            
                            self.scrollView?.setContentOffset(CGPoint(x: 0, y: -self.scrollView!.contentInset.top), animated: false);
                        })
                    })   
                }
            case .Refreshing:
                //隐藏箭头
                iconView.hidden = true;
                //菊花开始转
                indicatorView.startAnimating();
                messageLabel.text = "正在刷新"
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.scrollView?.contentInset.top = self.scrollView!.contentInset.top + LBRefreshControlH;
                })
                //系统会去找ValueChanged对应的target 和 action 并且去调用
                sendActionsForControlEvents(.ValueChanged);
            }
        }
    }
    
//MARK:- 初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK:- 设置UI
    private func setupUI(){
//        backgroundColor = UIColor.orangeColor();
        frame.size = CGSize(width: SCREENW, height: LBRefreshControlH)
        frame.origin.y = -LBRefreshControlH;
        
        //加载子控件
        addSubview(iconView);
        addSubview(messageLabel);
        addSubview(indicatorView);
        
        //布局，使用了SnapKit框架
        iconView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self);
            make.centerX.equalTo(self).offset(-30);
        }
        messageLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(iconView.snp_trailing);
            make.centerY.equalTo(iconView);
        }
        
        indicatorView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(iconView);
        }
    }

    //取到父控件
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview);
        guard let scrollView = newSuperview as? UIScrollView else {
            return;
        }
        self.scrollView = scrollView;
        //添加 KVO 对 scrollView 的滚动 contentOffset 进行监听
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil);
    }
    
//MARK:- KVO监听
    //当kvo观察者属性有改变时调用此方法
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // 当前 scrollView 的滚动的 y 方向的偏移量
        let contentOffsetY = scrollView!.contentOffset.y;
         // 顶部内边距
        let contentInsetTop = scrollView!.contentInset.top;
        // 根据滚动位置,判断当前控件是否真的完全显示出来了
        // 分析出来,只要 contentOffsetY > -114 代表没有完全显示出来
        // 否则,就完全显示出来了
        if scrollView!.dragging {
            //手还在拖拽
            let conditionValue = -(contentInsetTop + LBRefreshControlH);
            if contentOffsetY > conditionValue {
                //控件没有被完全拖拽出来
                if lb_state == .Pulling {
                    // 更改当前状态为默认状态，提示下拉刷新
                    lb_state = .Normal;
                }
            }else{
                //控件已经完全下拉出来
                if lb_state == .Normal {
                    //显示下拉状态，提示释放更新
                    lb_state = .Pulling;
                }
            }
        }else{
            //手已经松开
            // 判断当前控件是否完全显示出来(当前状态是否是`松手就可以刷新的状态`)
            //如果Pulling状态说明已经完全下拉出来，否则只可能是Normal状态
            if lb_state == .Pulling {
                lb_state = .Refreshing;
            }
        }
    }
    //结束刷新
    func endRefreshing(){
        //状态设置为默认
        lb_state = .Normal;
    }
    
//MARK:- 懒加载子控件
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "tableview_pull_refresh"));
    private lazy var messageLabel: UILabel = {
        let message = UILabel(textColor: UIColor.grayColor(), fontSize: 12);
        message.text = "下拉加载更多";
        return message;
    }();
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray);
        return indicatorView;
    }();
    
}

/**
 设置label
 textColor: 文字颜色
 fontSize: 文字尺寸
 */
extension UILabel {
    convenience init(textColor: UIColor, fontSize: CGFloat) {
        self.init();
        self.font = UIFont.systemFontOfSize(fontSize);
        self.textColor = textColor;
        
    }
    
    
}


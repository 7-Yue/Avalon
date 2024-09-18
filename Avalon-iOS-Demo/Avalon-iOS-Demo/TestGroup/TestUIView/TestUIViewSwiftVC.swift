import UIKit
import SnapKit
import AvalonFramework

// 这里可以让NSClassFromString，可以通过TestUIViewVC获取到class
@objc(TestUIViewSwiftVC)
class TestUIViewSwiftVC: UIViewController {
    
    private lazy var scrollView = { () -> UIScrollView in
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private lazy var v1: UIView = {
        let v1 = UIView()
        return v1
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.scrollView)
        }
        
    }
    
}

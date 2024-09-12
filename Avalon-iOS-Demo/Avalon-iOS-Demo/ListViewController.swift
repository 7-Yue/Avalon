import UIKit
import AvalonFramework
import ObjectiveC.runtime
import SnapKit

class ListViewController: UIViewController {
    
    init(item: FileItem) {
        self.dataList = item.contents?.filter({ $0.name.contains("Test")}) ?? [FileItem]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dataList: [FileItem]
    
    private lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(reflecting: UITableViewCell.self))
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view .addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView.reloadData()
    }

}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let i = self.dataList[indexPath.row]
        if i.type == .directory {
            let vc = ListViewController(item: i)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.dataList[indexPath.row].type == .file {
            let vcName = self.dataList[indexPath.row].name.replacingOccurrences(of: ".swift", with: "")
            let name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
//            let wholeName = "\(name).\(vcName)"
//            let other = wholeName.replacingOccurrences(of: "-", with: "_")
//            let cls1: AnyClass? = NSClassFromString("\(vcName)")
            let cls: AnyClass? = NSClassFromString("\(vcName)")
            guard let viewControllerClass = cls as? UIViewController.Type else {
                return
            }
            let vc = viewControllerClass.init() as UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(reflecting: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "\(self.dataList[indexPath.row].name)"
        return cell
    }
}

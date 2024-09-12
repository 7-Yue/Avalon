import UIKit
import AvalonFramework
import ObjectiveC.runtime
import SnapKit

struct FileItem: Codable {
    enum FileType: String, Codable {
        case file = "file"
        case directory = "directory"
        case unknown
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = FileType(rawValue: rawValue) ?? .unknown
        }
    }
    let name: String
    let type: FileType
    let contents: [FileItem]?
}

class RootViewController: UIViewController {
    
    private lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(reflecting: UITableViewCell.self))
        return tableView
    }()
    
    private lazy var dataList = [FileItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view .addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView.reloadData()
        
        if let jsonPath = Bundle.main.path(forResource: "TestGroup", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                let testGroup = try JSONDecoder().decode(FileItem.self, from: jsonData)
                self.dataList = testGroup.contents?.filter({ $0.type == .directory }) ?? [FileItem]()
                self.tableView.reloadData()
            } catch {
                print("解析 JSON 文件失败: \(error)")
            }
        } else {
            print("未找到 TestGroup.json 文件")
        }
    }

}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let i = self.dataList[indexPath.row]
        if (i.type == .directory) {
            let vc = ListViewController(item: i)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(reflecting: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "\(self.dataList[indexPath.row].name)"
        return cell
    }
}
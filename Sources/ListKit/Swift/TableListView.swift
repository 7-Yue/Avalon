import UIKit

fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        get {
            guard index >= 0 && index < count else {
                return nil
            }
            return self[index]
        }
        set {
            guard index >= 0 && index < count else { return }
            self[index] = newValue!
        }
    }
}

private class TableListViewProxyItem: NSObject {
    weak private(set) var internalTarget: NSObjectProtocol?
    weak private(set) var externalTarget: NSObjectProtocol?
    
    init(internalTarget: NSObjectProtocol? = nil,
         externalTarget: NSObjectProtocol? = nil) {
        self.internalTarget = internalTarget
        self.externalTarget = externalTarget
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let internalTarget = internalTarget, internalTarget.responds(to: aSelector) {
            return internalTarget
        } else if let externalTarget = externalTarget, externalTarget.responds(to: aSelector) {
            return externalTarget
        }
        return nil
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        guard let internalTarget = internalTarget,
              let externalTarget = externalTarget else { return false }
        return internalTarget.responds(to: aSelector) ||
        externalTarget.responds(to: aSelector)
    }
    
}

private class CustomTableView: UITableView {
    override var delegate: (any UITableViewDelegate)? {
        willSet {
            if newValue != nil {
                assert(newValue is TableListViewProxyItem, "不要替换delegate")
            }
        }
    }
    
    override var dataSource: (any UITableViewDataSource)? {
        willSet {
            if newValue != nil {
                assert(newValue is TableListViewProxyItem, "不要替换dataSource")
            }
        }
    }
}

public class TableListView: UIView {
    private(set) var tableView: UITableView!
    private(set) var data: TableListDataProtocol?
    
    private var proxy: TableListViewProxyItem!
    private var registerCellList = [UITableViewCell.Type]()
    private var registerHeaderViewList = [UITableViewHeaderFooterView.Type]()
    private var registerFooterViewList = [UITableViewHeaderFooterView.Type]()
    
    
    public init(frame: CGRect,
                style: UITableView.Style = .plain,
                tableViewProxy: NSObjectProtocol) {
        super.init(frame: frame)
        
        proxy = TableListViewProxyItem(internalTarget: self,
                                       externalTarget: tableViewProxy)
        tableView = { () -> CustomTableView in
            let tableView = CustomTableView(frame: frame, style: style)
            
            let pointer = UnsafeMutableRawPointer(mutating: Unmanaged.passUnretained(proxy).toOpaque())
            withUnsafeMutablePointer(to: &tableView.delegate) { delegatePointer in
                delegatePointer.pointee = unsafeBitCast(pointer, to: UITableViewDelegate?.self)
            }
            withUnsafeMutablePointer(to: &tableView.dataSource) { delegatePointer in
                delegatePointer.pointee = unsafeBitCast(pointer, to: UITableViewDataSource?.self)
            }
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            if #available(iOS 15.0, *) {
                tableView.sectionHeaderTopPadding = 0;
            }
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .never;
            } else {
                tableView.contentInset = .zero;
            }
            
            return tableView
        }()
        
        addSubview(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds;
    }
    
    
}

extension TableListView {
    public func bindWithData(data: TableListDataProtocol?) {
        self.data = data
        tableView.reloadData()
    }
}

extension TableListView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return data?.sections?[safe: section]?.rows?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = data?.sections?[safe: indexPath.section]?.rows?[safe: indexPath.row]
        guard let rowData = rowData else {
            return UITableViewCell()
        }
        let cellType = rowData.cellType
        if !registerCellList.contains(where: { $0 == cellType }) {
            tableView.register(cellType, forCellReuseIdentifier: String(reflecting: cellType))
            registerCellList.append(cellType)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(reflecting: cellType),
                                                 for: indexPath)
        if let cell = cell as? TableListCellProtocol {
            cell.config(rowData: rowData, indexPath: indexPath)
        }
        return cell
    }
}

extension TableListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionData = data?.sections?[safe: section] else {
            return nil
        }
        guard let relatedHeader = sectionData.relatedHeader else {
            return nil
        }
        if !registerHeaderViewList.contains(where: { $0 == relatedHeader }) {
            tableView.register(relatedHeader,
                               forHeaderFooterViewReuseIdentifier: String(reflecting: relatedHeader))
            registerHeaderViewList.append(relatedHeader)
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(reflecting: relatedHeader))
        if let header = header as? TableListSupplementaryViewProtocol {
            header.config(sectionData: sectionData, section: section)
        }
        return header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionData = data?.sections?[safe: section] else {
            return nil
        }
        guard let relatedFooter = sectionData.relatedFooter else {
            return nil
        }
        if !registerFooterViewList.contains(where: { $0 == relatedFooter }) {
            tableView.register(relatedFooter,
                               forHeaderFooterViewReuseIdentifier: String(reflecting: relatedFooter))
            registerFooterViewList.append(relatedFooter)
        }
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(reflecting: relatedFooter))
        if let footer = footer as? TableListSupplementaryViewProtocol {
            footer.config(sectionData: sectionData, section: section)
        }
        return footer
    }
    
    public func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {
        if let cell = cell as? TableListCellProtocol {
            cell.cellWillDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          willDisplayHeaderView view: UIView,
                          forSection section: Int) {
        if let view = view as? TableListSupplementaryViewProtocol {
            view.viewWillDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          willDisplayFooterView view: UIView,
                          forSection section: Int) {
        if let view = view as? TableListSupplementaryViewProtocol {
            view.viewWillDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          didEndDisplaying cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {
        if let cell = cell as? TableListCellProtocol {
            cell.cellEndDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          didEndDisplayingFooterView view: UIView,
                          forSection section: Int) {
        if let view = view as? TableListSupplementaryViewProtocol {
            view.viewEndDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          didEndDisplayingHeaderView view: UIView,
                          forSection section: Int) {
        if let view = view as? TableListSupplementaryViewProtocol {
            view.viewEndDisplay()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let rowData = data?.sections?[safe: indexPath.section]?.rows?[safe: indexPath.row] {
            return rowData.cellHeight
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionData = data?.sections?[safe: section] {
            return sectionData.headerHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
        if let sectionData = data?.sections?[safe: section] {
            return sectionData.footerHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
}



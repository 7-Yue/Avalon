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

private class CollectionListViewProxyItem: NSObject {
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
        let x = internalTarget.responds(to: aSelector) ||
        externalTarget.responds(to: aSelector)
        return x
    }
    
}

private class CustomCollectionView: UICollectionView {
    override var delegate: (any UICollectionViewDelegate)? {
        willSet {
            if newValue != nil {
                assert(newValue is CollectionListViewProxyItem, "不要替换delegate")
            }
        }
    }
    
    override var dataSource: (any UICollectionViewDataSource)? {
        willSet {
            if newValue != nil {
                assert(newValue is CollectionListViewProxyItem, "不要替换dataSource")
            }
        }
    }
}

public class CollectionListView: UIView {
    private(set) var collectionView: UICollectionView!
    private(set) var data: CollectionListDataProtocol?
    
    private var proxy: CollectionListViewProxyItem!
    private var registerCellList = [UICollectionViewCell.Type]()
    private var registerHeaderViewList = [UICollectionReusableView.Type]()
    private var registerFooterViewList = [UICollectionReusableView.Type]()
    
    public init(frame: CGRect,
                scrollDirection: UICollectionView.ScrollDirection = .vertical,
                collectionViewProxy: NSObjectProtocol) {
        super.init(frame: frame)
        
        proxy = CollectionListViewProxyItem(internalTarget: self,
                                            externalTarget: collectionViewProxy)
        collectionView = { () -> UICollectionView in
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = scrollDirection
            layout.estimatedItemSize = .zero
            let collectionView = UICollectionView(frame: frame,
                                                  collectionViewLayout: layout)
            let pointer = UnsafeMutableRawPointer(mutating: Unmanaged.passUnretained(proxy).toOpaque())
            withUnsafeMutablePointer(to: &collectionView.delegate) { delegatePointer in
                delegatePointer.pointee = unsafeBitCast(pointer, to: UICollectionViewDelegate?.self)
            }
            withUnsafeMutablePointer(to: &collectionView.dataSource) { delegatePointer in
                delegatePointer.pointee = unsafeBitCast(pointer, to: UICollectionViewDataSource?.self)
            }
            
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never;
            } else {
                collectionView.contentInset = .zero;
            }
            
            return collectionView;
        }()
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds;
    }
}

extension CollectionListView {
    public func bindWithData(data: CollectionListDataProtocol?) {
        self.data = data
        collectionView.reloadData()
    }
}

extension CollectionListView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.data?.sections?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return data?.sections?[safe: section]?.rows?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rowData = data?.sections?[safe: indexPath.section]?.rows?[safe: indexPath.row]
        guard let rowData = rowData else {
            return UICollectionViewCell()
        }
        let cellType = rowData.cellType
        if !registerCellList.contains(where: { $0 == cellType }) {
            collectionView.register(cellType,
                                    forCellWithReuseIdentifier: String(reflecting: cellType))
            registerCellList.append(cellType)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(reflecting: cellType),
                                                      for: indexPath)
        if let cell = cell as? CollectionListCellProtocol {
            cell.config(rowData: rowData, indexPath: indexPath)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            var type: UICollectionReusableView.Type
            if let sectionData = data?.sections?[safe:indexPath.section],
                  let relatedHeader = sectionData.relatedHeader {
                type = relatedHeader
            } else {
                type = UICollectionReusableView.self
            }
            if !registerHeaderViewList.contains(where: { $0 == type }) {
                collectionView.register(type,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                        withReuseIdentifier: String(reflecting: type))
                registerHeaderViewList.append(type)
            }
            let header =
            collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                            withReuseIdentifier: String(reflecting: type),
                                                            for: indexPath)
            if let header = header as? CollectionListSupplementaryViewProtocol,
                let data = data?.sections?[safe:indexPath.section] {
                header.config(sectionData: data, section: indexPath.section)
            }
            return header
        } else  if (kind == UICollectionView.elementKindSectionFooter) {
            var type: UICollectionReusableView.Type
            if let sectionData = data?.sections?[safe:indexPath.section],
               let relatedFooter = sectionData.relatedFooter {
                type = relatedFooter
            } else {
                type = UICollectionReusableView.self
            }
            if !registerFooterViewList.contains(where: { $0 == type }) {
                collectionView.register(type,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                        withReuseIdentifier: String(reflecting: type))
                registerFooterViewList.append(type)
            }
            let footer =
            collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                            withReuseIdentifier: String(reflecting: type),
                                                            for: indexPath)
            if let footer = footer as? CollectionListSupplementaryViewProtocol,
                let data = data?.sections?[safe:indexPath.section] {
                footer.config(sectionData: data, section: indexPath.section)
            }
            return footer
        } else {
            assert(false, "不支持footer和header以外的视图")
            return UICollectionReusableView()
        }
    }
}

extension CollectionListView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let rowData = data?.sections?[safe:indexPath.section]?.rows?[safe:indexPath.row] {
            return rowData.cellSize?(collectionView.bounds.size) ?? .zero
        } else {
            return .zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return data?.sections?[safe:section]?.inset ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return data?.sections?[safe: section]?.minimumLineSpacing ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return data?.sections?[safe: section]?.minimumInteritemSpacing ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        return data?.sections?[safe: section]?.headerSize ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        return data?.sections?[safe: section]?.footerSize ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionListCellProtocol else {
            return
        }
        cell.cellWillDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplaySupplementaryView view: UICollectionReusableView,
                               forElementKind elementKind: String,
                               at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard let header = view as? CollectionListSupplementaryViewProtocol else {
                return
            }
            header.viewWillDisplay()
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            guard let footer = view as? CollectionListSupplementaryViewProtocol else {
                return
            }
            footer.viewWillDisplay()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionListCellProtocol else {
            return
        }
        cell.cellEndDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplayingSupplementaryView view: UICollectionReusableView,
                               forElementOfKind elementKind: String,
                               at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard let header = view as? CollectionListSupplementaryViewProtocol else {
                return
            }
            header.viewEndDisplay()
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            guard let footer = view as? CollectionListSupplementaryViewProtocol else {
                return
            }
            footer.viewEndDisplay()
        }
    }
}




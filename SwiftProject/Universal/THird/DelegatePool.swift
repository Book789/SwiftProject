//
//  DelegatePool.swift
//  SwiftProject
//
//

// 弱引用包装器：不持有对象，自动释放
final class WeakWrapper<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

// 多代理管理类（自动清理已释放的代理）
final class DelegatePool<T: AnyObject> {
    // 存弱引用，不会强持有
    private var wrappers: [WeakWrapper<T>] = []
    
    // 添加代理
    func addDelegate(_ delegate: T) {
        // 先清理已释放的
        clearReleasedDelegates()
        // 避免重复添加
        guard !wrappers.contains(where: { $0.value === delegate }) else { return }
        wrappers.append(WeakWrapper(value: delegate))
    }
    
    // 移除代理
    func removeDelegate(_ delegate: T) {
        wrappers.removeAll { $0.value === delegate }
    }
    
    // 遍历所有活着的代理（自动过滤已释放的）
    func invoke(_ action: (T) -> Void) {
        clearReleasedDelegates()
        wrappers.forEach {
            if let delegate = $0.value {
                action(delegate)
            }
        }
    }
    
    // 自动清理：移除已经释放的对象
    private func clearReleasedDelegates() {
        wrappers.removeAll { $0.value == nil }
    }
    
    // 当前活着的代理数量
    var count: Int {
        clearReleasedDelegates()
        return wrappers.count
    }
}

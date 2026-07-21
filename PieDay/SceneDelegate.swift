import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let transactions = TransactionViewController()
        transactions.tabBarItem = UITabBarItem(title: "交易", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)
        let dashboard = ViewController()
        dashboard.tabBarItem = UITabBarItem(title: "總覽", image: UIImage(systemName: "chart.donut"), tag: 1)

        let tabs = UITabBarController()
        tabs.viewControllers = [
            UINavigationController(rootViewController: transactions),
            UINavigationController(rootViewController: dashboard)
        ]
        tabs.tabBar.tintColor = .systemIndigo
        // 財務 App 啟動時先回答「這個月狀況如何」，再讓使用者進入交易明細。
        // 主動載入可避免 UITabBarController 的 lazy loading 讓總覽首次顯示延後。
        dashboard.loadViewIfNeeded()
        tabs.selectedIndex = 1

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
    }
}

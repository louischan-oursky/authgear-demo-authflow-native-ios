import UIKit
import Authgear

class ThirdScreen: UIViewController {

    let userInfo: UserInfo
    var userInfoTextView = UITextView()

    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hue: 50.0/360.0, saturation: 0.99, brightness: 0.67, alpha: 1.0)
        self.navigationItem.title = "UserInfoScreen"

        let json = [
            "sub": self.userInfo.sub,
            "phone_number": self.userInfo.phoneNumber!
        ]

        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let str = String.init(data: data, encoding: .utf8)

        self.view.addSubview(self.userInfoTextView)

        self.userInfoTextView.translatesAutoresizingMaskIntoConstraints = false
        self.userInfoTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.userInfoTextView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.userInfoTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.userInfoTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.userInfoTextView.text = str
    }
}

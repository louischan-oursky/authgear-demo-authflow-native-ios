import UIKit
import Authgear

class SecondScreen: UIViewController {

    let authRequest: AuthgearExperimental.AuthenticationRequest
    let stateToken: String
    let phoneNumber: String

    var stackView = UIStackView()
    var otpLabel = UILabel()
    var otpField = UITextField()

    init(authRequest: AuthgearExperimental.AuthenticationRequest, stateToken: String, phoneNumber: String) {
        self.authRequest = authRequest
        self.stateToken = stateToken
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(hue: 50.0/360.0, saturation: 0.99, brightness: 0.67, alpha: 1.0)

        self.view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.otpLabel)
        self.stackView.addArrangedSubview(self.otpField)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.otpLabel.translatesAutoresizingMaskIntoConstraints = false
        self.otpField.translatesAutoresizingMaskIntoConstraints = false

        self.navigationItem.title = "OTPScreen"

        self.stackView.axis = .vertical
        self.stackView.spacing = 16.0
        self.stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.stackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true

        self.otpLabel.text = "OTP"

        self.otpField.placeholder = "Enter the OTP"
        self.otpField.borderStyle = .line
        self.otpField.backgroundColor = UIColor.white
        self.otpField.keyboardType = .phonePad
        self.otpField.returnKeyType = .continue
        self.otpField.addTarget(self, action: #selector(onReturn), for: .editingDidEndOnExit)
    }

    @objc func onReturn() {
        Task {
            self.setLoading(true)
            defer { self.setLoading(false) }

            do {
                let code = self.otpField.text ?? ""

                let session = URLSession(configuration: .ephemeral)
                let authgearResponse = try await inputAuthflow(session: session, stateToken: self.stateToken, input: [
                    "code": code
                ])
                print("authgearResponse: \(authgearResponse)")

                let data = authgearResponse.result?.action.data.value as! [String: Any]
                let finishRedirectURIString = data["finish_redirect_uri"] as! String
                let finishRedirectURI = URL(string: finishRedirectURIString)!
                let redirectURI = try await extractRedirectURI(session: session, url: finishRedirectURI)

                UIApplication.shared.authgear.experimental.finishAuthentication(finishURL: redirectURI, request: self.authRequest) { result in
                    switch result {
                    case .success(let userInfo):
                        DispatchQueue.main.async {
                            print("access token \(UIApplication.shared.authgear.accessToken!)")
                            let vc = ThirdScreen(userInfo: userInfo)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    case .failure(let error):
                        print("error \(error)")
                    }
                }
            } catch {
                print("error: \(error)")
            }
        }
    }

    func setLoading(_ loading: Bool) {
        if loading {
            self.otpField.isEnabled = false
            self.otpField.backgroundColor = UIColor.gray
        } else {
            self.otpField.isEnabled = true
            self.otpField.backgroundColor = UIColor.white
        }
    }
}

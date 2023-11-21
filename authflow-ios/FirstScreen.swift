import UIKit

class FirstScreen: UIViewController {

    var stackView = UIStackView()
    var phoneLabel = UILabel()
    var phoneField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(hue: 50.0/360.0, saturation: 0.99, brightness: 0.67, alpha: 1.0)

        self.view.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.phoneLabel)
        self.stackView.addArrangedSubview(self.phoneField)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        self.phoneField.translatesAutoresizingMaskIntoConstraints = false

        self.navigationItem.title = "PhoneNumberScreen"

        self.stackView.axis = .vertical
        self.stackView.spacing = 16.0
        self.stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        self.stackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true

        self.phoneLabel.text = "Phone Number"

        self.phoneField.placeholder = "Enter your phone number"
        self.phoneField.borderStyle = .line
        self.phoneField.backgroundColor = UIColor.white
        self.phoneField.keyboardType = .phonePad
        self.phoneField.returnKeyType = .continue
        self.phoneField.addTarget(self, action: #selector(onReturn), for: .editingDidEndOnExit)
    }

    @objc func onReturn() {
        Task {
            do {
                let phoneNumber = self.phoneField.text ?? ""

                let (authRequest, query) = try await QueryPreparer().prepareQuery()
                print("query: \(query)")
                let session = URLSession(configuration: .ephemeral)
                var authgearResponse = try await createAuthflow(session: session, query: query)
                print("authgearResponse: \(authgearResponse)")
                authgearResponse = try await inputAuthflow(session: session, stateToken: authgearResponse.result!.stateToken, input: [
                    "identification": "phone",
                    "login_id": phoneNumber,
                    "authentication": "primary_oob_otp_sms",
                    "index": 0,
                    "channel": "sms"
                ])
                print("authgearResponse: \(authgearResponse)")

                await MainActor.run {
                    let vc = SecondScreen(authRequest: authRequest, stateToken: authgearResponse.result!.stateToken ,phoneNumber: phoneNumber)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print("error: \(error)")
            }
        }
    }

    func setLoading(_ loading: Bool) {
        if loading {
            self.phoneField.isEnabled = false
            self.phoneField.backgroundColor = UIColor.gray
        } else {
            self.phoneField.isEnabled = true
            self.phoneField.backgroundColor = UIColor.white
        }
    }
}

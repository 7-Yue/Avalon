import Foundation
import WebKit
import AvalonFramework

class TestWKWebViewSwiftVC1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
    }
}

@objc(TestWKWebViewSwiftVC)
class TestWKWebViewSwiftVC: UIViewController {

    private lazy var webView = { () -> WKWebView in
        let webViewConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "logHandler")
        webViewConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        let script = """
        (function() {
            var oldLog = console.log;
            console.log = function(message) {
                oldLog(message);
                window.webkit.messageHandlers.logHandler.postMessage(message);
            };
        })();
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false))

        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>WKWebView Test</title>
        </head>
        <body>
            <h1>Testing JavaScript in WKWebView</h1>
            <script>
                setInterval(function() {
                    console.log("1");
                }, 3000);
            </script>
            <script>
                function logEverySecond() {
                    console.log("2");
                    setTimeout(logEverySecond, 1000);
                }

                
                logEverySecond();
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        return webView
    }()

    private lazy var button = { () -> UIButton in
        let button = UIButton(frame: .zero)
        button.setTitle("push", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        view.addSubview(webView)

        view.addSubview(button)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.center = webView.center
    }

    @objc private func pushAction() {
        navigationController?.pushViewController(TestWKWebViewSwiftVC1(), animated: true)
    }
}

extension TestWKWebViewSwiftVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler", let log = message.body as? String {
            print("JavaScript log: \(log)")
        }
    }
}



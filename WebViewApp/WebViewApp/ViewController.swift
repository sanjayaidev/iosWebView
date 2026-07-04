import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure content controller with message handler
        let contentController = WKUserContentController()
        contentController.add(self, name: "nativeHandler")
        
        // Configure web view
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        // Load HTML content
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WebView Demo</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    padding: 20px;
                    text-align: center;
                }
                button {
                    padding: 15px 30px;
                    font-size: 16px;
                    margin: 10px;
                    background-color: #007AFF;
                    color: white;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                }
                button:active {
                    opacity: 0.7;
                }
                #result {
                    margin-top: 20px;
                    padding: 15px;
                    background-color: #f0f0f0;
                    border-radius: 8px;
                }
            </style>
        </head>
        <body>
            <h1>WKWebView Demo</h1>
            <p>Interact with native iOS code from JavaScript</p>
            <button onclick="callNative()">Call Native Function</button>
            <button onclick="evaluateJS()">Evaluate JavaScript</button>
            <div id="result">Result will appear here</div>
            
            <script>
                function callNative() {
                    window.webkit.messageHandlers.nativeHandler.postMessage({
                        action: 'buttonClicked',
                        timestamp: new Date().toISOString()
                    });
                }
                
                function evaluateJS() {
                    window.webkit.messageHandlers.nativeHandler.postMessage({
                        action: 'getDeviceInfo'
                    });
                }
                
                function updateResult(message) {
                    document.getElementById('result').innerText = message;
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // Handle messages from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            return
        }
        
        switch action {
        case "buttonClicked":
            let timestamp = body["timestamp"] as? String ?? "unknown"
            showAlert(title: "JavaScript Message", message: "Button clicked at \(timestamp)")
            
            // Call back to JavaScript
            let js = "updateResult('Native received message at \(timestamp)')"
            webView.evaluateJavaScript(js, completionHandler: nil)
            
        case "getDeviceInfo":
            let deviceInfo = "Device: UIDevice.current.model\nSystem: \(UIDevice.current.systemVersion)"
            let js = "updateResult('\(deviceInfo)')"
            webView.evaluateJavaScript(js, completionHandler: nil)
            
        default:
            break
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web view finished loading")
    }
}

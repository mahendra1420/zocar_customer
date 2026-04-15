import UIKit
import Flutter
import GoogleMaps
import Siren

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    configureSiren()

    GMSServices.provideAPIKey("AIzaSyCeTS8oOJapyx6s8hKT-MWgT2sQORTuiAI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func configureSiren() {
      let siren = Siren.shared
      let rules = Rules(promptFrequency: .immediately, forAlertType: .force)
      siren.rulesManager = RulesManager(globalRules: rules)
      print("SIREN VERSION CHECKED...")
      siren.wail() // Start checking for updates
  }

}

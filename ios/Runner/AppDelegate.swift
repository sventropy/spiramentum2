import UIKit
import Flutter
import HealthKit
import UserNotificationsUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var healthStore: HKHealthStore?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let flutterViewController = self.window.rootViewController as! FlutterViewController
        let storeMindfulMinutesChannel = FlutterMethodChannel(name: "de.sventropy/mindfulness-minutes", binaryMessenger: flutterViewController.binaryMessenger)
        let showNotificationChannel = FlutterMethodChannel(name: "de.sventropy/notification-service", binaryMessenger: flutterViewController.binaryMessenger)
        self.ensureHealthKitAuthorization()
        self.ensureNotificationAuthorization()
        
        storeMindfulMinutesChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            print("Called storeMindfulMinutes channel")
            guard call.method == "storeMindfulMinutes" else {
                result(FlutterMethodNotImplemented)
                return
            }
            print("Method signature matches")
            let minutes = call.arguments as! Int32
            print("Parameter matches")
            self.storeMindfulMinutes(minutes: minutes, result: result)
        }
        
        showNotificationChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            print("Called showNotification channel")
            guard call.method == "showNotification" else {
                result(FlutterMethodNotImplemented)
                return
            }
            print("Method signature matches")
            let args = call.arguments as! Array<Any>
            let title = args[0] as! String
            let message = args[1] as! String
            print("Parameters match")
            self.sendNotification(title: title, message: message, result: result)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func ensureHealthKitAuthorization() {
        
        // Check HK availability
        if !HKHealthStore.isHealthDataAvailable() {
            return
        }
        
        // Initialize HK wrapper
        healthStore = HKHealthStore()
        // Request proper permissions for HK data access
        let allTypes = Set([HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
        healthStore!.requestAuthorization(toShare: allTypes, read: nil) { (success, error) in
            if !success {
                print("HealthKit authorization not granted. Error: \(String(describing: error))")
            }
        }
    }
    
    func storeMindfulMinutes(minutes: Int32, result: @escaping FlutterResult) {
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .minute, value: Int(minutes * -1), to: endDate)!
        let mindfulSessionTime = HKCategorySample(type: HKObjectType.categoryType(forIdentifier: .mindfulSession)! , value: HKCategoryValue.notApplicable.rawValue, start: startDate , end: endDate)
        print("Storing mindful session time: '\(minutes)' minutes")
        
        self.healthStore!.save(mindfulSessionTime, withCompletion: { (success, error) in
            if !success {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Error storing mindfulness time",
                                    details: "\(String(describing: error?.localizedDescription))"))
            } else {
                result(true)
            }
        })
    }
    
    func ensureNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [[.alert, .sound, .badge]],
            completionHandler: {
                (granted, error) in
                if !granted {
                    print("NotificationCenter authorization not granted. Error: \(String(describing: error))")
                } else {
                    UNUserNotificationCenter.current().delegate = self
                }
        })
    }
    
    func sendNotification(title: String, message: String, result: @escaping FlutterResult) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                        repeats: false)
        
        let requestIdentifier = "de.sventropy.spiramentum2.notification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(
            request,
            withCompletionHandler: { (error) in
                if error != nil {
                    result(FlutterError(code: "ERROR",
                                    message: "UserNotificationCenter add error",
                                    details: "\(String(describing: error?.localizedDescription))"))
                } else {
                    result(true)
                }
        })
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var healthStore: HKHealthStore?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.ensureHealthKitAuthorization()
        print("ensured")
        
        let flutterViewController = self.window.rootViewController as! FlutterViewController
        let storeMindfulMinutesChannel = FlutterMethodChannel(name: "de.sventropy/mindfulness-minutes", binaryMessenger: flutterViewController.binaryMessenger)
        
        storeMindfulMinutesChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            guard call.method == "storeMindfulMinutes" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            let minutes = call.arguments as! Int32
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .minute, value: Int(minutes * -1), to: endDate)!
            
            let mindfulSessionTime = HKCategorySample(type: HKObjectType.categoryType(forIdentifier: .mindfulSession)! , value: HKCategoryValue.notApplicable.rawValue, start: startDate , end: endDate)
            print("Storing mindful session time: '\(minutes)' minutes")
            self.healthStore!.save(mindfulSessionTime, withCompletion: { (success, error) in
                if !success {
                    print("Error storing mindful session time: \(String(describing: error))")
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "Error storing mindfulness time",
                                        details: "\(error!.localizedDescription)"))
                }
            })
            
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
        healthStore?.requestAuthorization(toShare: allTypes, read: nil) { (success, error) in
            if !success {
                // Handle the error here.
                print("HealthKit Auth error \(String(describing: error))")
            }
        }
        
    }
    
}

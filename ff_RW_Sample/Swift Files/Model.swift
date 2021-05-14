//
//  Model.swift
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/7/21.
//

import Foundation

let EX_REPORT = "report"
let EX_CONDITIONS = "conditions"
let EX_FORECAST = "forecast"
let EX_PERIOD = "period"
let EX_FORECASTTEXT = "text"
let EX_FORECASTISSUEDDATE = "dateIssued"
let EX_FORECASTSTARTDATE = "dateStart"
let EX_FORECASTENDDATE = "dateEnd"

@objc enum SessionAction : Int {
    case sessionSuccess
    case sessionNoOp
    case sessionPlaceNotFound
    case sessionTimedOut
    case sessionDataFailure
}

enum Coverage : String {
    case ovc = "ovc"
    case bkn = "bkn"
    case sct = "sct"
    case few = "few"
}

struct CloudLayer {
    var altitudeFt : Double?
    var ceiling : Bool?
    var coverage : String?
}

struct Visibility {
    var distanceSm : Double?
    var prevailingVisSm : Double?
    var distanceQualifier : Int?
    var prevailingVisDistanceQualifier : Int?
}

struct Weather {
    var description : String?
}

struct Wind {
    var direction : Int?
    var from : Int?
    var speedKts : Double?
    var gustSpeedKts : Double?
    var variable : Bool?
}

struct Period {
    var dateEnd : String?
    var dateStart : String?
}

struct Conditions {
    
    var ident : String
    var text : String?
    var dateIssued : String?
    
    var densityAltitudeFt : Int?
    var dewpointC : Double?
    var elevationFt : Int?
    var flightRules : String?
    
    var lat : Double
    var lon : Double
    var pressureHg : Double?
    var relativeHumidity : Double?
    var tempC : Double?
    
    var cloudlayer1 : [CloudLayer?]
    var cloudLayer2 : [CloudLayer?]
    
    var visibility : Visibility?
    
    var weather : [String?]
    
    var wind : Wind?
    
}

class excerciseModel : NSObject{
    
    class func resolveModelCurrent(_ cache : Dictionary <String, Any>) -> [Conditions?]?{
        
        let topDictionary = cache
        //print("model place", topDictionary)
        
        guard let reportOut = topDictionary[EX_REPORT] as? [String : Any] else{
            return nil
        }
        
        guard let currentCondition = reportOut[EX_CONDITIONS] as? [String : Any] else{
            return nil
        }
        
        return [processCondition(currentCondition, isForecast: false)]
       
    }
    
    class func resolveModelForecast(_ cache: Dictionary <String, Any>) -> [Conditions?]?{
        
        let topDictionary = cache
        //print("model place forecast", topDictionary)
        
        guard let reportOut = topDictionary[EX_REPORT] as? [String : Any] else{
            return nil
        }
        
        guard let forecastOut = reportOut[EX_FORECAST] as? [String : Any] else{
            return nil
        }
        
        guard let conditionsOut = forecastOut[EX_CONDITIONS] as? [[String : Any]] else{
            return nil
        }
        
        var forecastConditions : [Conditions?] = []
        for elem in conditionsOut{
            guard let conditionResult = processCondition(elem, isForecast: true) else{
                continue
            }
            forecastConditions.append(conditionResult)
        }
        
        guard forecastConditions.count > 0 else{
            return nil
        }
        return forecastConditions
    }
    
    class func resolveModelForecastPrelim(_ cache: Dictionary <String, Any>) -> [String]?{
        
        let topDictionary = cache
        //print("model place forecast", topDictionary)
        
        guard let reportOut = topDictionary[EX_REPORT] as? [String : Any] else{
            return nil
        }
        
        guard let forecastOut = reportOut[EX_FORECAST] as? [String : Any] else{
            return nil
        }
        
        
        guard let periodOut = forecastOut[EX_PERIOD] as? [String : Any] else{
            return nil
        }
        
        let forecastText = forecastOut[EX_FORECASTTEXT] as? String
        let forecastIssued = forecastOut[EX_FORECASTISSUEDDATE] as? String
        let forecastStart = periodOut[EX_FORECASTSTARTDATE] as? String
        let forecastEnd = periodOut[EX_FORECASTENDDATE] as? String
        
        var resultArray : [String] = []
        if let va1 = forecastText{
            resultArray.append(va1)
        }
        if let va2 = forecastIssued{
            resultArray.append(va2)
        }
        if let va3 = forecastStart{
            resultArray.append(va3)
        }
        if let va4 = forecastEnd{
            resultArray.append(va4)
        }
       
        return resultArray
    }
    
    class func processCondition(_ condition : [String : Any], isForecast: Bool) -> Conditions?{
        //print("THE CONDITON", condition)
        
        let identValue : String? = condition["ident"] as? String
        
        let ident : String = identValue != nil ? identValue! : "Kwho"
        
        guard let lat = condition["lat"] as! Double? else {
            return nil
        }
        guard let lon = condition["lon"] as! Double? else {
            return nil
        }
        
        var clay1Array : [CloudLayer?] = []
        var clay2Array : [CloudLayer?] = []
        
        if let firstArray = condition["cloudLayers"]{
            
            let arr = firstArray as! [[String : Any]]
            
            for elem in arr{
                let dict = elem as [String: Any]
                
                let alt1 : Double? = dict["altitudeFt"] as? Double ?? nil
                let ceil1 : Bool? = dict["ceiling"] as? Bool ?? nil
                let cover1 : String? = dict["coverage"] as? String? ?? nil
                
                let clay1 = CloudLayer(altitudeFt: alt1, ceiling: ceil1, coverage: cover1)
                
                clay1Array.append(clay1)
            }
            //print("Clay1", clay1Array)
        }
        
        if let secondArray = condition["cloudLayersV2"]{
            
            let arr = secondArray as! [[String : Any]]
            
            //print("PRINTING 2ND ARRAY", secondArray)
            //print("ARRAY", arr[0])
            
            
            for elem in arr{
                let dict = elem as [String: Any]
                
                let alt1 : Double? = dict["altitudeFt"] as? Double ?? nil
                let ceil1 : Bool? = dict["ceiling"] as? Bool ?? nil
                let cover1 : String? = dict["coverage"] as? String? ?? nil
                
                let clay1 = CloudLayer(altitudeFt: alt1, ceiling: ceil1, coverage: cover1)
                
                clay2Array.append(clay1)
                //print(dict["altitudeFt"] as? Int, dict["ceiling"] as! Int, dict["coverage"] as! String)
            }
            //print("Clay2", clay2Array)
        }
        
        var visible : Visibility?
        if let visibility = condition["visibility"] as! [String: Any]? {
            let distSm = visibility["distanceSm"] as? Double ?? nil
            let distprevail = visibility["prevailingVisSm"] as? Double ?? nil
            let distanceQualifier = visibility["distanceQualifier"] as? Int ?? nil
            let prevailingVisDistanceQualifier = visibility["prevailingVisDistanceQualifier"] as? Int ?? nil
            
            visible = Visibility(distanceSm: distSm, prevailingVisSm: distprevail, distanceQualifier: distanceQualifier, prevailingVisDistanceQualifier: prevailingVisDistanceQualifier)
        }
        
    
        let weatherArray = condition["weather"]
        
        var windy : Wind?
        if let wind = condition["wind"] as! [String: Any]? {
            let direction = wind["direction"] as? Int ?? nil
            let from = wind["from"] as? Int ?? nil
            let speedKts = wind["speedKts"] as? Double ?? nil
            let gustSpeedKts = wind["gustSpeedKts"] as? Double ?? nil
            let variable = wind["variable"] as? Bool ?? nil
        
            windy = Wind(direction: direction, from: from, speedKts: speedKts, gustSpeedKts: gustSpeedKts, variable: variable)
        }
        
        let dateIssued = condition["dateIssued"] as? String
        let densityAltitudeFt = condition["densityAltitudeFt"] as? Int
        let dewpointC = condition["dewpointC"] as? Double
        let elevationFt = condition["elevationFt"] as? Int
        let flightRules = condition["flightRules"] as? String
        
        let pressureHg = condition["pressureHg"] as? Double
        let relativeHumidity = condition["relativeHumidity"] as? Double
        let tempC = condition["tempC"] as? Double
        let text = condition["text"] as? String
        
        
        let conditionOut = Conditions(ident: ident.uppercased(), text: text, dateIssued: dateIssued, densityAltitudeFt: densityAltitudeFt, dewpointC: dewpointC, elevationFt: elevationFt, flightRules: flightRules, lat: lat, lon: lon, pressureHg: pressureHg, relativeHumidity: relativeHumidity, tempC: tempC, cloudlayer1: clay1Array, cloudLayer2: clay2Array, visibility: visible, weather: weatherArray as! [String?], wind: windy)
        
        
        
        
      /*
        var cloudLayerArray : [[String : Any]]?
        
        for elem1 in condition["cloudLayers"] as! [String : Any]{
            
        }
        let cloudLayer1 = CloudLayer(altitudeFt: <#T##Double?#>, ceiling: <#T##Bool?#>, coverage: <#T##String?#>)
        
        
        let cloudLayer2 = CloudLayer(altitudeFt: <#T##Double#>, ceiling: <#T##Bool#>, coverage: <#T##String#>)
        */
        return conditionOut
    }
    
    
    
    func playGround (){
       
        struct Fable : Story{
            var title : String?
            var place: String
            
            
        }
        
        
        
        
        
        let test : String? = "Who"
        
        if let check = test as? Story{
            print("value \(check)")
            
        }
        
        
    }
    
    let wildWest : String = "Hello Wild"
}

protocol Story {
    var place : String { get }
    func origin() -> String
}

extension Story  {
    func origin() -> String {
        return ("I came from \(place)")
    }
}

//
//  File.swift
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/6/21.
//

import Foundation
import UIKit


var stateCache : Conditions!
var stateCacheArray : [Conditions?]!

enum EX_ForeCastPrelim : Int {
    case forecastText
    case forecastIssueDate
    case forecastPeriodStart
    case forecastPeriodEnd
    case forecastMaxPrelimCount
}

@objc protocol FileDelegate {
    @objc func dismissDetail()
    @objc func refreshRequest(_ placeIdent : String) -> Dictionary <String, Any>
    @objc func makeFavorite(_ makeFave : Bool, placeIdent : String)
    @objc func faveStatus(_ placeIdent : String) -> Bool
}
@objcMembers class DetailVC : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @objc var delegate : FileDelegate?
    
    @IBOutlet var header: UIView!
    
    @IBOutlet weak var currentForecastSwitch: UISegmentedControl!
    
    @IBOutlet weak var dateIssued: UILabel!
    @IBOutlet weak var placeText: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    let cellReuseIdentifier = "customCell"
    
    var titleView : UILabel!
    
    var forecastWeather = false
    var restartCache : Dictionary <String, Any>?
    var restartTable = false
    var currentIdentity : String?
    
    @IBOutlet weak var historyNoticeView: UIView!
    @IBOutlet weak var historyNoticePositionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var issuedDate: UILabel!
    @IBOutlet weak var periodStart: UILabel!
    @IBOutlet weak var periodEnd: UILabel!
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var refreshBusyIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favoriteIndicator: UIImageView!
    
    var faveStatus = false
    
    var isHistoryFlag = false
    @IBOutlet weak var scrollFlashers: UIView!
    
    var isAutoRefresh = false
    var timerAutoRefreshTimer : Timer?
    let RefreshTime = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // tableview.register(iconCell.self, forCellReuseIdentifier: cellId)
        //self.placeId.text = stateCache.ident
        //self.placeText.text = stateCache.text
        //self.dateIssued.text = stateCache.dateIssued
        
        establishBaseViews()
        
    }
    
    func establishBaseViews(){
        
        if let stateCacheVal = stateCache {
            
            titleView = UILabel()
            titleView.text = stateCacheVal.ident.uppercased()
            titleView.font = UIFont(name: "Helvetica-Bold", size: 30.0)
            titleView.textColor = .white
            self.navigationItem.titleView = titleView
            self.currentIdentity = stateCacheVal.ident
            
            if let curId = self.currentIdentity{
                favoriteStatusUpdate(curId)
            }
            
            configureForCurrent()
        }
        else{
            self.navigationItem.title = ""
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func configureForCurrent(){
        
        if isHistoryFlag{
            self.currentForecastSwitch.isHidden = true;
            self.historyNoticeView.isHidden = false;
        }
        else{
            self.currentForecastSwitch.isHidden = false;
            self.historyNoticeView.isHidden = true;
        }
    }
    
    @objc func selectedPlaceCache(_ cache : Dictionary <String, Any>, isCurrent: Int){
      
        self.isHistoryFlag = isCurrent == 1
        //self.historyNoticeView.isHidden = true
         restartCache = cache
        if !forecastWeather {
            
            if let stateArray = excerciseModel.resolveModelCurrent(cache) {
                stateCacheArray = stateArray
                if let state = stateArray[0]{
                    stateCache = state
                    //print("STATE CONDI", state)
                   // print("***", state.ident)
                }
                else{
                    print("STATE CONDI NOT AVAILABLE", stateArray)
                    dimissController()
                }
            }
            else{
                print("FAILED to return stateArray")
                dimissController()
                print("FAILED to return stateArray ??? dismiss")
                
            }
        }
        else{
            if let stateArray = excerciseModel.resolveModelForecast(cache) {
                stateCacheArray = stateArray
                if let state = stateArray[0]{
                    stateCache = state
                    //print("STATE CONDI forecast", state)
                    //print("*** forecast", state.ident)
                   
                    if let forecastPrelim = excerciseModel.resolveModelForecastPrelim(cache){
                        if forecastPrelim.count == EX_ForeCastPrelim.forecastMaxPrelimCount.rawValue{
                            self.issuedDate.text = forecastPrelim[EX_ForeCastPrelim.forecastIssueDate.rawValue]
                            self.periodStart.text = forecastPrelim[EX_ForeCastPrelim.forecastPeriodStart.rawValue]
                            self.periodEnd.text = forecastPrelim[EX_ForeCastPrelim.forecastPeriodEnd.rawValue]
                            self.text.text = forecastPrelim[EX_ForeCastPrelim.forecastText.rawValue]
                        }
                    }
                }
                else{
                    print("STATE CONDI NOT AVAILABLE", stateArray)
                    dimissController()
                }
            }
            else{
                print("FAILED to return stateArray forecast")
                dimissController()
            }
            
        }
        
        
        
        if restartTable{
            restartTable = false
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
            
        }
        //let state : Conditions = excerciseModel.resolveModelCurrent(cache)
        
    }
    
    @objc func dimissController(){
        alertToBadData()
    }
    
    @IBAction func currentForecastSelected(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex){
        
        case 1:
            self.forecastWeather = true
            self.tableViewTopConstraint.constant = 200.0
            flashScrollPrompt()
        default:
            self.forecastWeather = false
            self.tableViewTopConstraint.constant = 50.0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        if let restart = restartCache{
            restartTable = true
            selectedPlaceCache(restart, isCurrent: 0)
            configureForCurrent()
        }
    }
    
    func flashScrollPrompt(){
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ timer in
            DispatchQueue.main.async{
                self.scrollFlashers.isHidden = false
            }
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) {timer in
                
                DispatchQueue.main.async{
                    self.scrollFlashers.isHidden = true
                }
            }
        }
        
        
        
    }
    
    func refreshOps(){
        DispatchQueue.main.async {
            self.refreshBusyIndicator.isHidden = false
            self.disableView(true)
            
            if let idVal = self.currentIdentity{
                
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let dict = self?.delegate?.refreshRequest(idVal){
                        self?.restartTable = true
                        
                        DispatchQueue.main.async {
                            self?.selectedPlaceCache(dict, isCurrent: 0)
                            self?.refreshBusyIndicator.isHidden = true
                            self?.configureForCurrent()
                            self?.disableView(false)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        refreshOps()
    }
    
    
    
    @IBAction func autoRefreshToggle(_ sender: UIBarButtonItem){
        
        self.isAutoRefresh = !self.isAutoRefresh
        
        if self.isAutoRefresh{
            refreshOps()
            self.timerAutoRefreshTimer = Timer.scheduledTimer(withTimeInterval: RefreshTime, repeats: true, block: { timer in
                self.refreshOps()
            })
        }
        else{
            if let timer = self.timerAutoRefreshTimer{
                timer.invalidate()
            }
        }
    }
    
    func disableView(_ shouldDisable : Bool){
        self.currentForecastSwitch.isEnabled = !shouldDisable
        
    }
    
    func favoriteStatusUpdate(_ placeIdent: String){
        
        guard let favStatus = self.delegate?.faveStatus(placeIdent) else {
            return
        }
        
        faveStatus = favStatus
        self.favoriteIndicator.isHidden = !faveStatus
        
    }
    
    @IBAction func favoriteToggle(_ sender: Any) {
        
        faveStatus = !faveStatus
        self.favoriteIndicator.isHidden = !faveStatus
        if let currentId = self.currentIdentity {
            self.delegate?.makeFavorite(faveStatus, placeIdent: currentId)
        }
    }
    
    
    
    func alertToBadData(){
        
        let alert = UIAlertController(title: "Incomplete Data", message: "The place selected has incomplete data", preferredStyle: .alert);
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stateCacheArray != nil {
            return stateCacheArray.count
        }
        else{
            alertToBadData()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell : XTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! XTableViewCell
        
        let cell : XTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! XTableViewCell
        
        //print("CELL IS ", cell)
        if let stateArrayVal = stateCacheArray[indexPath.row]{
            
            if let textVal = stateArrayVal.text{
                cell.placeText?.text = "\(textVal)"
            }
            
            if let dateVal = stateArrayVal.dateIssued{
                cell.dateIssued?.text = "\(dateVal)"
            }
            
            cell.latitude?.text = "\(stateArrayVal.lat)"
            cell.longitude?.text = "\(stateArrayVal.lon)"
            if let dens = stateArrayVal.densityAltitudeFt {
                cell.densityAltitudeFt?.text = "\(dens)"
            }
            else{
                cell.densityAltitudeFt?.text = "NA"
            }
            
            if let presVal = stateArrayVal.pressureHg{
                cell.pressureHg?.text = "\(presVal)"
            }
            else{
                cell.pressureHg?.text = "NA"
            }
            
            if let tempVal = stateArrayVal.tempC{
                cell.tempC?.text = "\(tempVal)"
            }
            else{
                cell.tempC?.text = "NA"
            }
            
            if let dewVal = stateArrayVal.dewpointC{
                cell.dewpointC?.text = "\(dewVal)"
            }
            else{
                cell.dewpointC?.text = "NA"
            }
            
            if let humVal = stateArrayVal.relativeHumidity{
                cell.relativeHumidity?.text = "\(humVal)"
            }
            else{
                cell.relativeHumidity?.text = "NA"
            }
            
            if let elvVal = stateArrayVal.elevationFt{
                cell.elevationFt?.text = "\(elvVal)"
            }
            else{
                cell.elevationFt?.text = "NA"
            }
            
            if let ruleVal = stateArrayVal.flightRules{
                cell.flightRules?.text = "\(ruleVal)".uppercased()
            }
            else{
                cell.flightRules?.text = "NA"
            }
            
            if let visiVal = stateArrayVal.visibility{
                if let SMVal = visiVal.distanceSm{
                    cell.distanceSm?.text = "\(SMVal)"
                }
                else{
                    cell.distanceSm?.text = "NA"
                }
                
                if let PrevVal = visiVal.prevailingVisSm{
                    cell.prevailingVisSm?.text = "\(PrevVal)"
                }
                else{
                    cell.prevailingVisSm?.text = "NA"
                }
            }
            
            var weatherVal = ""
            for weatherObj in stateArrayVal.weather{
                if let weatherPhrase = weatherObj {
                    if weatherVal.lengthOfBytes(using: String.Encoding.utf8) < 1{
                        weatherVal = weatherPhrase
                    }
                    else{
                        weatherVal += ", " + weatherPhrase
                    }
                }
            }
            if weatherVal.lengthOfBytes(using: String.Encoding.utf8) == 0{
                weatherVal = "NA"
            }
            cell.weatherString?.text = "Weather: " + weatherVal

            
            if let windVal = stateArrayVal.wind{
                if let WdVal = windVal.direction{
                    cell.wind_direction?.text = "\(WdVal)"
                }
                else{
                    cell.wind_direction?.text = "NA"
                }
                
                if let speedVal = windVal.speedKts{
                    cell.speedKts.text = "\(speedVal)"
                }
                else{
                    cell.speedKts?.text = "NA"
                }
                
                if let gustSpeedVal = windVal.gustSpeedKts{
                    cell.gustSpeedKts.text = "\(gustSpeedVal)"
                }
                else{
                    cell.gustSpeedKts?.text = "NA"
                }
                
                if let varVal = windVal.variable{
                    let varT = varVal ? "True" : "False"
                    cell.variable?.text = varT
                }
                else{
                    cell.variable?.text = "NA"
                }
            }
            
            var indexClay1 = 0
            let cloudLayArray1 = stateArrayVal.cloudlayer1
            cell.cloudlayer1_1StackView.isHidden = true
            cell.cloudlayer1_2StackView.isHidden = true
            cell.cloudlayer1_3StackView.isHidden = true
            
            for elem in cloudLayArray1{
                
                switch (indexClay1){
                
                case 0:
                    
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay1_alt1?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay1_alt1?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay1_ceil1?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay1_ceil1?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay1_cover1?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay1_cover1?.text = "NA"
                        }
                        
                        cell.cloudlayer1_1StackView.isHidden = false
                    }
                    
                case 1:
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay1_alt2?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay1_alt2?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay1_ceil2?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay1_ceil2?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay1_cover2?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay1_cover2?.text = "NA"
                        }
                        
                        cell.cloudlayer1_2StackView.isHidden = false
                    }
                    
                default:
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay1_alt3?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay1_alt3?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay1_ceil3?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay1_ceil3?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay1_cover3?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay1_cover3?.text = "NA"
                        }
                        cell.cloudlayer1_3StackView.isHidden = false
                    }
                    
                }
                indexClay1 += 1
            }
            
            
            
            
            var indexClay2 = 0
            let cloudLayArray2 = stateArrayVal.cloudLayer2
            cell.cloudlayer2_1StackView.isHidden = true
            cell.cloudlayer2_2StackView.isHidden = true
            cell.cloudlayer2_3StackView.isHidden = true
            
            for elem in cloudLayArray2{
                
                switch (indexClay2){
                
                case 0:
                    
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay2_alt1?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay2_alt1?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay2_ceil1?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay2_ceil1?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay2_cover1?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay2_cover1?.text = "NA"
                        }
                        
                        cell.cloudlayer2_1StackView.isHidden = false
                    }
                    
                case 1:
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay2_alt2?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay2_alt2?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay2_ceil2?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay2_ceil2?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay2_cover2?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay2_cover2?.text = "NA"
                        }
                        
                        cell.cloudlayer2_2StackView.isHidden = false
                    }
                    
                default:
                    if let clay1 = elem {
                        if let altVal1 = clay1.altitudeFt{
                            cell.clay2_alt3?.text = "\(altVal1)"
                        }
                        else{
                            cell.clay2_alt3?.text = "NA"
                        }
                        
                        if let ceilVal1 = clay1.ceiling{
                            cell.clay2_ceil3?.text = "\(ceilVal1)".capitalized
                        }
                        else{
                            cell.clay2_ceil3?.text = "NA"
                        }
                        
                        if let coverVal1 = clay1.coverage{
                            cell.clay2_cover3?.text = "\(coverVal1)"
                        }
                        else{
                            cell.clay2_cover3?.text = "NA"
                        }
                        cell.cloudlayer2_3StackView.isHidden = false
                    }
                    
                }
                indexClay2 += 1
            }
        }
        
     return cell
    }
    
    
    
}

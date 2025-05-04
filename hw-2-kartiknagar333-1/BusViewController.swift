//
//  BusViewController.swift
//  hw-2-kartiknagar333-1
//
//  Created by CDMStudent on 5/2/25.
//

import UIKit
let busURL = "https://www.ctabustracker.com/bustime/api/v3/getpredictions?key=APIKEY&format=json&rt="
 
class BusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    class Bus{
        var tmstmp: String = ""
        var vid: String = ""
        var dstp: Int = 0
        var prdtm: String = ""
        var des: String = ""
        var dly: Bool = false
    }
    var dataAvailable = false
    
    var buses: [Bus] = []
    var selectedStop: String?
    var selectedRoute: String?
    var stpnm: String?
    var errortext: String?

    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var BusTableVieww: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BusTableVieww.delegate = self
        BusTableVieww.dataSource = self
        
        if let rt = selectedRoute {
            selectedRoute = rt
            if let stp = selectedStop {
                selectedStop = stp
                if let nm = stpnm {
                    titleView.text = "\(selectedStop ?? "") \n\(nm)"
                }
                fetchBusPredication()
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAvailable ? buses.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (dataAvailable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusCell", for: indexPath)
           
            let bus = buses[indexPath.row]
            let distanceInMeters = Double(bus.dstp) * 0.3048
            cell.textLabel?.text = "To : \(bus.des)\nArrive on: \(bus.prdtm)"
            cell.detailTextLabel?.text = "VID : \(bus.vid)\n\(bus.dly ? "Delay" : "No Delay")\nDistance: \(String(format: "%.0f", distanceInMeters)) meters"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            cell.textLabel?.text =  errortext
            return cell
        }
    }

    func fetchBusPredication() {
        guard let rt = selectedRoute,
              let stp = selectedStop,
              let feedURL = URL(string: "\(busURL)\(rt)&stpid=\(stp)") else {
            errortext = "Invalid URL or missing data"
            return
        }
        let request = URLRequest(url: feedURL)
        let session = URLSession.shared

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.errortext = error.localizedDescription
                return
            }

            guard let data = data else {
                self?.errortext = "No Data Received"
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
              
                    guard let response = json["bustime-response"] as? [String:Any] else {
                        throw SerializationError.missing("bustime-response")
                    }
                    
                    guard let prdArray = response["prd"] as? [[String:Any]] else {
                        throw SerializationError.missing("prd")
                    }

                    for prdarray in prdArray {
                        guard let tmstmp = prdarray["tmstmp"] as? String else {
                            throw SerializationError.missing("tmstmp")
                        }
                        guard let vid = prdarray["vid"] as? String else {
                            throw SerializationError.missing("vid")
                        }
                        guard let dstp = prdarray["dstp"] as? Int else {
                            throw SerializationError.missing("dstp")
                        }
                        guard let prdtm = prdarray["prdtm"] as? String else {
                            throw SerializationError.missing("prdtm")
                        }
                        guard let dly = prdarray["dly"] as? Bool else {
                            throw SerializationError.missing("dly")
                        }
                        guard let des = prdarray["des"] as? String else {
                            throw SerializationError.missing("des")
                        }
                        let bus = Bus()
                        bus.tmstmp = tmstmp
                        bus.vid = vid
                        bus.dstp = dstp
                        bus.dly = dly
                        bus.prdtm = prdtm
                        bus.des = des
                        self?.buses.append(bus)
                      
                    }
                    self?.dataAvailable = true
                    DispatchQueue.main.async {
                        self?.BusTableVieww.reloadData()
                    }
                    
                } else {
                    self?.errortext = "Invalid JSON Format"
                }
            } catch {
                self?.errortext = "JSON Parsing Error"
            }
        }.resume()
    }


}

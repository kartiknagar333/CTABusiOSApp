//
//  StopViewController.swift
//  hw-2-kartiknagar333-1
//
//  Created by CDMStudent on 5/2/25.
//

import UIKit
let directioURL = "https://www.ctabustracker.com/bustime/api/v3/getdirections?key=APIKEY&format=json&rt="

let stopURL = "https://www.ctabustracker.com/bustime/api/v3/getstops?key=APIKEY&format=json&rt="
 
class StopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var selectedRoute: String?
    var RouteName: String?
    var selectedDir: String?
    var errortext: String?
    
    @IBOutlet weak var StopTableView: UITableView!
    @IBOutlet weak var DirectionSegment: UISegmentedControl!
    
    class dir {
        var id: String = ""
    }
    class Stop {
        var stpid: String = ""
        var stpnm: String = ""
    }
    var dataAvailable = false
    
    var dirs: [dir] = []
    var stops: [Stop] = []
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StopTableView.delegate = self
        StopTableView.dataSource = self
        
        if let route = selectedRoute {
            selectedRoute = route
            if let rtnm = RouteName {
                self.navigationItem.title = "\(selectedRoute ?? "") \(rtnm)"
            }
            fetchDirection()
        }
    }
    
    @IBAction func ChnageDir(_ sender: Any) {
        let index = DirectionSegment.selectedSegmentIndex
           if index != UISegmentedControl.noSegment {
               selectedDir = DirectionSegment.titleForSegment(at: index)
               stops.removeAll()
               dataAvailable = false
               StopTableView.reloadData()
               fetchStops()
           }
    }
    
    func fetchDirection() {
        guard let feedURL = URL(string: directioURL + selectedRoute!) else {
            showExitAlert(title: "Invalid URL", message: "The URL provided is incorrect or malformed. This screen will now close.")
            return
        }

        let request = URLRequest(url: feedURL)
        let session = URLSession.shared

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.showExitAlert(title: "Request Error", message: error.localizedDescription)
                return
            }

            guard let data = data else {
                self?.showExitAlert(title: "No Data Received", message: "The server responded, but no data was returned. This screen will now close.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
              
                    guard let response = json["bustime-response"] as? [String:Any] else {
                        throw SerializationError.missing("bustime-response")
                    }
                    guard let directionsArray = response["directions"] as? [[String:Any]] else {
                        throw SerializationError.missing("directions")
                    }

                    for dirarray in directionsArray {
                        guard let id = dirarray["id"] as? String else {
                            throw SerializationError.missing("id")
                        }
                        
                        let dir1 = dir()
                        dir1.id = id
                        self?.dirs.append(dir1)
                      
                    }
                    
                    DispatchQueue.main.async {
                       
                        self?.DirectionSegment.removeAllSegments()
                        for (index, direction) in self?.dirs.enumerated() ?? [].enumerated() {
                            self?.DirectionSegment.insertSegment(withTitle: direction.id, at: index, animated: true)
                        }
                        self?.DirectionSegment.selectedSegmentIndex = 0
                        self?.selectedDir = self?.dirs[0].id
                        self?.fetchStops()
                    }
                    
                   
                    
                } else {
                    self?.showExitAlert(title: "Invalid JSON Format", message: "The response from the server could not be understood. This screen will now close.")

                }
            } catch {
                self?.showExitAlert(title: "JSON Parsing Error", message: "An error occurred while decoding the server response. This screen will now close.")
            }
        }.resume()
    }
    
    
    func showExitAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAvailable ? dirs.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (dataAvailable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath)
           
            let stop = stops[indexPath.row]
            cell.textLabel?.text = stop.stpid
            cell.detailTextLabel?.text = stop.stpnm
            
          
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            cell.textLabel?.text =  errortext
            return cell
        }
    }

    func fetchStops() {
        guard let route = selectedRoute,
              let dir = selectedDir,
              let feedURL = URL(string: "\(stopURL)\(route)&dir=\(dir)") else {
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
                    guard let stopsArray = response["stops"] as? [[String:Any]] else {
                        throw SerializationError.missing("stops")
                    }

                    for stparray in stopsArray {
                        guard let id = stparray["stpid"] as? String else {
                            throw SerializationError.missing("stpid")
                        }
                        guard let name = stparray["stpnm"] as? String else {
                            throw SerializationError.missing("stpnm")
                        }
                        
                        let stop = Stop()
                        stop.stpid = id
                        stop.stpnm = name
                        self?.stops.append(stop)
                      
                    }
                    self?.dataAvailable = true
                    DispatchQueue.main.async {
                        self?.StopTableView.reloadData()
                    }
                    
                } else {
                    self?.errortext = "Invalid JSON Format"
                }
            } catch {
                self?.errortext = "JSON Parsing Error"
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuses",
           let destinationVC = segue.destination as? BusViewController,
           let indexPath = StopTableView.indexPathForSelectedRow {

            let selected = stops[indexPath.row]
            destinationVC.selectedStop = selected.stpid
            destinationVC.selectedRoute = selectedRoute
            destinationVC.stpnm = selected.stpnm
        }
    }
    
}

import UIKit

 let routeURL = "https://www.ctabustracker.com/bustime/api/v2/getroutes?key=APIKEY&format=json"


class TableViewController: UITableViewController {
    
    class Route {
        var rt: String = ""
        var rtnm: String = ""
        var rtclr: String = ""
        var rtdd: String = ""
    }
    
    var errortext: String?
    var dataAvailable = false
    var routes: [Route] = []
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBusRoutes();
    }
    
    func fetchBusRoutes() {
        guard let feedURL = URL(string: routeURL) else {
            setError("Invalid URL")
            return
        }

        let request = URLRequest(url: feedURL)
        let session = URLSession.shared

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.setError("Request error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                self?.setError("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    guard let response = json["bustime-response"] as? [String:Any] else {
                        throw SerializationError.missing("bustime-response")
                    }
                    guard let routesArray = response["routes"] as? [[String:Any]] else {
                        throw SerializationError.missing("routes")
                    }

                    for routeData in routesArray {
                        guard let id = routeData["rt"] as? String else {
                            throw SerializationError.missing("rt")
                        }
                        guard let name = routeData["rtnm"] as? String else {
                            throw SerializationError.missing("rtnm")
                        }
                        guard let color = routeData["rtclr"] as? String else {
                            throw SerializationError.missing("rtclr")
                        }
                    
                        
                        let route = Route()
                        route.rt = id
                        route.rtnm = name
                        route.rtclr = color
                        
                        self?.routes.append(route)
                    }
                    self?.dataAvailable = true
                    DispatchQueue.main.async{
                        self?.tableView.reloadData()
                    }
                } else {
                    self?.setError("Invalid JSON format")
                }
            } catch {
                self?.setError("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func setError(_ message: String) {
        errortext = message
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAvailable ? routes.count : 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (dataAvailable) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
            let record = routes[indexPath.row]
            cell.textLabel?.text = record.rt
            cell.detailTextLabel?.text = record.rtnm
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            cell.textLabel?.text =  errortext
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStops",
           let destinationVC = segue.destination as? StopViewController,
           let indexPath = tableView.indexPathForSelectedRow {

            let selected = routes[indexPath.row]
            destinationVC.selectedRoute = selected.rt
            destinationVC.RouteName = selected.rtnm
        }
    }
    
}


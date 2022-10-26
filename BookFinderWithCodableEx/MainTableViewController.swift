//
//  MainTableViewController.swift
//  BookFinderWithCodableEx
//
//  Created by Eunchan Kim on 2022/10/26.
//

import UIKit

class MainTableViewController: UITableViewController {

    let apiKey = "KakaoAK 477bb79f961ea2ec95341a674823ad65"
    @IBOutlet weak var searchBar: UISearchBar!
    
    var books:[Book] = [] //struct에 생성한 Books 타입으로 books 배열 만들어준다
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 120
    }

    func search(with query:String?, page: Int){
       guard let query = query else {return}
        let str = "https://dapi.kakao.com/v3/search/book?query=\(query)&page=\(page)"
        //1. URL->URLRequest->URLSSesion->session.dataTask->hadler(data) ->codable ->ResultData
        // ->ResultData.documetnts ->book:[Book}->tableView.reload()
        
        //영어말고 한글도 당연히 검색하겠죠
        //그럴때는 이친구를 써줘요 addingPercentEncoding
        if let strURL = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: strURL){
            var request = URLRequest(url: url)
            request.addValue(apiKey, forHTTPHeaderField: "Authorization")
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) {data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else {return}
                
                if let result = try? JSONDecoder().decode(ResultData.self, from: data){
                    self.books = result.documents
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book = books[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as? UIImageView
        if let url = URL(string: book.thumbnail){
            let request = URLRequest(url: url)
            let session = URLSession.shared
            session.dataTask(with: request){data, _, _ in
                if let data = data {
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        imageView?.image = image
                    }
                }
            }.resume()
        }

        let lblTitle = cell.viewWithTag(2) as? UILabel
        lblTitle?.text = book.title
        
        let lblAuthors = cell.viewWithTag(3) as? UILabel
        lblAuthors?.text = book.authors.joined(separator: ", ")
       
        let lblPublisher = cell.viewWithTag(4) as? UILabel
        lblPublisher?.text = book.publisher
        
        let lblPrice = cell.viewWithTag(5) as? UILabel
        lblPrice?.text = "\(book.price)"

        return cell

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
extension MainTableViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        page = 2
        search(with: searchBar.text, page: page)
        searchBar.resignFirstResponder()
    }
}

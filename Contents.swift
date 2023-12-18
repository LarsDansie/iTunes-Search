import UIKit


struct StoreItem: Codable {
    var name: String
    var artist: String
    var kind: String
    var artworkURL: URL
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case artworkURL = "artworkUrl30"
        case description
    }
   
    enum AdditionalKeys: String, CodingKey {
          case longDescription
      }
      
      init(from decoder: Decoder) throws {
          let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
          self.name = try valueContainer.decode(String.self, forKey: CodingKeys.name)
          self.artist = try valueContainer.decode(String.self, forKey: CodingKeys.artist)
          self.kind = try valueContainer.decode(String.self, forKey: CodingKeys.kind)
          self.artworkURL = try valueContainer.decode(URL.self, forKey: CodingKeys.artworkURL)
          
          if let description = try? valueContainer.decode(String.self, forKey: CodingKeys.description) {
              self.description = description
          } else {
              let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
              self.description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
          }
      }
  }


struct SearchResponse: Codable {
    let results: [StoreItem]
}

enum StoreItemError: Error, LocalizedError {
    case itemsNotFound
}

func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
    var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
    urlComponents.queryItems = query.map { URLQueryItem(name: $0.key,
           value: $0.value) }
        let (data, response) = try await URLSession.shared.data(from:
           urlComponents.url!)
            guard let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 else {
            throw StoreItemError.itemsNotFound
        }
    
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(SearchResponse.self,
           from: data)
    
        return searchResponse.results
    }

let query = [
    "limit": "5",
    "term": "Robbers",
    "artistName": "The 1975",
    "media": "music"
]
Task {
    do {
        let storeItems = try await fetchItems(matching: query)
        storeItems.forEach { item in
            print("""
            Name: \(item.name)
            Artist: \(item.artist)
            Kind: \(item.kind)
            Description: \(item.description)
            Artwork URL: \(item.artworkURL)
             
             
            """)
        }
    } catch {
        print(error)
    }
}


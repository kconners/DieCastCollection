//
//  MyLibrary.swift
//  DieCastCollection
//
//  Created by Kaylen Conners on 9/15/23.
//

import SwiftUI

struct LibaryCard: View {
    @Binding var item: libraryItem
    var body: some View {
        Text(item.casting_name)
    }
}
	


struct MyLibrary: View {
    @State private var items: [libraryItem] = []
  //  @State private var itEM: libraryItem;
    @State private var searchValue = "";
    @State private var imageString = "";
    let screenSize: CGRect = UIScreen.main.bounds
    var body: some View {
        NavigationStack(){
            TextField("Search", text:$searchValue)
                .padding()
                .frame(width: 300, height: 50)
                .background(Color.black.opacity(0.05))
                .cornerRadius(10)
            Divider()
            ScrollView {
                VStack {
                    
                    ForEach(items) { item in // show received results
                        MyRectView(item: item)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxHeight: screenSize.height)
            .border(.green)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            do {
                try await LoadLibrary()
            } catch {
                print("Error", error)
            }
        }
    }
    
    func LoadLibrary() async throws {
        let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let id: String = UserDefaults.standard.string(forKey: "id") ?? ""
        
        guard let url = URL(string: urlForApi+"/users/\(id)/collection") else { fatalError("Missing URL") }
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(token, forHTTPHeaderField: "token")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        let libraryItems = try JSONDecoder().decode([libraryItem].self, from: data)
        items = libraryItems;
        
    }
    
}
struct MyRectView: View {
    let screenSize: CGRect = UIScreen.main.bounds
    var item: libraryItem;
    @State private var imageString = "";
    var body: some View {
        NavigationStack(){
            HStack{
                VStack{
                    Image(base64String: imageString)
                }
                .frame(maxWidth: screenSize.width * 0.25)
                VStack{
                    Text(item.casting_name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(item.tampo)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Georgia", size: 12))
                }
                .frame(maxWidth: screenSize.width * 0.75)
            }
        }
        .border(.gray)
        .cornerRadius(5)
        .background(Color.gray .opacity(0.15))
        .task {
           await checkImage()     // 3)
        }
    }
        
    
    func checkImage() async {
        if(item.casting_id != "" && item.version_id != "") {
            do {
                try await getImage(castingId: item.casting_id, versionId: item.version_id, personalImageId_1: item.user_image_1)
            } catch {
                print("Error", error)
            }
        }
    }
    
    func getImage(castingId: String, versionId: String, personalImageId_1: String) async throws {

        var items: [imageFromDb] = []
        
        guard let url = URL(string: urlForApi+"/castings/\(castingId)/version/\(versionId)/image") else { fatalError("Missing URL") }
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        let images = try JSONDecoder().decode([imageFromDb].self, from: data)
        items = images;
        imageString = items[0].encode
                
    }
}

extension Image {
    init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        guard let uiImage = UIImage(data: data) else { return nil }
        self = Image(uiImage: uiImage.resized(to: CGSize(width: 100, height: 100)))
         
     
    }
}
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

struct imageFromDb: Codable, Identifiable {
    
    public var casting_id: Int
    public var id: Int
    public var encode: String
    public var status: String
    
}
struct LibraryResponse: Codable {
    var LibraryResponses: [libraryItem] = []
}
struct libraryItem: Codable, Identifiable {
    public var casting_name: String
    public var color: String
    public var tampo: String
    public var admin_image_id: Int
    public var id: String
    public var casting_id: String
    public var version_id: String
    public var user_image_1: String
    public var user_image_2: String
    public var location: String
    public var count_carded: String
    public var count_uncarded: String
    public var status: String
}

struct MyLibrary_Previews: PreviewProvider {
    static var previews: some View {
        MyLibrary()
    }
}

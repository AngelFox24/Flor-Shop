import Foundation

struct DeepLink {
    static func destination(from url: URL) -> Destination? {
        guard url.scheme == AppConfig.deepLinkScheme else { return nil }

        for parser in registeredParsers {
            if let destination = parser.parse(url) {
                return destination
            }
        }

        return nil
    }

    static let registeredParsers: [DeepLinkParser] = [
        //TODO: Add more view to redirect with deeplink
        .equal(to: ["point-of-sale"], destination: .tab(.pointOfSale)),
        .equal(to: ["sales"], destination: .tab(.sales)),
        .equal(to: ["customers"], destination: .tab(.customers)),
        .equal(to: ["employees"], destination: .tab(.employees)),

//            .equal(to: ["list", "upcoming"], destination: .push(.customerView(parameters: <#T##CustomerViewParameters#>))),
//        .equal(to: ["list", "top-rated"], destination: .push(.movieList(.topRated))),
//        .equal(to: ["list", "popular"], destination: .push(.movieList(.popular))),

//        .movieDetailsDescription,
//        .movieDetailsGallery,
//
//        .actorDetails,
    ]
}

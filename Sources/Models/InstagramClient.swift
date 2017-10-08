//
//  InstagramClient.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 8/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

struct InstagramClient {

    let clientId: String?
    let redirectURI: String?
    var scopes: [InstagramScope] = [.basic]

    init(clientId: String?, redirectURI: String?) {
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

}

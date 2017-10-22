//
//  InstagramClient.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 8/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

struct InstagramClient {

    // MARK: - Properties

    let clientId: String?
    let redirectURI: String?

    // MARK: - Initializers

    init(clientId: String?, redirectURI: String?) {
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

}

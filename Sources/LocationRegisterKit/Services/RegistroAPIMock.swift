//
//  RegistroAPIMock.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation

public protocol RegistroAPIProtocol {
    func fetchRegistros(completion: @escaping (Result<[RegistroDTO], Error>) -> Void)
}

public final class RegistroAPIMock: RegistroAPIProtocol {
    private let bundle: Bundle

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    public func fetchRegistros(completion: @escaping (Result<[RegistroDTO], Error>) -> Void) {
        guard let url = bundle.url(forResource: "registros", withExtension: "json") else {
            completion(.failure(NSError(domain: "RegistroAPIMock",
                                        code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "registros.json not found"])))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let list = try JSONDecoder().decode([RegistroDTO].self, from: data)
            completion(.success(list))
        } catch {
            completion(.failure(error))
        }
    }
}

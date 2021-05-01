//
//  LivePhoto+SwiftUI.swift
//  
//
//  Created by Christian Elies on 02.12.19.
//

#if canImport(SwiftUI)
import MediaCore
import PhotosUI
import SwiftUI

#if !os(macOS) && !targetEnvironment(macCatalyst) && !os(tvOS)
@available(iOS 13, *)
public extension LivePhoto {
    /// Creates a ready-to-use `SwiftUI` view for capturing `LivePhoto`s
    /// If an error occurs during initialization a `SwiftUI.Text` with the `localizedDescription` is shown.
    ///
    /// - Parameter completion: A closure which gets the `URL` of the captured `LivePhoto` on `success` or `Error` on `failure`.
    ///
    /// - Returns: some View
    static func camera(_ completion: @escaping LivePhotoDataCompletion) -> some View {
        camera(errorView: { error in Text(error.localizedDescription) }, completion)
    }

    /// Creates a ready-to-use `SwiftUI` view for capturing `LivePhoto`s
    /// If an error occurs during initialization the provided `errorView` closure is used to construct the view to be displayed.
    ///
    /// - Parameter errorView: A closure that constructs an error view for the given error.
    /// - Parameter completion: A closure which gets the `URL` of the captured `LivePhoto` on `success` or `Error` on `failure`.
    ///
    /// - Returns: some View
    @ViewBuilder static func camera<ErrorView: View>(@ViewBuilder errorView: (Swift.Error) -> ErrorView, _ completion: @escaping LivePhotoDataCompletion) -> some View {
        let result = Result {
            try CameraViewCreator.livePhoto(completion)
        }
        switch result {
        case let .success(view):
            view
        case let .failure(error):
            errorView(error)
        }
    }
}
#endif

#if !os(macOS) && !os(tvOS)
@available(iOS 13, macOS 10.15, *)
public extension LivePhoto {
    /// Creates a ready-to-use `SwiftUI` view for browsing `LivePhoto`s in the photo library
    /// If an error occurs during initialization a `SwiftUI.Text` with the `localizedDescription` is shown.
    ///
    /// - Parameter selectionLimit: Specifies the number of items which can be selected. Works only on iOS 14 and macOS 11 where the `PHPicker` is used under the hood. Defaults to `1`.
    /// - Parameter completion: A closure which gets the selected `LivePhoto` on `success` or `Error` on `failure`.
    ///
    /// - Returns: some View
    static func browser(selectionLimit: Int = 1, _ completion: @escaping ResultLivePhotosCompletion) -> some View {
        browser(errorView: { error in Text(error.localizedDescription) }, completion)
    }

    /// Creates a ready-to-use `SwiftUI` view for browsing `LivePhoto`s in the photo library
    /// If an error occurs during initialization the provided `errorView` closure is used to construct the view to be displayed.
    ///
    /// - Parameter selectionLimit: Specifies the number of items which can be selected. Works only on iOS 14 and macOS 11 where the `PHPicker` is used under the hood. Defaults to `1`.
    /// - Parameter errorView: A closure that constructs an error view for the given error.
    /// - Parameter completion: A closure which gets the selected `LivePhoto` on `success` or `Error` on `failure`.
    ///
    /// - Returns: some View
    @ViewBuilder static func browser<ErrorView: View>(selectionLimit: Int = 1, @ViewBuilder errorView: (Swift.Error) -> ErrorView, _ completion: @escaping ResultLivePhotosCompletion) -> some View {
        if #available(iOS 14, macOS 11, *) {
            PHPicker(configuration: {
                var configuration = PHPickerConfiguration()
                configuration.filter = .livePhotos
                configuration.selectionLimit = selectionLimit
                return configuration
            }()) { result in
                switch result {
                case let .success(result):
                    let result = Result {
                        try result.compactMap { object -> LivePhoto? in
                            guard let assetIdentifier = object.assetIdentifier else {
                                return nil
                            }
                            return try LivePhoto.with(identifier: .init(stringLiteral: assetIdentifier))
                        }
                    }
                    completion(result)
                case let .failure(error): ()
                    completion(.failure(error))
                }
            }
        } else {
            let result = Result {
                try ViewCreator.browser(mediaTypes: [.image, .livePhoto]) { (result: Result<LivePhoto, Error>) in
                    switch result {
                    case let .success(livePhoto):
                        completion(.success([livePhoto]))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
            switch result {
            case let .success(view):
                view
            case let .failure(error):
                errorView(error)
            }
        }
    }
}
#endif

#if !os(macOS) && !targetEnvironment(macCatalyst)
@available(iOS 13, tvOS 13, *)
public extension LivePhoto {
    /// Creates a ready-to-use `SwiftUI` view representation of the receiver
    ///
    /// - Parameter size: the desired size of the `LivePhoto`
    ///
    func view(size: CGSize) -> some View {
        LivePhotoView(livePhoto: self, size: size)
    }
}
#endif

#endif

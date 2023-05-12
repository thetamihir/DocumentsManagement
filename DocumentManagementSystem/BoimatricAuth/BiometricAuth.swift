//
//  LocalAuth.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import Foundation
import LocalAuthentication

final class BiometricAuth {
    
   static let share = BiometricAuth()
    enum BiometricType {
        case none
        case touchID
        case faceID
        case unknown
    }
    
    enum BiometricError: LocalizedError {
        case authenticationFailed
        case userCancel
        case userFallback
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed: return "There was a problem verifying your identity."
            case .userCancel: return "You pressed cancel."
            case .userFallback: return "You pressed password."
            case .biometryNotAvailable: return "Face ID/Touch ID is not available."
            case .biometryNotEnrolled: return "Face ID/Touch ID is not set up."
            case .biometryLockout: return "Face ID/Touch ID is locked."
            case .unknown: return "Face ID/Touch ID may not be configured"
            }
        }
    }
    
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    init(policy: LAPolicy = .deviceOwnerAuthentication,
         localizedReason: String = "Verify your Identity",
         localizedFallbackTitle: String = "Enter App Password") {
        self.policy = policy
        self.localizedReason = localizedReason
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = "cancle"
    }
    
    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        guard context.canEvaluatePolicy(policy, error: &error) else {
            let type = biometricType(for: context.biometryType)
            guard let error = error else {
                return completion(false, type, nil)
            }
        
            return completion(false, type, biometricError(from: error))
        }
        completion(true, biometricType(for: context.biometryType), nil)
    }
    
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    guard let error = error else { return completion(false, nil) }
                    completion(false, self?.biometricError(from: error as NSError))
                }
            }
        }
    }
    
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
    
    private func biometricError(from nsError: NSError) -> BiometricError {
        let error: BiometricError
        
        switch nsError {
        case LAError.authenticationFailed:
            error = .authenticationFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
            error = .userFallback
        case LAError.biometryNotAvailable:
            error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            error = .biometryNotEnrolled
        case LAError.biometryLockout:
            error = .biometryLockout
        default:
            error = .unknown
        }
        
        return error
    }
}


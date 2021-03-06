//
//  AuthService.swift
//  PitTime
//
//  Created by 神村亮佑 on 2020/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let dbBase = Firestore.firestore()

class AuthService {

    // MARK: PROPERTIES
    static let instance = AuthService()

    private var REF_USER = dbBase.collection("users")

    // MARK: FUNCTIONS
    func logInUserToFirebase(credential: AuthCredential, handler: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?, _ userID: String?) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            // Check for errors
            if error != nil {
                print("Error logging in to Firebase")
                handler(nil, true, nil, nil)
                return
            }
            // Check for provider ID
            guard let providerID = result?.user.uid else {
                print("Error getting provider ID")
                handler(nil, true, nil, nil)
                return
            }

            self.checkIfUserExistsInDatabase(providerID: providerID) { returnedUserID in
                if let userID = returnedUserID {
                    handler(providerID, false, false, userID)
                    return
                } else {
                    handler(providerID, false, true, nil)
                    return
                }
            }
        }
    }

    func logInUserToApp(userID: String, handler: @escaping (_ success: Bool) -> Void) {
        // Get the users info
        getUserInfo(forUserID: userID) { returnedName, returnedBio in
            if let name = returnedName, let bio = returnedBio {
                // Success
                print("Success getting user info log in")
                handler(true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Set the users info into our app
                    UserDefaults.standard.set(userID, forKey: CurrentUserDefaults.userID)
                    UserDefaults.standard.set(bio, forKey: CurrentUserDefaults.bio)
                    UserDefaults.standard.set(name, forKey: CurrentUserDefaults.displayName)
                }
            } else {
                // Error
                print("Error getting user info while log in")
                handler(false)
            }
        }
    }

    func logOutUser(handler: @escaping (_ success: Bool) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error \(error)")
            handler(false)
            return
        }
        handler(true)

        // Updated UserDefaults
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let defaultDictionary = UserDefaults.standard.dictionaryRepresentation()
            defaultDictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    func createNewUserInDatabase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, handler: @escaping (_ userID: String?) -> Void) {

        // Set up a user Document with the user Collection
        let document = REF_USER.document()
        let userID = document.documentID

        // Upload profile image to Storage
        ImageManager.instance.uploadProfileImage(userID: userID, image: profileImage)

        // Upload profile data to Firestore
        let userData: [String: Any] = [
            DatabaseUserField.displayName: name,
            DatabaseUserField.email: email,
            DatabaseUserField.providerID: providerID,
            DatabaseUserField.provider: provider,
            DatabaseUserField.userID: userID,
            DatabaseUserField.bio: "",
            DatabaseUserField.dateCreated: FieldValue.serverTimestamp()
        ]
        document.setData(userData) {error in
            if error != nil {
                // Error
                print("Error uploading data to user document")
                handler(nil)
            } else {
                // Success
                handler(userID)
            }
        }
    }

    func getUserInfo(forUserID userID: String, handler: @escaping (_ name: String?, _ bio: String?) -> Void) {
        REF_USER.document(userID).getDocument { documentSnapshot, _ in
            if let document = documentSnapshot,
               let name = document.get(DatabaseUserField.displayName) as? String,
               let bio = document.get(DatabaseUserField.bio) as? String {
                print("Success getting user info")
                handler(name, bio)
                return
            } else {
                print("Error getting user info")
                handler(nil, nil)
                return
            }
        }
    }

    // MARK: PRIVATE FUNCTIONS
    private func checkIfUserExistsInDatabase(providerID: String, handler: @escaping (_ existingUserID: String?) -> Void) {
        // If a userID is returned, then the user does exist in our database
        REF_USER.whereField(DatabaseUserField.providerID, isEqualTo: providerID).getDocuments {querySnapshot, _ in
            if let snapshot = querySnapshot, snapshot.isEmpty != true, let document = snapshot.documents.first {
                let existingUserID = document.documentID
                handler(existingUserID)
            } else {
                // ERROR NEW USER
                handler(nil)
                return
            }
        }
    }

}

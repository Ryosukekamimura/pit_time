//
//  OnboardingView.swift
//  PitTime
//
//  Created by 神村亮佑 on 2020/11/25.
//

import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var displayName: String = ""
    @State var email: String = ""
    @State var providerID: String = ""
    @State var provider: String = ""
    
    @State var showOnboardingPart2: Bool = false
    @State var showError: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20, content: {
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .accentColor(.black)
                        .padding(.vertical, 40)
                        .padding(.leading, 20)
                })
                Spacer()
            }
            Spacer()
            Text("Welcome to ピッとたいむ!".uppercased())
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color.MyTheme.blueColor)
            
            Text("「ピッとたいむ」は時間管理を後押しするアプリです。")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding()
                .foregroundColor(Color.MyTheme.blueColor)
            
            //MARK: SIGN IN WITH APPLE
            Button(action: {
                SignInWithApple.instance.startSignInWithAppleFlow(view: self)
            }, label: {
                SignInWithAppleButtonCustom()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(.horizontal, 20)
            })
            
            //MARK: SIGN IN WITH GOOGLE
            Button(action: {
                SignInWithGoogle.instance.startSignInWithGoogleFlow(view: self)
            }, label: {
                HStack{
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.sRGB, red: 222/255, green: 82/255, blue: 70/255, opacity: 1.0))
                .cornerRadius(9)
                .font(.system(size: 25, weight: .medium, design: .default))
                .padding(.horizontal, 20)
            })
            .accentColor(.white)
            
            Spacer()
        })
        .background(Color.MyTheme.beigeColor)
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showOnboardingPart2, onDismiss:  {
            self.presentationMode.wrappedValue.dismiss()
        }, content: {
            OnboardingViewPart2(displayName: $displayName, email: $email, providerID: $providerID, provider: $provider)
        })
        .alert(isPresented: $showError) { () -> Alert in
            Alert(title: Text("Error signingg in 🙁"))
        }
    }
    
    //MARK: FUNCTIONS
    func connectToFirebase(name: String, email: String, provider: String, credentical: AuthCredential) {
        AuthService.instance.logInUserToFirebase(credential: credentical) { (returnedProviderID, isError, isNewUser, returnedUserID) in
            if let newUser = isNewUser {
                if newUser{
                    // NEW USER
                    if let providerID = returnedProviderID, !isError {
                        // SUCCESS
                        // New user, continue to the onboarding part 2
                        self.displayName = name
                        self.email = email
                        self.providerID = providerID
                        self.provider = provider
                        print("This is email -> \(email)")
                        self.showOnboardingPart2.toggle()
                    }else{
                        //ERROR
                        print("Error getting provider ID from log in user to Firebase")
                        self.showError.toggle()
                    }
                }else{
                    // EXISTING USER
                    if let userID = returnedUserID {
                        // SUCCESS, LOG IN TO APP
                        AuthService.instance.logInUserToApp(userID: userID) { (success) in
                            if success{
                                print("Successfull log in existing user")
                                self.presentationMode.wrappedValue.dismiss()
                            }else{
                                print("Error log in existing user into our app")
                                self.showError.toggle()
                            }
                        }
                    }else{
                        // ERROR
                        print("Error getting User ID from existing user to Firebase")
                        self.showError.toggle()
                    }
                }
            }else{
                // ERROR
                print("Error getting into from  log in user to Firebase")
                self.showError.toggle()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

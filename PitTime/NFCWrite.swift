//
//  NFCWrite.swift
//  PitTime
//
//  Created by 神村亮佑 on 2020/11/24.
//

import SwiftUI
import CoreNFC
import UIKit
// import RealmSwift

class NFCSessionWrite: NSObject, NFCNDEFReaderSessionDelegate {
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserDisplayName: String?

    // MARK: PROPERTIES
    var session: NFCNDEFReaderSession?
    var isShareOthers: Bool = false
    var isEndTime: Bool = false

    // MARK: PUBLIC FUNCTIONS
    public func  beginScanning(isShareOthers: Bool, isEndTime: Bool) {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("スキャンに対応されていない機種です。申し訳ございません。")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
        self.isShareOthers = isShareOthers
        self.isEndTime = isEndTime
        session?.alertMessage = "データを書き込むのでNFCタグに近づけてください"
        session?.begin()
        return
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Do nothing here unless you want to impletent error
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Do nothing here
    }
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // This is to silence console.
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // restart session for 2 seconds
            let retryInterval = DispatchTimeInterval.milliseconds(2000)
            session.alertMessage = "1個以上のタグが見つかります。もう一度お試しください"
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        let tag = tags.first!
        session.connect(to: tag) { error in
            if error != nil {
                session.alertMessage = "NFCタグに書き込むことが出来ませんでした。もう一度お試しください"
                session.invalidate()
                print("ERROR CONNECTED")
                return
            } else {
                // Query tag if no error occur
                tag.queryNDEFStatus {ndefStatus, _, error in
                    if error != nil {
                        session.alertMessage = "NFCタグを照会することができません🙄"
                        session.invalidate()
                        print("ERROR QUERY TAG")
                        return
                    }

                    // proceed to query
                    switch ndefStatus {
                    case .notSupported:
                        print("Not Supoort")
                        session.alertMessage = "このタグはNDEFを実行することができませんでした😥"
                        session.invalidate()
                    case .readWrite:
                        // Writing code logic
                        print("Read Write")
                        let payLoad: NFCNDEFPayload?

                        // Write Current Time
                        let currentTime = self.getCurrentTime()

                        payLoad = NFCNDEFPayload(
                            format: .nfcWellKnown,
                            type: "T".data(using: .utf8)!,
                            identifier: "Text".data(using: .utf8)!,
                            payload: currentTime.data(using: .utf8)!
                        )

                        // make our message array
                        let nfcMessage = NFCNDEFMessage(records: [payLoad!])
                        print("\(nfcMessage)")

                        // write to tag
                        tag.writeNDEF(nfcMessage) { error in
                            if error != nil {
                                session.alertMessage = "WRITE NFC FAIL: \(error!.localizedDescription)"
                                print("fail write : \(String(describing: error?.localizedDescription))")
                            } else {
                                session.alertMessage = "成功しました！🤩"
                                print("SUCCESS WRITE!!")

                                
                                
                                //MARK: TODO: MAKE FUNCTION
                                if self.isShareOthers {
                                    if self.isEndTime {
                                        // EndTime in PitModel
                                        print("\(currentTime) THIS IS END TIME")
                                        
                                        
                                    }else{
                                        // Share Firestore
                                        NFCWriteService.instance.postCloudStoreOnlyBeginTime(beginTime: currentTime)
                                    }
                                } else {
                                    print("Not Share Others🥺")
                                }
                                
                                
                            }
                            session.invalidate()
                        }

                    case .readOnly:
                        print("Read Only")
                        session.alertMessage = "Tag is read only."
                        session.invalidate()

                    @unknown default:
                        print("Unkwon error")
                        session.alertMessage = "Unknown NDEF tag status"
                        session.invalidate()

                    }
                }
            }
        }
    }
    // MARK: PRIVATE FUNCTIONS
    private func getCurrentTime() -> String {
        let time = Date()
        print("CURRENT TIME = \(time)")
        let currentTime = DateHelper.instance.stringFromDate(date: time)
        return currentTime
    }

    private func notSupported(session: NFCNDEFReaderSession) {
        print("Not Supoort")
        session.alertMessage = "Tag is not NDEF complaint"
        session.invalidate()
    }
}

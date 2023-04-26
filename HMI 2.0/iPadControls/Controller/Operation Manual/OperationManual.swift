//
//  HomeGeneralSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 01/03/19.
//  Copyright © 2019 WET. All rights reserved.
//


import Foundation
import PDFReader


public class OperationManual{
    
    let logger = Logger()
    
    /***************************************************************************
     * Function :  showOpereationManual
     * Input    :  none
     * Output   :  Reader View Controller Instance
     * Comment  :
     ***************************************************************************/
    
    public func showOperationManual() -> PDFViewController {
        
        let systemLanguage = getDeviceLanguage()
        
        //Show Operation Manual According to the Device Language
        
        switch systemLanguage{
            
        case "en-us":
            return getOperationManualPDFFile(name: "OManual")
        default:
            return getOperationManualPDFFile(name: "OManual")
            
        }
        
    }
    
    /***************************************************************************
     * Function :  getDeviceLanguage
     * Input    :  none
     * Output   :  Language Name
     * Comment  :  This function is used just in case multi language operation
     *             manuals are provided
     ***************************************************************************/
    
    private func getDeviceLanguage() -> String{
        
        let language = Locale.preferredLanguages[0]
        logger.logData(data: "OPERATION MANUAL: SYSTEM LANGUAGE -> \(language)")
        
        return language
        
    }
    
    /***************************************************************************
     * Function :  getOperationManualPDFFile
     * Input    :  pdf file name
     * Output   :  Reader View Controller Instance
     * Comment  :
     ***************************************************************************/
    
    private func getOperationManualPDFFile(name:String) -> PDFViewController {
        
        let operationManualFilePath = Bundle.main.url(forResource: name, withExtension: "pdf")
        let document = PDFDocument(url: operationManualFilePath!)
        let readerController = PDFViewController.createNew(with: document!)
        readerController.backgroundColor = .black
        readerController.scrollDirection = .horizontal
        readerController.view.transform = CGAffineTransform(rotationAngle: .pi / 2)
        readerController.title = "OPERATION MANUAL"
        return readerController
    }
    
}

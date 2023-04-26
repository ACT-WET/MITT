function firestatusLogWrapper(){
    //console.log("StatusLog script triggered");
    var totalStatus;
    var status_fire = [];
    
if (ATHOPLCConnected){

    athoplc_client.readHoldingRegister(100,30,function(resp){
        
        if (resp != undefined && resp != null){
            nthBit(resp.register[0],0)
            
            //Device AirLifts
            status_fire.push(nthBit(resp.register[12],0) ? nthBit(resp.register[12],0) : 0); // Out_DeviceLift AirValve
            status_fire.push(nthBit(resp.register[12],1) ? nthBit(resp.register[12],1) : 0); // Out_FirePilot AirValve
            status_fire.push(nthBit(resp.register[12],2) ? nthBit(resp.register[12],2) : 0); // Out_WaterLift AirValve
            
            //Supervisory Station Valves
            status_fire.push(nthBit(resp.register[16],3) ? nthBit(resp.register[16],3) : 0); // ZSO 6501 Gasvalve Open
            status_fire.push(nthBit(resp.register[16],4) ? nthBit(resp.register[16],4) : 0); // ZSC 6501 Gasvalve Closed
            status_fire.push(nthBit(resp.register[16],5) ? nthBit(resp.register[16],5) : 0); // ZSO 6502 Gasvalve Open
            status_fire.push(nthBit(resp.register[16],6) ? nthBit(resp.register[16],6) : 0); // ZSC 6502 Gasvalve Closed  
            status_fire.push(nthBit(resp.register[16],7) ? nthBit(resp.register[16],7) : 0); // ZSC 6503 Gasvalve Closed  
            status_fire.push(nthBit(resp.register[16],8) ? nthBit(resp.register[16],8) : 0); // ZSC 6504 Gasvalve Closed  
            status_fire.push(nthBit(resp.register[16],9) ? nthBit(resp.register[16],9) : 0); // PSL Fault
            status_fire.push(nthBit(resp.register[16],10) ? nthBit(resp.register[16],10) : 0); // PSH Fault

            //Supervisory Station Inlet Outlet Pressure
            status_fire.push(nthBit(resp.register[17],0) ? nthBit(resp.register[17],0) : 0); // PT 6501 ChannelFault
            status_fire.push(nthBit(resp.register[17],1) ? nthBit(resp.register[17],1) : 0); // PT 6501 AboveHi
            status_fire.push(nthBit(resp.register[17],2) ? nthBit(resp.register[17],2) : 0); // PT 6501 Below L
            status_fire.push(nthBit(resp.register[17],3) ? nthBit(resp.register[17],3) : 0); // PT 6502 ChannelFault
            status_fire.push(nthBit(resp.register[17],4) ? nthBit(resp.register[17],4) : 0); // PT 6502 AboveHi
            status_fire.push(nthBit(resp.register[17],5) ? nthBit(resp.register[17],5) : 0); // PT 6502 Below L 

            //FireShooter Lifts
            status_fire.push(nthBit(resp.register[18],0) ? nthBit(resp.register[18],0) : 0); // YS6101 FireEnable 

            status_fire.push(nthBit(resp.register[18],1) ? nthBit(resp.register[18],1) : 0); // FS601 RaiseError
            status_fire.push(nthBit(resp.register[18],2) ? nthBit(resp.register[18],2) : 0); // FS601 LowerError
            status_fire.push(nthBit(resp.register[18],3) ? nthBit(resp.register[18],3) : 0); // FS601 Raised

            status_fire.push(nthBit(resp.register[18],4) ? nthBit(resp.register[18],4) : 0); // FS602 RaiseError
            status_fire.push(nthBit(resp.register[18],5) ? nthBit(resp.register[18],5) : 0); // FS602 LowerError
            status_fire.push(nthBit(resp.register[18],6) ? nthBit(resp.register[18],6) : 0); // FS602 Raised

            status_fire.push(nthBit(resp.register[18],7) ? nthBit(resp.register[18],7) : 0); // FS603 RaiseError
            status_fire.push(nthBit(resp.register[18],8) ? nthBit(resp.register[18],8) : 0); // FS603 LowerError
            status_fire.push(nthBit(resp.register[18],9) ? nthBit(resp.register[18],9) : 0); // FS603 Raised

            status_fire.push(nthBit(resp.register[18],10) ? nthBit(resp.register[18],10) : 0); // FS604 RaiseError
            status_fire.push(nthBit(resp.register[18],11) ? nthBit(resp.register[18],11) : 0); // FS604 LowerError
            status_fire.push(nthBit(resp.register[18],12) ? nthBit(resp.register[18],12) : 0); // FS604 Raised

            status_fire.push(nthBit(resp.register[18],13) ? nthBit(resp.register[18],13) : 0); // FS605 RaiseError
            status_fire.push(nthBit(resp.register[18],14) ? nthBit(resp.register[18],14) : 0); // FS605 LowerError
            status_fire.push(nthBit(resp.register[18],15) ? nthBit(resp.register[18],15) : 0); // FS605 Raised

            status_fire.push(nthBit(resp.register[19],0) ? nthBit(resp.register[19],0) : 0); // FS606 RaiseError
            status_fire.push(nthBit(resp.register[19],1) ? nthBit(resp.register[19],1) : 0); // FS606 LowerError
            status_fire.push(nthBit(resp.register[19],2) ? nthBit(resp.register[19],2) : 0); // FS606 Raised

            status_fire.push(nthBit(resp.register[19],3) ? nthBit(resp.register[19],3) : 0); // FS607 RaiseError
            status_fire.push(nthBit(resp.register[19],4) ? nthBit(resp.register[19],4) : 0); // FS607 LowerError
            status_fire.push(nthBit(resp.register[19],5) ? nthBit(resp.register[19],5) : 0); // FS607 Raised

            status_fire.push(nthBit(resp.register[19],6) ? nthBit(resp.register[19],6) : 0); // FS608 RaiseError
            status_fire.push(nthBit(resp.register[19],7) ? nthBit(resp.register[19],7) : 0); // FS608 LowerError
            status_fire.push(nthBit(resp.register[19],8) ? nthBit(resp.register[19],8) : 0); // FS608 Raised

            status_fire.push(nthBit(resp.register[19],9) ? nthBit(resp.register[19],9) : 0); // FS609 RaiseError
            status_fire.push(nthBit(resp.register[19],10) ? nthBit(resp.register[19],10) : 0); // FS609 LowerError
            status_fire.push(nthBit(resp.register[19],11) ? nthBit(resp.register[19],11) : 0); // FS609 Raised

            status_fire.push(nthBit(resp.register[19],12) ? nthBit(resp.register[19],12) : 0); // FS610 RaiseError
            status_fire.push(nthBit(resp.register[19],13) ? nthBit(resp.register[19],13) : 0); // FS610 LowerError
            status_fire.push(nthBit(resp.register[19],14) ? nthBit(resp.register[19],14) : 0); // FS610 Raised

            status_fire.push(nthBit(resp.register[19],15) ? nthBit(resp.register[19],15) : 0); // FS611 RaiseError
            status_fire.push(nthBit(resp.register[20],0) ? nthBit(resp.register[20],0) : 0); // FS611 LowerError
            status_fire.push(nthBit(resp.register[20],1) ? nthBit(resp.register[20],1) : 0); // FS611 Raised

            status_fire.push(nthBit(resp.register[20],2) ? nthBit(resp.register[20],2) : 0); // FS612 RaiseError
            status_fire.push(nthBit(resp.register[20],3) ? nthBit(resp.register[20],3) : 0); // FS612 LowerError
            status_fire.push(nthBit(resp.register[20],4) ? nthBit(resp.register[20],4) : 0); // FS612 Raised

            status_fire.push(nthBit(resp.register[20],5) ? nthBit(resp.register[20],5) : 0); // FS613 RaiseError
            status_fire.push(nthBit(resp.register[20],6) ? nthBit(resp.register[20],6) : 0); // FS613 LowerError
            status_fire.push(nthBit(resp.register[20],7) ? nthBit(resp.register[20],7) : 0); // FS613 Raised

            status_fire.push(nthBit(resp.register[20],8) ? nthBit(resp.register[20],8) : 0); // FS614 RaiseError
            status_fire.push(nthBit(resp.register[20],9) ? nthBit(resp.register[20],9) : 0); // FS614 LowerError
            status_fire.push(nthBit(resp.register[20],10) ? nthBit(resp.register[20],10) : 0); // FS614 Raised

            status_fire.push(nthBit(resp.register[20],11) ? nthBit(resp.register[20],11) : 0); // FS615 RaiseError
            status_fire.push(nthBit(resp.register[20],12) ? nthBit(resp.register[20],12) : 0); // FS615 LowerError
            status_fire.push(nthBit(resp.register[20],13) ? nthBit(resp.register[20],13) : 0); // FS615 Raised

            status_fire.push(nthBit(resp.register[20],14) ? nthBit(resp.register[20],14) : 0); // FS616 RaiseError
            status_fire.push(nthBit(resp.register[20],15) ? nthBit(resp.register[20],15) : 0); // FS616 LowerError
            status_fire.push(nthBit(resp.register[21],0) ? nthBit(resp.register[21],0) : 0); // FS616 Raised

            status_fire.push(nthBit(resp.register[21],1) ? nthBit(resp.register[21],1) : 0); // FS617 RaiseError
            status_fire.push(nthBit(resp.register[21],2) ? nthBit(resp.register[21],2) : 0); // FS617 LowerError
            status_fire.push(nthBit(resp.register[21],3) ? nthBit(resp.register[21],3) : 0); // FS617 Raised

            status_fire.push(nthBit(resp.register[21],4) ? nthBit(resp.register[21],4) : 0); // FS618 RaiseError
            status_fire.push(nthBit(resp.register[21],5) ? nthBit(resp.register[21],5) : 0); // FS618 LowerError
            status_fire.push(nthBit(resp.register[21],6) ? nthBit(resp.register[21],6) : 0); // FS618 Raised

            status_fire.push(nthBit(resp.register[21],7) ? nthBit(resp.register[21],7) : 0); // FS619 RaiseError
            status_fire.push(nthBit(resp.register[21],8) ? nthBit(resp.register[21],8) : 0); // FS619 LowerError
            status_fire.push(nthBit(resp.register[21],9) ? nthBit(resp.register[21],9) : 0); // FS619 Raised

            status_fire.push(nthBit(resp.register[21],10) ? nthBit(resp.register[21],10) : 0); // FS620 RaiseError
            status_fire.push(nthBit(resp.register[21],11) ? nthBit(resp.register[21],11) : 0); // FS620 LowerError
            status_fire.push(nthBit(resp.register[21],12) ? nthBit(resp.register[21],12) : 0); // FS620 Raised

            status_fire.push(nthBit(resp.register[21],13) ? nthBit(resp.register[21],13) : 0); // FS621 RaiseError
            status_fire.push(nthBit(resp.register[21],14) ? nthBit(resp.register[21],14) : 0); // FS621 LowerError
            status_fire.push(nthBit(resp.register[21],15) ? nthBit(resp.register[21],15) : 0); // FS621 Raised

            status_fire.push(nthBit(resp.register[22],0) ? nthBit(resp.register[22],0) : 0); // FS622 RaiseError
            status_fire.push(nthBit(resp.register[22],1) ? nthBit(resp.register[22],1) : 0); // FS622 LowerError
            status_fire.push(nthBit(resp.register[22],2) ? nthBit(resp.register[22],2) : 0); // FS622 Raised

            status_fire.push(nthBit(resp.register[22],3) ? nthBit(resp.register[22],3) : 0); // FS623 RaiseError
            status_fire.push(nthBit(resp.register[22],4) ? nthBit(resp.register[22],4) : 0); // FS623 LowerError
            status_fire.push(nthBit(resp.register[22],5) ? nthBit(resp.register[22],5) : 0); // FS623 Raised

            status_fire.push(nthBit(resp.register[22],6) ? nthBit(resp.register[22],6) : 0); // FS624 RaiseError
            status_fire.push(nthBit(resp.register[22],7) ? nthBit(resp.register[22],7) : 0); // FS624 LowerError
            status_fire.push(nthBit(resp.register[22],8) ? nthBit(resp.register[22],8) : 0); // FS624 Raised

            status_fire.push(nthBit(resp.register[22],9) ? nthBit(resp.register[22],9) : 0); // FS625 RaiseError
            status_fire.push(nthBit(resp.register[22],10) ? nthBit(resp.register[22],10) : 0); // FS625 LowerError
            status_fire.push(nthBit(resp.register[22],11) ? nthBit(resp.register[22],11) : 0); // FS625 Raised

            status_fire.push(nthBit(resp.register[22],12) ? nthBit(resp.register[22],12) : 0); // FS626 RaiseError
            status_fire.push(nthBit(resp.register[22],13) ? nthBit(resp.register[22],13) : 0); // FS626 LowerError
            status_fire.push(nthBit(resp.register[22],14) ? nthBit(resp.register[22],14) : 0); // FS626 Raised

            status_fire.push(nthBit(resp.register[22],15) ? nthBit(resp.register[22],15) : 0); // FS627 RaiseError
            status_fire.push(nthBit(resp.register[23],0) ? nthBit(resp.register[23],0) : 0); // FS627 LowerError
            status_fire.push(nthBit(resp.register[23],1) ? nthBit(resp.register[23],1) : 0); // FS627 Raised

            //Oarsman GFCI Status
            status_fire.push(nthBit(resp.register[14],0) ? nthBit(resp.register[14],0) : 0); // Oarsman 601 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],1) ? nthBit(resp.register[14],1) : 0); // Oarsman 602 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],2) ? nthBit(resp.register[14],2) : 0); // Oarsman 603 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],3) ? nthBit(resp.register[14],3) : 0); // Oarsman 604 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],4) ? nthBit(resp.register[14],4) : 0); // Oarsman 605 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],5) ? nthBit(resp.register[14],5) : 0); // Oarsman 606 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],6) ? nthBit(resp.register[14],6) : 0); // Oarsman 607 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],7) ? nthBit(resp.register[14],7) : 0); // Oarsman 608 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],8) ? nthBit(resp.register[14],8) : 0); // Oarsman 609 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],9) ? nthBit(resp.register[14],9) : 0); // Oarsman 610 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],10) ? nthBit(resp.register[14],10) : 0); // Oarsman 611 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],11) ? nthBit(resp.register[14],11) : 0); // Oarsman 612 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],12) ? nthBit(resp.register[14],12) : 0); // Oarsman 613 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],13) ? nthBit(resp.register[14],13) : 0); // Oarsman 614 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],14) ? nthBit(resp.register[14],14) : 0); // Oarsman 615 GFCI Tripped
            status_fire.push(nthBit(resp.register[14],15) ? nthBit(resp.register[14],15) : 0); // Oarsman 616 GFCI Tripped
            status_fire.push(nthBit(resp.register[15],0) ? nthBit(resp.register[15],0) : 0); // Oarsman 617 GFCI Tripped
            status_fire.push(nthBit(resp.register[15],1) ? nthBit(resp.register[15],1) : 0); // Oarsman 618 GFCI Tripped
            status_fire.push(nthBit(resp.register[15],2) ? nthBit(resp.register[15],2) : 0); // Oarsman 619 GFCI Tripped
            status_fire.push(nthBit(resp.register[15],3) ? nthBit(resp.register[15],3) : 0); // Oarsman 620 GFCI Tripped

            //Call For Ignition Status
            status_fire.push(nthBit(resp.register[24],0) ? nthBit(resp.register[24],0) : 0); // ClFrIg 601
            status_fire.push(nthBit(resp.register[24],1) ? nthBit(resp.register[24],1) : 0); // ClFrIg 602
            status_fire.push(nthBit(resp.register[24],2) ? nthBit(resp.register[24],2) : 0); // ClFrIg 603
            status_fire.push(nthBit(resp.register[24],3) ? nthBit(resp.register[24],3) : 0); // ClFrIg 604
            status_fire.push(nthBit(resp.register[24],4) ? nthBit(resp.register[24],4) : 0); // ClFrIg 605
            status_fire.push(nthBit(resp.register[24],5) ? nthBit(resp.register[24],5) : 0); // ClFrIg 606
            status_fire.push(nthBit(resp.register[24],6) ? nthBit(resp.register[24],6) : 0); // ClFrIg 607
            status_fire.push(nthBit(resp.register[24],7) ? nthBit(resp.register[24],7) : 0); // ClFrIg 608
            status_fire.push(nthBit(resp.register[24],8) ? nthBit(resp.register[24],8) : 0); // ClFrIg 609
            status_fire.push(nthBit(resp.register[24],9) ? nthBit(resp.register[24],9) : 0); // ClFrIg 610
            status_fire.push(nthBit(resp.register[24],10) ? nthBit(resp.register[24],10) : 0); // ClFrIg 611
            status_fire.push(nthBit(resp.register[24],11) ? nthBit(resp.register[24],11) : 0); // ClFrIg 612
            status_fire.push(nthBit(resp.register[24],12) ? nthBit(resp.register[24],12) : 0); // ClFrIg 613
            status_fire.push(nthBit(resp.register[24],13) ? nthBit(resp.register[24],13) : 0); // ClFrIg 614
            status_fire.push(nthBit(resp.register[24],14) ? nthBit(resp.register[24],14) : 0); // ClFrIg 615
            status_fire.push(nthBit(resp.register[24],15) ? nthBit(resp.register[24],15) : 0); // ClFrIg 616
            status_fire.push(nthBit(resp.register[25],0) ? nthBit(resp.register[25],0) : 0); // ClFrIg 617
            status_fire.push(nthBit(resp.register[25],1) ? nthBit(resp.register[25],1) : 0); // ClFrIg 618
            status_fire.push(nthBit(resp.register[25],2) ? nthBit(resp.register[25],2) : 0); // ClFrIg 619
            status_fire.push(nthBit(resp.register[25],3) ? nthBit(resp.register[25],3) : 0); // ClFrIg 620
            status_fire.push(nthBit(resp.register[25],4) ? nthBit(resp.register[25],4) : 0); // ClFrIg 621
            status_fire.push(nthBit(resp.register[25],5) ? nthBit(resp.register[25],5) : 0); // ClFrIg 622
            status_fire.push(nthBit(resp.register[25],6) ? nthBit(resp.register[25],6) : 0); // ClFrIg 623
            status_fire.push(nthBit(resp.register[25],7) ? nthBit(resp.register[25],7) : 0); // ClFrIg 624
            status_fire.push(nthBit(resp.register[25],8) ? nthBit(resp.register[25],8) : 0); // ClFrIg 625
            status_fire.push(nthBit(resp.register[25],9) ? nthBit(resp.register[25],9) : 0); // ClFrIg 626
            status_fire.push(nthBit(resp.register[25],10) ? nthBit(resp.register[25],10) : 0); // ClFrIg 627


            //Burner Fault Status
            status_fire.push(nthBit(resp.register[26],0) ? nthBit(resp.register[26],0) : 0); // BurnerFault 601
            status_fire.push(nthBit(resp.register[26],1) ? nthBit(resp.register[26],1) : 0); // BurnerFault 602
            status_fire.push(nthBit(resp.register[26],2) ? nthBit(resp.register[26],2) : 0); // BurnerFault 603
            status_fire.push(nthBit(resp.register[26],3) ? nthBit(resp.register[26],3) : 0); // BurnerFault 604
            status_fire.push(nthBit(resp.register[26],4) ? nthBit(resp.register[26],4) : 0); // BurnerFault 605
            status_fire.push(nthBit(resp.register[26],5) ? nthBit(resp.register[26],5) : 0); // BurnerFault 606
            status_fire.push(nthBit(resp.register[26],6) ? nthBit(resp.register[26],6) : 0); // BurnerFault 607
            status_fire.push(nthBit(resp.register[26],7) ? nthBit(resp.register[26],7) : 0); // BurnerFault 608
            status_fire.push(nthBit(resp.register[26],8) ? nthBit(resp.register[26],8) : 0); // BurnerFault 609
            status_fire.push(nthBit(resp.register[26],9) ? nthBit(resp.register[26],9) : 0); // BurnerFault 610
            status_fire.push(nthBit(resp.register[26],10) ? nthBit(resp.register[26],10) : 0); // BurnerFault 611
            status_fire.push(nthBit(resp.register[26],11) ? nthBit(resp.register[26],11) : 0); // BurnerFault 612
            status_fire.push(nthBit(resp.register[26],12) ? nthBit(resp.register[26],12) : 0); // BurnerFault 613
            status_fire.push(nthBit(resp.register[26],13) ? nthBit(resp.register[26],13) : 0); // BurnerFault 614
            status_fire.push(nthBit(resp.register[26],14) ? nthBit(resp.register[26],14) : 0); // BurnerFault 615
            status_fire.push(nthBit(resp.register[26],15) ? nthBit(resp.register[26],15) : 0); // BurnerFault 616
            status_fire.push(nthBit(resp.register[27],0) ? nthBit(resp.register[27],0) : 0); // BurnerFault 617
            status_fire.push(nthBit(resp.register[27],1) ? nthBit(resp.register[27],1) : 0); // BurnerFault 618
            status_fire.push(nthBit(resp.register[27],2) ? nthBit(resp.register[27],2) : 0); // BurnerFault 619
            status_fire.push(nthBit(resp.register[27],3) ? nthBit(resp.register[27],3) : 0); // BurnerFault 620
            status_fire.push(nthBit(resp.register[27],4) ? nthBit(resp.register[27],4) : 0); // BurnerFault 621
            status_fire.push(nthBit(resp.register[27],5) ? nthBit(resp.register[27],5) : 0); // BurnerFault 622
            status_fire.push(nthBit(resp.register[27],6) ? nthBit(resp.register[27],6) : 0); // BurnerFault 623
            status_fire.push(nthBit(resp.register[27],7) ? nthBit(resp.register[27],7) : 0); // BurnerFault 624
            status_fire.push(nthBit(resp.register[27],8) ? nthBit(resp.register[27],8) : 0); // BurnerFault 625
            status_fire.push(nthBit(resp.register[27],9) ? nthBit(resp.register[27],9) : 0); // BurnerFault 626
            status_fire.push(nthBit(resp.register[27],10) ? nthBit(resp.register[27],10) : 0); // BurnerFault 627


            //Burner Flame Status
            status_fire.push(nthBit(resp.register[28],0) ? nthBit(resp.register[28],0) : 0); // BurnerFlame 601
            status_fire.push(nthBit(resp.register[28],1) ? nthBit(resp.register[28],1) : 0); // BurnerFlame 602
            status_fire.push(nthBit(resp.register[28],2) ? nthBit(resp.register[28],2) : 0); // BurnerFlame 603
            status_fire.push(nthBit(resp.register[28],3) ? nthBit(resp.register[28],3) : 0); // BurnerFlame 604
            status_fire.push(nthBit(resp.register[28],4) ? nthBit(resp.register[28],4) : 0); // BurnerFlame 605
            status_fire.push(nthBit(resp.register[28],5) ? nthBit(resp.register[28],5) : 0); // BurnerFlame 606
            status_fire.push(nthBit(resp.register[28],6) ? nthBit(resp.register[28],6) : 0); // BurnerFlame 607
            status_fire.push(nthBit(resp.register[28],7) ? nthBit(resp.register[28],7) : 0); // BurnerFlame 608
            status_fire.push(nthBit(resp.register[28],8) ? nthBit(resp.register[28],8) : 0); // BurnerFlame 609
            status_fire.push(nthBit(resp.register[28],9) ? nthBit(resp.register[28],9) : 0); // BurnerFlame 610
            status_fire.push(nthBit(resp.register[28],10) ? nthBit(resp.register[28],10) : 0); // BurnerFlame 611
            status_fire.push(nthBit(resp.register[28],11) ? nthBit(resp.register[28],11) : 0); // BurnerFlame 612
            status_fire.push(nthBit(resp.register[28],12) ? nthBit(resp.register[28],12) : 0); // BurnerFlame 613
            status_fire.push(nthBit(resp.register[28],13) ? nthBit(resp.register[28],13) : 0); // BurnerFlame 614
            status_fire.push(nthBit(resp.register[28],14) ? nthBit(resp.register[28],14) : 0); // BurnerFlame 615
            status_fire.push(nthBit(resp.register[28],15) ? nthBit(resp.register[28],15) : 0); // BurnerFlame 616
            status_fire.push(nthBit(resp.register[29],0) ? nthBit(resp.register[29],0) : 0); // BurnerFlame 617
            status_fire.push(nthBit(resp.register[29],1) ? nthBit(resp.register[29],1) : 0); // BurnerFlame 618
            status_fire.push(nthBit(resp.register[29],2) ? nthBit(resp.register[29],2) : 0); // BurnerFlame 619
            status_fire.push(nthBit(resp.register[29],3) ? nthBit(resp.register[29],3) : 0); // BurnerFlame 620
            status_fire.push(nthBit(resp.register[29],4) ? nthBit(resp.register[29],4) : 0); // BurnerFlame 621
            status_fire.push(nthBit(resp.register[29],5) ? nthBit(resp.register[29],5) : 0); // BurnerFlame 622
            status_fire.push(nthBit(resp.register[29],6) ? nthBit(resp.register[29],6) : 0); // BurnerFlame 623
            status_fire.push(nthBit(resp.register[29],7) ? nthBit(resp.register[29],7) : 0); // BurnerFlame 624
            status_fire.push(nthBit(resp.register[29],8) ? nthBit(resp.register[29],8) : 0); // BurnerFlame 625
            status_fire.push(nthBit(resp.register[29],9) ? nthBit(resp.register[29],9) : 0); // BurnerFlame 626
            status_fire.push(nthBit(resp.register[29],10) ? nthBit(resp.register[29],10) : 0); // BurnerFlame 627


            totalStatus = [ 
                            status_fire
                          ];

            totalStatus = bool2int(totalStatus);

            if (firedevStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
            }

            firedevStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            firesysStatus = [{
                            "***************************DEVICE AIRLIFTS STATUS**************************" : "1",
                            "Out_DeviceLift AirValve": status_fire[0],
                            "Out_FirePilot AirValve": status_fire[1],
                            "Out_WaterLift AirValve": status_fire[2],
                            "***************************VALVE STATUS***************************" : "2",
                            "ZSO 6501 Gasvalve Open": status_fire[3],
                            "ZSC 6501 Gasvalve Closed": status_fire[4],
                            "ZSO 6502 Gasvalve Open": status_fire[5],
                            "ZSC 6502 Gasvalve Closed": status_fire[6],
                            "ZSC 6503 Gasvalve Closed": status_fire[7],
                            "ZSC 6504 Gasvalve Closed": status_fire[8],
                            "PSL Fault": status_fire[9],
                            "PSH Fault": status_fire[10],
                            "***************************SS INLET OUTLET PRESSURE STATUS***************************" : "3",
                            "PT6501 ChannelFault": status_fire[11],
                            "SPP601 AboveHi": status_fire[12],
                            "SPP602 BelowL": status_fire[13],
                            "PT6502 ChannelFault": status_fire[14],
                            "PT6502 AboveHi": status_fire[15],
                            "PT6502 BelowL": status_fire[16],
                            "***************************FIRE SHOOTERT LIFT STATUS***************************" : "4",
                            "YS6101 Fire Enable": status_fire[17],
                            "FS601 RaiseError": status_fire[18],
                            "FS601 LowerError": status_fire[19],
                            "FS601 Raised": status_fire[20],
                            "FS602 RaiseError": status_fire[21],
                            "FS602 LowerError": status_fire[22],
                            "FS602 Raised": status_fire[23],
                            "FS603 RaiseError": status_fire[24],
                            "FS603 LowerError": status_fire[25],
                            "FS603 Raised": status_fire[26],
                            "FS604 RaiseError": status_fire[27],
                            "FS604 LowerError": status_fire[28],
                            "FS604 Raised": status_fire[29],
                            "FS605 RaiseError": status_fire[30],
                            "FS605 LowerError": status_fire[31],
                            "FS605 Raised": status_fire[32],
                            "FS606 RaiseError": status_fire[33],
                            "FS606 LowerError": status_fire[34],
                            "FS606 Raised": status_fire[35],
                            "FS607 RaiseError": status_fire[36],
                            "FS607 LowerError": status_fire[37],
                            "FS607 Raised": status_fire[38],
                            "FS608 RaiseError": status_fire[39],
                            "FS608 LowerError": status_fire[40],
                            "FS608 Raised": status_fire[41],
                            "FS609 RaiseError": status_fire[42],
                            "FS609 LowerError": status_fire[43],
                            "FS609 Raised": status_fire[44],
                            "FS610 RaiseError": status_fire[45],
                            "FS610 LowerError": status_fire[46],
                            "FS610 Raised": status_fire[47],
                            "FS611 RaiseError": status_fire[48],
                            "FS611 LowerError": status_fire[49],
                            "FS611 Raised": status_fire[50],
                            "FS612 RaiseError": status_fire[51],
                            "FS612 LowerError": status_fire[52],
                            "FS612 Raised": status_fire[53],
                            "FS613 RaiseError": status_fire[54],
                            "FS613 LowerError": status_fire[55],
                            "FS613 Raised": status_fire[56],
                            "FS614 RaiseError": status_fire[57],
                            "FS614 LowerError": status_fire[58],
                            "FS614 Raised": status_fire[59],
                            "FS615 RaiseError": status_fire[60],
                            "FS615 LowerError": status_fire[61],
                            "FS615 Raised": status_fire[62],
                            "FS616 RaiseError": status_fire[63],
                            "FS616 LowerError": status_fire[64],
                            "FS616 Raised": status_fire[65],
                            "FS617 RaiseError": status_fire[66],
                            "FS617 LowerError": status_fire[67],
                            "FS617 Raised": status_fire[68],
                            "FS618 RaiseError": status_fire[69],
                            "FS618 LowerError": status_fire[70],
                            "FS618 Raised": status_fire[71],
                            "FS619 RaiseError": status_fire[72],
                            "FS619 LowerError": status_fire[73],
                            "FS619 Raised": status_fire[74],
                            "FS620 RaiseError": status_fire[75],
                            "FS620 LowerError": status_fire[76],
                            "FS620 Raised": status_fire[77],
                            "FS621 RaiseError": status_fire[78],
                            "FS621 LowerError": status_fire[79],
                            "FS621 Raised": status_fire[80],
                            "FS622 RaiseError": status_fire[81],
                            "FS622 LowerError": status_fire[82],
                            "FS622 Raised": status_fire[83],
                            "FS623 RaiseError": status_fire[84],
                            "FS623 LowerError": status_fire[85],
                            "FS623 Raised": status_fire[86],
                            "FS624 RaiseError": status_fire[87],
                            "FS624 LowerError": status_fire[88],
                            "FS624 Raised": status_fire[89],
                            "FS625 RaiseError": status_fire[90],
                            "FS625 LowerError": status_fire[91],
                            "FS625 Raised": status_fire[92],
                            "FS626 RaiseError": status_fire[93],
                            "FS626 LowerError": status_fire[94],
                            "FS626 Raised": status_fire[95],
                            "FS627 RaiseError": status_fire[96],
                            "FS627 LowerError": status_fire[97],
                            "FS627 Raised": status_fire[98],
                            "****************************OARSMAN GFCI STATUS********************" : "5",
                            "Oarsman VFD 601 GFCI Tripped": status_fire[99],
                            "Oarsman VFD 602 GFCI Tripped": status_fire[100],
                            "Oarsman VFD 603 GFCI Tripped": status_fire[101],
                            "Oarsman VFD 604 GFCI Tripped": status_fire[102],
                            "Oarsman VFD 605 GFCI Tripped": status_fire[103],
                            "Oarsman VFD 606 GFCI Tripped": status_fire[104],
                            "Oarsman VFD 607 GFCI Tripped": status_fire[105],
                            "Oarsman VFD 608 GFCI Tripped": status_fire[106],
                            "Oarsman VFD 609 GFCI Tripped": status_fire[107],
                            "Oarsman VFD 610 GFCI Tripped": status_fire[108],
                            "Oarsman VFD 611 GFCI Tripped": status_fire[109],
                            "Oarsman VFD 612 GFCI Tripped": status_fire[110],
                            "Oarsman VFD 613 GFCI Tripped": status_fire[111],
                            "Oarsman VFD 614 GFCI Tripped": status_fire[112],
                            "Oarsman VFD 615 GFCI Tripped": status_fire[113],
                            "Oarsman VFD 616 GFCI Tripped": status_fire[114],
                            "Oarsman VFD 617 GFCI Tripped": status_fire[115],
                            "Oarsman VFD 618 GFCI Tripped": status_fire[116],
                            "Oarsman VFD 619 GFCI Tripped": status_fire[117],
                            "Oarsman VFD 620 GFCI Tripped": status_fire[118],
                            "****************************CALL FOR IGNITION STATUS********************" : "6",
                            "Call For Ignition BC 601": status_fire[119],
                            "Call For Ignition BC 602": status_fire[120],
                            "Call For Ignition BC 603": status_fire[121],
                            "Call For Ignition BC 604": status_fire[122],
                            "Call For Ignition BC 605": status_fire[123],
                            "Call For Ignition BC 606": status_fire[124],
                            "Call For Ignition BC 607": status_fire[125],
                            "Call For Ignition BC 608": status_fire[126],
                            "Call For Ignition BC 609": status_fire[127],
                            "Call For Ignition BC 610": status_fire[128],
                            "Call For Ignition BC 611": status_fire[129],
                            "Call For Ignition BC 612": status_fire[130],
                            "Call For Ignition BC 613": status_fire[131],
                            "Call For Ignition BC 614": status_fire[132],
                            "Call For Ignition BC 615": status_fire[133],
                            "Call For Ignition BC 616": status_fire[134],
                            "Call For Ignition BC 617": status_fire[135],
                            "Call For Ignition BC 618": status_fire[136],
                            "Call For Ignition BC 619": status_fire[137],
                            "Call For Ignition BC 620": status_fire[138],
                            "Call For Ignition BC 621": status_fire[139],
                            "Call For Ignition BC 622": status_fire[140],
                            "Call For Ignition BC 623": status_fire[141],
                            "Call For Ignition BC 624": status_fire[142],
                            "Call For Ignition BC 625": status_fire[143],
                            "Call For Ignition BC 626": status_fire[144],
                            "Call For Ignition BC 627": status_fire[145],
                            "****************************BC FAULT STATUS*****************" : "7",
                            "BC Fault Status BC 601": status_fire[146],
                            "BC Fault Status BC 602": status_fire[147],
                            "BC Fault Status BC 603": status_fire[148],
                            "BC Fault Status BC 604": status_fire[149],
                            "BC Fault Status BC 605": status_fire[150],
                            "BC Fault Status BC 606": status_fire[151],
                            "BC Fault Status BC 607": status_fire[152],
                            "BC Fault Status BC 608": status_fire[153],
                            "BC Fault Status BC 609": status_fire[154],
                            "BC Fault Status BC 610": status_fire[155],
                            "BC Fault Status BC 611": status_fire[156],
                            "BC Fault Status BC 612": status_fire[157],
                            "BC Fault Status BC 613": status_fire[158],
                            "BC Fault Status BC 614": status_fire[159],
                            "BC Fault Status BC 615": status_fire[160],
                            "BC Fault Status BC 616": status_fire[161],
                            "BC Fault Status BC 617": status_fire[162],
                            "BC Fault Status BC 618": status_fire[163],
                            "BC Fault Status BC 619": status_fire[164],
                            "BC Fault Status BC 620": status_fire[165],
                            "BC Fault Status BC 621": status_fire[166],
                            "BC Fault Status BC 622": status_fire[167],
                            "BC Fault Status BC 623": status_fire[168],
                            "BC Fault Status BC 624": status_fire[169],
                            "BC Fault Status BC 625": status_fire[170],
                            "BC Fault Status BC 626": status_fire[171],
                            "BC Fault Status BC 627": status_fire[172],
                            "****************************BC FLAME STATUS*****************" : "8",
                            "BC Flame Status BC 601": status_fire[173],
                            "BC Flame Status BC 602": status_fire[174],
                            "BC Flame Status BC 603": status_fire[175],
                            "BC Flame Status BC 604": status_fire[176],
                            "BC Flame Status BC 605": status_fire[177],
                            "BC Flame Status BC 606": status_fire[178],
                            "BC Flame Status BC 607": status_fire[179],
                            "BC Flame Status BC 608": status_fire[180],
                            "BC Flame Status BC 609": status_fire[181],
                            "BC Flame Status BC 610": status_fire[182],
                            "BC Flame Status BC 611": status_fire[183],
                            "BC Flame Status BC 612": status_fire[184],
                            "BC Flame Status BC 613": status_fire[185],
                            "BC Flame Status BC 614": status_fire[186],
                            "BC Flame Status BC 615": status_fire[187],
                            "BC Flame Status BC 616": status_fire[188],
                            "BC Flame Status BC 617": status_fire[189],
                            "BC Flame Status BC 618": status_fire[190],
                            "BC Flame Status BC 619": status_fire[191],
                            "BC Flame Status BC 620": status_fire[192],
                            "BC Flame Status BC 621": status_fire[193],
                            "BC Flame Status BC 622": status_fire[194],
                            "BC Flame Status BC 623": status_fire[195],
                            "BC Flame Status BC 624": status_fire[196],
                            "BC Flame Status BC 625": status_fire[197],
                            "BC Flame Status BC 626": status_fire[198],
                            "BC Flame Status BC 627": status_fire[199],
                        }];
        }
    });//end of first PLC modbus call
}

// compares current state to previous state to log differences
function logChanges(currentState){
    // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
    // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
    // pattern of statements must match devStatus and totalStatus format
    var statements=[

        [   // firedevices - atho
            {"yes":"ATHO - Open: Out_DeviceLift AirValve","no":"ATHO - Close: Out_DeviceLift AirValve"},
            {"yes":"ATHO - Open: Out_FirePilot AirValve","no":"ATHO - Close: Out_FirePilot AirValve"},
            {"yes":"ATHO - Open: Out_WaterLift AirValve","no":"ATHO - Close: Out_WaterLift AirValve"},

            {"yes":"ATHO - 1: ZSO 6501 Gasvalve","no":"ATHO - 0: ZSO 6501 Gasvalve"},
            {"yes":"ATHO - 1: ZSC 6501 Gasvalve","no":"ATHO - 0: ZSC 6501 Gasvalve"},
            {"yes":"ATHO - 1: ZSO 6502 Gasvalve","no":"ATHO - 0: ZSO 6502 Gasvalve"},
            {"yes":"ATHO - 1: ZSC 6502 Gasvalve","no":"ATHO - 0: ZSC 6502 Gasvalve"},
            {"yes":"ATHO - 1: ZSC 6503 Gasvalve","no":"ATHO - 0: ZSC 6503 Gasvalve"},
            {"yes":"ATHO - 1: ZSC 6504 Gasvalve","no":"ATHO - 0: ZSC 6504 Gasvalve"},
            {"yes":"ATHO - PSL Faulted","no":"ATHO - Resolved: PSL Fault"},
            {"yes":"ATHO - PSH Faulted","no":"ATHO - Resolved: PSH Fault"},

            {"yes":"ATHO - PT6501 ChannelFault","no":"ATHO - Resolved: PT6501 ChannelFault"},
            {"yes":"ATHO - PT6501 AboveHi","no":"ATHO - Resolved: PT6501 AboveHi"},
            {"yes":"ATHO - PT6501 BelowL","no":"ATHO - Resolved: PT6501 BelowL"},
            {"yes":"ATHO - PT6502 ChannelFault","no":"ATHO - Resolved: PT6502 ChannelFault"},
            {"yes":"ATHO - PT6502 AboveHi","no":"ATHO - Resolved: PT6502 AboveHi"},
            {"yes":"ATHO - PT6502 BelowL","no":"ATHO - Resolved: PT6502 BelowL"},

            {"yes":"ATHO - YS6101 Fire Enabled","no":"ATHO - YS6101 Fire Disabled"},

            {"yes":"ATHO - Lift FS601 RaiseError","no":"ATHO - Resolved: Lift FS601 RaiseError"},
            {"yes":"ATHO - Lift FS601 LowerError","no":"ATHO - Resolved: Lift FS601 LowerError"},
            {"yes":"ATHO - Lift FS601 Raised","no":"ATHO - Resolved: Lift FS601 Lowered"},
            
            {"yes":"ATHO - Lift FS602 RaiseError","no":"ATHO - Resolved: Lift FS602 RaiseError"},
            {"yes":"ATHO - Lift FS602 LowerError","no":"ATHO - Resolved: Lift FS602 LowerError"},
            {"yes":"ATHO - Lift FS602 Raised","no":"ATHO - Resolved: Lift FS602 Lowered"},
            
            {"yes":"ATHO - Lift FS603 RaiseError","no":"ATHO - Resolved: Lift FS603 RaiseError"},
            {"yes":"ATHO - Lift FS603 LowerError","no":"ATHO - Resolved: Lift FS603 LowerError"},
            {"yes":"ATHO - Lift FS603 Raised","no":"ATHO - Resolved: Lift FS603 Lowered"},
            
            {"yes":"ATHO - Lift FS604 RaiseError","no":"ATHO - Resolved: Lift FS604 RaiseError"},
            {"yes":"ATHO - Lift FS604 LowerError","no":"ATHO - Resolved: Lift FS604 LowerError"},
            {"yes":"ATHO - Lift FS604 Raised","no":"ATHO - Resolved: Lift FS604 Lowered"},
            
            {"yes":"ATHO - Lift FS605 RaiseError","no":"ATHO - Resolved: Lift FS605 RaiseError"},
            {"yes":"ATHO - Lift FS605 LowerError","no":"ATHO - Resolved: Lift FS605 LowerError"},
            {"yes":"ATHO - Lift FS605 Raised","no":"ATHO - Resolved: Lift FS605 Lowered"},
            
            {"yes":"ATHO - Lift FS606 RaiseError","no":"ATHO - Resolved: Lift FS606 RaiseError"},
            {"yes":"ATHO - Lift FS606 LowerError","no":"ATHO - Resolved: Lift FS606 LowerError"},
            {"yes":"ATHO - Lift FS606 Raised","no":"ATHO - Resolved: Lift FS606 Lowered"},
            
            {"yes":"ATHO - Lift FS607 RaiseError","no":"ATHO - Resolved: Lift FS607 RaiseError"},
            {"yes":"ATHO - Lift FS607 LowerError","no":"ATHO - Resolved: Lift FS607 LowerError"},
            {"yes":"ATHO - Lift FS607 Raised","no":"ATHO - Resolved: Lift FS607 Lowered"},
            
            {"yes":"ATHO - Lift FS608 RaiseError","no":"ATHO - Resolved: Lift FS608 RaiseError"},
            {"yes":"ATHO - Lift FS608 LowerError","no":"ATHO - Resolved: Lift FS608 LowerError"},
            {"yes":"ATHO - Lift FS608 Raised","no":"ATHO - Resolved: Lift FS608 Lowered"},
            
            {"yes":"ATHO - Lift FS609 RaiseError","no":"ATHO - Resolved: Lift FS609 RaiseError"},
            {"yes":"ATHO - Lift FS609 LowerError","no":"ATHO - Resolved: Lift FS609 LowerError"},
            {"yes":"ATHO - Lift FS609 Raised","no":"ATHO - Resolved: Lift FS609 Lowered"},
            
            {"yes":"ATHO - Lift FS610 RaiseError","no":"ATHO - Resolved: Lift FS610 RaiseError"},
            {"yes":"ATHO - Lift FS610 LowerError","no":"ATHO - Resolved: Lift FS610 LowerError"},
            {"yes":"ATHO - Lift FS610 Raised","no":"ATHO - Resolved: Lift FS610 Lowered"},
            
            {"yes":"ATHO - Lift FS611 RaiseError","no":"ATHO - Resolved: Lift FS611 RaiseError"},
            {"yes":"ATHO - Lift FS611 LowerError","no":"ATHO - Resolved: Lift FS611 LowerError"},
            {"yes":"ATHO - Lift FS611 Raised","no":"ATHO - Resolved: Lift FS611 Lowered"},
            
            {"yes":"ATHO - Lift FS612 RaiseError","no":"ATHO - Resolved: Lift FS612 RaiseError"},
            {"yes":"ATHO - Lift FS612 LowerError","no":"ATHO - Resolved: Lift FS612 LowerError"},
            {"yes":"ATHO - Lift FS612 Raised","no":"ATHO - Resolved: Lift FS612 Lowered"},
            
            {"yes":"ATHO - Lift FS613 RaiseError","no":"ATHO - Resolved: Lift FS613 RaiseError"},
            {"yes":"ATHO - Lift FS613 LowerError","no":"ATHO - Resolved: Lift FS613 LowerError"},
            {"yes":"ATHO - Lift FS613 Raised","no":"ATHO - Resolved: Lift FS613 Lowered"},
            
            {"yes":"ATHO - Lift FS614 RaiseError","no":"ATHO - Resolved: Lift FS614 RaiseError"},
            {"yes":"ATHO - Lift FS614 LowerError","no":"ATHO - Resolved: Lift FS614 LowerError"},
            {"yes":"ATHO - Lift FS614 Raised","no":"ATHO - Resolved: Lift FS614 Lowered"},
            
            {"yes":"ATHO - Lift FS615 RaiseError","no":"ATHO - Resolved: Lift FS615 RaiseError"},
            {"yes":"ATHO - Lift FS615 LowerError","no":"ATHO - Resolved: Lift FS615 LowerError"},
            {"yes":"ATHO - Lift FS615 Raised","no":"ATHO - Resolved: Lift FS615 Lowered"},
            
            {"yes":"ATHO - Lift FS616 RaiseError","no":"ATHO - Resolved: Lift FS616 RaiseError"},
            {"yes":"ATHO - Lift FS616 LowerError","no":"ATHO - Resolved: Lift FS616 LowerError"},
            {"yes":"ATHO - Lift FS616 Raised","no":"ATHO - Resolved: Lift FS616 Lowered"},
            
            {"yes":"ATHO - Lift FS617 RaiseError","no":"ATHO - Resolved: Lift FS617 RaiseError"},
            {"yes":"ATHO - Lift FS617 LowerError","no":"ATHO - Resolved: Lift FS617 LowerError"},
            {"yes":"ATHO - Lift FS617 Raised","no":"ATHO - Resolved: Lift FS617 Lowered"},
            
            {"yes":"ATHO - Lift FS618 RaiseError","no":"ATHO - Resolved: Lift FS618 RaiseError"},
            {"yes":"ATHO - Lift FS618 LowerError","no":"ATHO - Resolved: Lift FS618 LowerError"},
            {"yes":"ATHO - Lift FS618 Raised","no":"ATHO - Resolved: Lift FS618 Lowered"},
            
            {"yes":"ATHO - Lift FS619 RaiseError","no":"ATHO - Resolved: Lift FS619 RaiseError"},
            {"yes":"ATHO - Lift FS619 LowerError","no":"ATHO - Resolved: Lift FS619 LowerError"},
            {"yes":"ATHO - Lift FS619 Raised","no":"ATHO - Resolved: Lift FS619 Lowered"},
            
            {"yes":"ATHO - Lift FS620 RaiseError","no":"ATHO - Resolved: Lift FS620 RaiseError"},
            {"yes":"ATHO - Lift FS620 LowerError","no":"ATHO - Resolved: Lift FS620 LowerError"},
            {"yes":"ATHO - Lift FS620 Raised","no":"ATHO - Resolved: Lift FS620 Lowered"},
            
            {"yes":"ATHO - Lift FS621 RaiseError","no":"ATHO - Resolved: Lift FS621 RaiseError"},
            {"yes":"ATHO - Lift FS621 LowerError","no":"ATHO - Resolved: Lift FS621 LowerError"},
            {"yes":"ATHO - Lift FS621 Raised","no":"ATHO - Resolved: Lift FS621 Lowered"},
            
            {"yes":"ATHO - Lift FS622 RaiseError","no":"ATHO - Resolved: Lift FS622 RaiseError"},
            {"yes":"ATHO - Lift FS622 LowerError","no":"ATHO - Resolved: Lift FS622 LowerError"},
            {"yes":"ATHO - Lift FS622 Raised","no":"ATHO - Resolved: Lift FS622 Lowered"},
            
            {"yes":"ATHO - Lift FS623 RaiseError","no":"ATHO - Resolved: Lift FS623 RaiseError"},
            {"yes":"ATHO - Lift FS623 LowerError","no":"ATHO - Resolved: Lift FS623 LowerError"},
            {"yes":"ATHO - Lift FS623 Raised","no":"ATHO - Resolved: Lift FS623 Lowered"},
            
            {"yes":"ATHO - Lift FS624 RaiseError","no":"ATHO - Resolved: Lift FS624 RaiseError"},
            {"yes":"ATHO - Lift FS624 LowerError","no":"ATHO - Resolved: Lift FS624 LowerError"},
            {"yes":"ATHO - Lift FS624 Raised","no":"ATHO - Resolved: Lift FS624 Lowered"},
            
            {"yes":"ATHO - Lift FS625 RaiseError","no":"ATHO - Resolved: Lift FS625 RaiseError"},
            {"yes":"ATHO - Lift FS625 LowerError","no":"ATHO - Resolved: Lift FS625 LowerError"},
            {"yes":"ATHO - Lift FS625 Raised","no":"ATHO - Resolved: Lift FS625 Lowered"},
            
            {"yes":"ATHO - Lift FS626 RaiseError","no":"ATHO - Resolved: Lift FS626 RaiseError"},
            {"yes":"ATHO - Lift FS626 LowerError","no":"ATHO - Resolved: Lift FS626 LowerError"},
            {"yes":"ATHO - Lift FS626 Raised","no":"ATHO - Resolved: Lift FS626 Lowered"},
            
            {"yes":"ATHO - Lift FS627 RaiseError","no":"ATHO - Resolved: Lift FS627 RaiseError"},
            {"yes":"ATHO - Lift FS627 LowerError","no":"ATHO - Resolved: Lift FS627 LowerError"},
            {"yes":"ATHO - Lift FS627 Raised","no":"ATHO - Resolved: Lift FS627 Lowered"},

            {"yes":"ATHO - Oarsman 601 GFCI Tripped","no":"ATHO - Oarsman 601 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 602 GFCI Tripped","no":"ATHO - Oarsman 602 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 603 GFCI Tripped","no":"ATHO - Oarsman 603 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 604 GFCI Tripped","no":"ATHO - Oarsman 604 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 605 GFCI Tripped","no":"ATHO - Oarsman 605 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 606 GFCI Tripped","no":"ATHO - Oarsman 606 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 607 GFCI Tripped","no":"ATHO - Oarsman 607 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 608 GFCI Tripped","no":"ATHO - Oarsman 608 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 609 GFCI Tripped","no":"ATHO - Oarsman 609 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 610 GFCI Tripped","no":"ATHO - Oarsman 610 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 611 GFCI Tripped","no":"ATHO - Oarsman 611 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 612 GFCI Tripped","no":"ATHO - Oarsman 612 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 613 GFCI Tripped","no":"ATHO - Oarsman 613 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 614 GFCI Tripped","no":"ATHO - Oarsman 614 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 615 GFCI Tripped","no":"ATHO - Oarsman 615 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 616 GFCI Tripped","no":"ATHO - Oarsman 616 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 617 GFCI Tripped","no":"ATHO - Oarsman 617 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 618 GFCI Tripped","no":"ATHO - Oarsman 618 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 619 GFCI Tripped","no":"ATHO - Oarsman 619 GFCI NOT Tripped"},
            {"yes":"ATHO - Oarsman 620 GFCI Tripped","no":"ATHO - Oarsman 620 GFCI NOT Tripped"},

            {"yes":"ATHO - Call For Ignition BC601 ON","no":"ATHO - Call For Ignition BC601 OFF"},
            {"yes":"ATHO - Call For Ignition BC602 ON","no":"ATHO - Call For Ignition BC602 OFF"},
            {"yes":"ATHO - Call For Ignition BC603 ON","no":"ATHO - Call For Ignition BC603 OFF"},
            {"yes":"ATHO - Call For Ignition BC604 ON","no":"ATHO - Call For Ignition BC604 OFF"},
            {"yes":"ATHO - Call For Ignition BC605 ON","no":"ATHO - Call For Ignition BC605 OFF"},
            {"yes":"ATHO - Call For Ignition BC606 ON","no":"ATHO - Call For Ignition BC606 OFF"},
            {"yes":"ATHO - Call For Ignition BC607 ON","no":"ATHO - Call For Ignition BC607 OFF"},
            {"yes":"ATHO - Call For Ignition BC608 ON","no":"ATHO - Call For Ignition BC608 OFF"},
            {"yes":"ATHO - Call For Ignition BC609 ON","no":"ATHO - Call For Ignition BC609 OFF"},
            {"yes":"ATHO - Call For Ignition BC610 ON","no":"ATHO - Call For Ignition BC610 OFF"},
            {"yes":"ATHO - Call For Ignition BC611 ON","no":"ATHO - Call For Ignition BC611 OFF"},
            {"yes":"ATHO - Call For Ignition BC612 ON","no":"ATHO - Call For Ignition BC612 OFF"},
            {"yes":"ATHO - Call For Ignition BC613 ON","no":"ATHO - Call For Ignition BC613 OFF"},
            {"yes":"ATHO - Call For Ignition BC614 ON","no":"ATHO - Call For Ignition BC614 OFF"},
            {"yes":"ATHO - Call For Ignition BC615 ON","no":"ATHO - Call For Ignition BC615 OFF"},
            {"yes":"ATHO - Call For Ignition BC616 ON","no":"ATHO - Call For Ignition BC616 OFF"},
            {"yes":"ATHO - Call For Ignition BC617 ON","no":"ATHO - Call For Ignition BC617 OFF"},
            {"yes":"ATHO - Call For Ignition BC618 ON","no":"ATHO - Call For Ignition BC618 OFF"},
            {"yes":"ATHO - Call For Ignition BC619 ON","no":"ATHO - Call For Ignition BC619 OFF"},
            {"yes":"ATHO - Call For Ignition BC620 ON","no":"ATHO - Call For Ignition BC620 OFF"},
            {"yes":"ATHO - Call For Ignition BC621 ON","no":"ATHO - Call For Ignition BC621 OFF"},
            {"yes":"ATHO - Call For Ignition BC622 ON","no":"ATHO - Call For Ignition BC622 OFF"},
            {"yes":"ATHO - Call For Ignition BC623 ON","no":"ATHO - Call For Ignition BC623 OFF"},
            {"yes":"ATHO - Call For Ignition BC624 ON","no":"ATHO - Call For Ignition BC624 OFF"},
            {"yes":"ATHO - Call For Ignition BC625 ON","no":"ATHO - Call For Ignition BC625 OFF"},
            {"yes":"ATHO - Call For Ignition BC626 ON","no":"ATHO - Call For Ignition BC626 OFF"},
            {"yes":"ATHO - Call For Ignition BC627 ON","no":"ATHO - Call For Ignition BC627 OFF"},


            {"yes":"ATHO - BC601 Faulted","no":"ATHO - Resolved: BC601 Fault"},
            {"yes":"ATHO - BC602 Faulted","no":"ATHO - Resolved: BC602 Fault"},
            {"yes":"ATHO - BC603 Faulted","no":"ATHO - Resolved: BC603 Fault"},
            {"yes":"ATHO - BC604 Faulted","no":"ATHO - Resolved: BC604 Fault"},
            {"yes":"ATHO - BC605 Faulted","no":"ATHO - Resolved: BC605 Fault"},
            {"yes":"ATHO - BC606 Faulted","no":"ATHO - Resolved: BC606 Fault"},
            {"yes":"ATHO - BC607 Faulted","no":"ATHO - Resolved: BC607 Fault"},
            {"yes":"ATHO - BC608 Faulted","no":"ATHO - Resolved: BC608 Fault"},
            {"yes":"ATHO - BC609 Faulted","no":"ATHO - Resolved: BC609 Fault"},
            {"yes":"ATHO - BC610 Faulted","no":"ATHO - Resolved: BC610 Fault"},
            {"yes":"ATHO - BC611 Faulted","no":"ATHO - Resolved: BC611 Fault"},
            {"yes":"ATHO - BC612 Faulted","no":"ATHO - Resolved: BC612 Fault"},
            {"yes":"ATHO - BC613 Faulted","no":"ATHO - Resolved: BC613 Fault"},
            {"yes":"ATHO - BC614 Faulted","no":"ATHO - Resolved: BC614 Fault"},
            {"yes":"ATHO - BC615 Faulted","no":"ATHO - Resolved: BC615 Fault"},
            {"yes":"ATHO - BC616 Faulted","no":"ATHO - Resolved: BC616 Fault"},
            {"yes":"ATHO - BC617 Faulted","no":"ATHO - Resolved: BC617 Fault"},
            {"yes":"ATHO - BC618 Faulted","no":"ATHO - Resolved: BC618 Fault"},
            {"yes":"ATHO - BC619 Faulted","no":"ATHO - Resolved: BC619 Fault"},
            {"yes":"ATHO - BC620 Faulted","no":"ATHO - Resolved: BC620 Fault"},
            {"yes":"ATHO - BC621 Faulted","no":"ATHO - Resolved: BC621 Fault"},
            {"yes":"ATHO - BC622 Faulted","no":"ATHO - Resolved: BC622 Fault"},
            {"yes":"ATHO - BC623 Faulted","no":"ATHO - Resolved: BC623 Fault"},
            {"yes":"ATHO - BC624 Faulted","no":"ATHO - Resolved: BC624 Fault"},
            {"yes":"ATHO - BC625 Faulted","no":"ATHO - Resolved: BC625 Fault"},
            {"yes":"ATHO - BC626 Faulted","no":"ATHO - Resolved: BC626 Fault"},
            {"yes":"ATHO - BC627 Faulted","no":"ATHO - Resolved: BC627 Fault"},

            {"yes":"ATHO - BC601 Flame ON","no":"ATHO - BC601 Flame OFF"},
            {"yes":"ATHO - BC602 Flame ON","no":"ATHO - BC602 Flame OFF"},
            {"yes":"ATHO - BC603 Flame ON","no":"ATHO - BC603 Flame OFF"},
            {"yes":"ATHO - BC604 Flame ON","no":"ATHO - BC604 Flame OFF"},
            {"yes":"ATHO - BC605 Flame ON","no":"ATHO - BC605 Flame OFF"},
            {"yes":"ATHO - BC606 Flame ON","no":"ATHO - BC606 Flame OFF"},
            {"yes":"ATHO - BC607 Flame ON","no":"ATHO - BC607 Flame OFF"},
            {"yes":"ATHO - BC608 Flame ON","no":"ATHO - BC608 Flame OFF"},
            {"yes":"ATHO - BC609 Flame ON","no":"ATHO - BC609 Flame OFF"},
            {"yes":"ATHO - BC610 Flame ON","no":"ATHO - BC610 Flame OFF"},
            {"yes":"ATHO - BC611 Flame ON","no":"ATHO - BC611 Flame OFF"},
            {"yes":"ATHO - BC612 Flame ON","no":"ATHO - BC612 Flame OFF"},
            {"yes":"ATHO - BC613 Flame ON","no":"ATHO - BC613 Flame OFF"},
            {"yes":"ATHO - BC614 Flame ON","no":"ATHO - BC614 Flame OFF"},
            {"yes":"ATHO - BC615 Flame ON","no":"ATHO - BC615 Flame OFF"},
            {"yes":"ATHO - BC616 Flame ON","no":"ATHO - BC616 Flame OFF"},
            {"yes":"ATHO - BC617 Flame ON","no":"ATHO - BC617 Flame OFF"},
            {"yes":"ATHO - BC618 Flame ON","no":"ATHO - BC618 Flame OFF"},
            {"yes":"ATHO - BC619 Flame ON","no":"ATHO - BC619 Flame OFF"},
            {"yes":"ATHO - BC620 Flame ON","no":"ATHO - BC620 Flame OFF"},
            {"yes":"ATHO - BC621 Flame ON","no":"ATHO - BC621 Flame OFF"},
            {"yes":"ATHO - BC622 Flame ON","no":"ATHO - BC622 Flame OFF"},
            {"yes":"ATHO - BC623 Flame ON","no":"ATHO - BC623 Flame OFF"},
            {"yes":"ATHO - BC624 Flame ON","no":"ATHO - BC624 Flame OFF"},
            {"yes":"ATHO - BC625 Flame ON","no":"ATHO - BC625 Flame OFF"},
            {"yes":"ATHO - BC626 Flame ON","no":"ATHO - BC626 Flame OFF"},
            {"yes":"ATHO - BC627 Flame ON","no":"ATHO - BC627 Flame OFF"},
        ]
    ];
    
    if (firedevStatus.length > 0) {
        for(var each in currentState){
            // find all indeces with values different from previous examination
            var suspects = kompare(currentState[each],firedevStatus[each]);
            for(var each2 in suspects){
                var text = (currentState[each][suspects[each2]]) ? statements[each][suspects[each2]].yes:statements[each][suspects[each2]].no;
                var description = "";
                var message = "";
                var category = "";
                if(text !== "n/a"){
                    //watchDog.eventLog('each: ' +each +' and each2: ' +each2+' and suspcts: ' +suspects);
                    watchDog.eventLog(text);
                    watchLog.eventLog(text);
                }
            }
        }
    }

}

// general function that will help DEEP compare arrays
function kompare (array1,array2) {
    var collisions = [];

    for (var i = 0, l=array1.length; i < l; i++) {
        // Check if we have nested arrays
        if (array1[i] instanceof Array && array2[i] instanceof Array) {
            // recurse into the nested arrays
            if (!kompare(array1[i],array2[i])){
                return [false];
            }
        }
        else if (array1[i] !== array2[i]) {
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            collisions.push(i);
        }
    }

    return collisions;
}

function nthBit(n,b){

    var currentBit = 1 << b;

    if (currentBit & n){
        return 1;
    }

    return 0;
}

// convert boolean to int
function bool2int(array){
    for (var each in array) {
        // Check if we have nested arrays
        if (array[each] instanceof Array) {
            // recurse into the nested arrays
            array[each] = bool2int(array[each]);
        }
        else {
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            array[each] = (array[each]) ? 1 : 0;
        }
    }
    return array;
}
}

module.exports=firestatusLogWrapper;
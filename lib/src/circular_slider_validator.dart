import 'package:flutter/material.dart';

class MinMaxAngleValidator {
  
  ///Optional, defines the minimum value the initial handler could have while getting drag
  ///when not defined, the handler can get move freely thru the slider
  ///if [iniHandlerMinValue] is set, it must be smaller than [endHandlerMinValue] unless [endHandlerMinValue] is null
  int iniHandlerMinValue;
  
  ///Optional, defines the maximum value the initial handler could have while getting drag
  ///when not defined, the handler can get move freely thru the slider
  ///if [iniHandlerMaxValue] is set, it must be smaller than [endHandlerMaxValue] unless [endHandlerMaxValue] is null
  int iniHandlerMaxValue;

  ///Optional, defines the minimum value the end handler could have while getting drag
  ///when not defined, the handler can get move freely thru the slider
  ///if [endHandlerMinValue] is set, it must be bigger than [iniHandlerMinValue] unless [iniHandlerMinValue] is null
  int endHandlerMinValue;

  ///Optional, defines the maximum value the end handler could have while getting drag
  ///when not defined, the handler can get move freely thru the slider
  ///if [endHandlerMaxValue] is set, it must be bigger than [iniHandlerMaxValue] unless [iniHandlerMaxValue] is null
  int endHandlerMaxValue;

  MinMaxAngleValidator({
    this.iniHandlerMinValue,
    this.iniHandlerMaxValue,
    this.endHandlerMinValue,
    this.endHandlerMaxValue,
  }) :
    assert((iniHandlerMinValue == null || (iniHandlerMinValue !=null && iniHandlerMinValue >=0)), "[iniHandlerMaxValue] must be equal or bigger than zero"),
    assert((iniHandlerMaxValue == null || (iniHandlerMaxValue !=null && iniHandlerMaxValue >=0)), "[iniHandlerMaxValue] must be equal or bigger than zero"),
    assert((iniHandlerMinValue ==null || endHandlerMinValue == null || (iniHandlerMinValue !=null && endHandlerMinValue !=null && iniHandlerMinValue < endHandlerMinValue)), "[endHandlerMinValue] value can not be bigger than [iniHandlerMinValue]"),
    assert((iniHandlerMaxValue ==null || endHandlerMaxValue == null || (iniHandlerMaxValue !=null && endHandlerMaxValue !=null && iniHandlerMaxValue < endHandlerMaxValue)), "[iniHandlerMaxValue] value can not be bigger than [endHandlerMaxValue]");

  bool validateIniHandler(int newValue, int initialEndHndLoc, int lastValidIniLoc, int tLaps, Function(int, int, int) onSelectionChange){
      if(iniHandlerMaxValue != null && newValue > iniHandlerMaxValue) {
          onSelectionChange(lastValidIniLoc ?? iniHandlerMaxValue, initialEndHndLoc, tLaps);
        return false;
      }

      if(iniHandlerMinValue != null && newValue < iniHandlerMinValue) {
          onSelectionChange(lastValidIniLoc ?? iniHandlerMinValue, initialEndHndLoc, tLaps);
        return false;
      }
    
    return true;    
  }

  bool validateEndHandler(int newValue, int initialIniHndLoc, int lastValidEndLoc, int tLaps, Function(int, int, int) onSelectionChange){
      if(endHandlerMaxValue != null && newValue > endHandlerMaxValue) {
          onSelectionChange(initialIniHndLoc, lastValidEndLoc ?? endHandlerMaxValue, tLaps);
          return false;
      }

      if(endHandlerMinValue != null && newValue < endHandlerMinValue) {
        onSelectionChange(initialIniHndLoc, lastValidEndLoc ?? endHandlerMinValue, tLaps);
        return false;
      }

    return true;
  }

  ///Allow us to validate if the Sweep is dragng the handler outside the valid limit
  ///
  bool validateSweepDrag({
    @required int initialIniHndLoc, @required int lastValidIniLoc, @required int newIniValue, 
    @required int initialEndHndLoc, @required int lastValidEndLoc, @required int newEndValue,  
    @required int tLaps, @required Function(int, int, int) onSelectionChange}) {
  
      var status = validateIniHandler(newIniValue, initialEndHndLoc, lastValidIniLoc, tLaps, onSelectionChange);
      
      if(status)
        status = validateEndHandler(newEndValue, initialIniHndLoc, lastValidEndLoc, tLaps, onSelectionChange); 
    
    return status;
  }
}

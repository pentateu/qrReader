
function notInApp() {
  console.log('notInApp --> navigator.userAgent');
  return navigator.userAgent.indexOf("AppGyverSteroids") === -1;
}

function pluginAvailable(){
  return cordova &&
         cordova.plugins &&
         cordova.plugins.barcodeScanner &&
         cordova.plugins.barcodeScanner.scan;
}

function onTap(element, fn){
  if(element){
    element.addEventListener("touchstart", fn, false);
  }
}

function notifyScanResult(text){
  //TODO: deliver the result ..
  document.getElementById("result").innerText = text;
}

function onScanResults(result){
  if (result.cancelled) {
    console.log('INFO: Scan action cancelled !');
  }
  notifyScanResult(result.text);
}

function onScanError(error){
  var errorMsg = error;
  if (error === "unable to obtain video capture device input") {
    errorMsg = "Could not access Camera. To fix this, switch to the Settings app, and go to:\n\n  Privacy > Camera\n\nThen, ensure the slider is enabled (green) for the Enterprise app.";
  }
  console.log('ERROR: ' + errorMsg);
  alert(errorMsg);
}

function openReader(){
  if(pluginAvailable()){
    cordova.plugins.barcodeScanner.scan(onScanResults, onScanError);
  }
  else{
    alert("Barcode Scanner Plugin not available!");
  }
}

function setupButtonLabel(btn){
  var buttonLabel = window.frameElement.getAttribute('data-button-label');
  if(btn && buttonLabel){
    btn.innerText = buttonLabel;
  }
}

document.addEventListener("DOMContentLoaded", function() {
  var btn = document.getElementById("openReaderBtn");
  if(btn){
    onTap(btn, openReader);
    setupButtonLabel(btn);
  }
  else{
    console.log('ERROR: could not find the button element.');
  }
});

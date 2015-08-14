class QRReaderModule
  notInApp: -> navigator.userAgent.indexOf("AppGyverSteroids") == -1

  pluginAvailable: -> cordova?.plugins?.barcodeScanner?.scan?

  onTap: (element, fn) -> element?.addEventListener "touchstart", fn, false

  pushFormDetail: (collection, id) -> supersonic.module.layers.push "data.#{collection}.show", { id: id }

  #TODO: add regular expression for the validation
  validCode: (code) =>
    true

  #extract the collection name and id of the item
  parseCode: (code) =>
    parts = code.split(":")
    return (parts[0], parts[1])

  processScanResult: (code) =>
    if @validCode code
      (collection, id) = @parseCode code
      @pushFormDetail collection, id
    else
      alert "Invalid code!"

  onScanResults: (result) =>
    if result.cancelled
      console.log "INFO: Scan action cancelled !"
    else
      @processScanResult result.text

  onScanError: (error) =>
    errorMsg = error
    if error == "unable to obtain video capture device input"
      errorMsg = "Could not access Camera. To fix this, switch to the Settings app, and go to:\n\n  Privacy > Camera\n\nThen, ensure the slider is enabled (green) for the Enterprise app."

    console.log "ERROR: #{errorMsg}"
    alert errorMsg

  openReader: =>
    if @notInApp()
      alert "This plugin is only supported in mobile apps."
    else if @pluginAvailable()
      cordova.plugins.barcodeScanner.scan @onScanResults, @onScanError
    else
      alert "Barcode Scanner Plugin not available!"

  setupButton: =>
    @onTap @btn, @openReader

    buttonLabel = supersonic.module.attributes.get "button-label"
    if @btn? && buttonLabel?
      @btn.innerText = buttonLabel

  start: =>
    @btn = document.querySelector "#openReaderBtn"
    if @btn?
      @setupButton()
    else
      console.log "ERROR: could not find the button element."

document.addEventListener "DOMContentLoaded", new QRReaderModule().start

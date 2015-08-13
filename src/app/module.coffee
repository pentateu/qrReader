
QR_DISPLAY_MODULE_ID = "nz.co.iswe.modules.qrdisplay"

class QRReaderModule
  notInApp: -> navigator.userAgent.indexOf("AppGyverSteroids") == -1

  pluginAvailable: -> cordova?.plugins?.barcodeScanner?.scan?

  onTap: (element, fn) -> element?.addEventListener "touchstart", fn, false

  # TODO: Parse the code to identify which form should be called
  # to display the details about this record
  parseQRCode: (text) ->

  pushFormDetail: (targetForm, recordId) -> supersonic.module.layers.push "data.#{targetForm}.show", { id: recordId }

  pushQRDisplay: (recordId) =>
    resourceInfo = supersonic.module.attributes.get "qrdisplay-resource-info"
    supersonic.module.layers.push(
      QR_DISPLAY_MODULE_ID,
      {id:recordId, "resource-info":resourceInfo}
    ).catch (error) =>
      alert "Could not show the QRDisplay module. Error: #{error}"

  notifyQRDisplay: (recordId) => supersonic.data.channel('QRDisplay-show').publish(recordId)

  processScanResult: (text) =>
    targetForm = supersonic.module.attributes.get "target-form"
    detailBehaviour = supersonic.module.attributes.get "detail-behaviour"

    if detailBehaviour == "New View - QRDisplay"
      @pushQRDisplay text
    else if detailBehaviour == "New View - Form Detail" && targetForm?
      @pushFormDetail targetForm, text
    else if detailBehaviour == "Same View - QRDisplay"
      @notifyQRDisplay text
    else
      # @parseQRCode text
      # TODO: Show Error

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
      alert "This plugin is only support in mobile apps."
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

    ##TODO: Remove the test code below
    navDisplay = document.querySelector "#navDisplay"
    @onTap navDisplay, => @pushQRDisplay "55c87f7706884a0011000004"

document.addEventListener "DOMContentLoaded", new QRReaderModule().start

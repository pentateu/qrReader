
class QRReaderModule
  notInApp: ->
    console.log "notInApp --> navigator.userAgent: #{navigator.userAgent}"
    navigator.userAgent.indexOf("AppGyverSteroids") == -1

  pluginAvailable: ->
    cordova?.plugins?.barcodeScanner?.scan?

  onTap: (element, fn) ->
    element?.addEventListener "touchstart", fn, false

  # Parse the code to identify which form should be called
  # to display the details about this record
  parseQRCode: (text) ->
    

  openDetailView: (targetForm, recordId) ->
    url = "http://localhost/views/#{targetForm}Show/index.html?id=#{recordId}&record-id=#{recordId}"
    console.log "INFO: open detail page - url: #{url}"
    supersonic.module.layers.push url
    #supersonic.module.layers.push “data.#{targetForm}.new”, { id: recordId }

  openQRDisplay: (recordId) ->
    supersonic.module.layers.push "QRDisplay", {id:recordId}

  processScanResult: (text) ->
    targetForm = supersonic.module.attributes.get "target-form"
    detailView = supersonic.module.attributes.get "detail-view"

    if detailView == "QRDisplay Module"
      @openQRDisplay text
    else if detailView == "Form Detail Page" && targetForm?
      @openDetailView targetForm, text
    else
      # @parseQRCode text
      # TODO: Show Error

  onScanResults: (result) ->
    if result.cancelled
      console.log "INFO: Scan action cancelled !"
    else
      @processScanResult result.text

  onScanError: (error) ->
    errorMsg = error
    if error == "unable to obtain video capture device input"
      errorMsg = "Could not access Camera. To fix this, switch to the Settings app, and go to:\n\n  Privacy > Camera\n\nThen, ensure the slider is enabled (green) for the Enterprise app."

    console.log "ERROR: #{errorMsg}"

    alert errorMsg

  openReader: ->
    if @notInApp()
      return alert "This plugin is only support in mobile apps."

    if @pluginAvailable()
      cordova.plugins.barcodeScanner.scan onScanResults, onScanError
    else
      alert "Barcode Scanner Plugin not available!"

  setupButtonLabel: (btn) ->
    buttonLabel = supersonic.module.attributes.get "button-label"
    if btn? && buttonLabel?
      btn.innerText = buttonLabel

  start: ->
    @btn = document.getElementById "openReaderBtn"
    if @btn?
      onTap @btn, @openReader
      @setupButtonLabel @btn
    else
      console.log "ERROR: could not find the button element."


document.addEventListener "DOMContentLoaded", new QRReaderModule().start

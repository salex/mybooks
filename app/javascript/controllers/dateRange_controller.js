import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "from_date" ,'to_date','toOptions','fromOptions','from','to']
  static values = { url: String }

  connect() {
    // dates are input objects, not value
    this.fromDate = this.from_dateTarget
    this.toDate =  this.to_dateTarget
  }

  toOption(){
    var toSel = this.toOptionsTarget
    this.toDate.value = toSel.value
    this.toTarget.value = toSel.value
  }

  fromOption() {
    var fromSel = this.fromOptionsTarget
    var toSel = this.toOptionsTarget
    var fromIndex = fromSel.selectedIndex
    this.fromDate.value = fromSel.value
    toSel.selectedIndex = fromIndex
    this.toDate.value = toSel.value
    this.toTarget.value = toSel.value
    this.fromTarget.value = fromSel.value
  }

  filter(){ // this does a turbo frame replace
    this.toTarget.value = this.toDate.value
    this.fromTarget.value = this.fromDate.value
  }

  assignPdf() { // url comes in as 'accounts//'
    location.assign(`/${this.urlValue.replace('//','/register_pdf/')}?from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

  assignSplit() {
    location.assign(`/${this.urlValue.replace('//','/split_register_pdf/')}?from=${this.fromDate.value}&to=${this.toDate.value}`)
  }

}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["year",'month'];

  connect() {
    // console.log("Hello yearMonth controller!")
 
  }
  clickHandler() {
      // console.log("Button clicked!");
      // Add your logic here
      let date = this.yearTarget.value + '/' + this.monthTarget.value + "/1"
      // console.log(date)
      location.assign(`/bank_statements/show_date?date=${date}`)
  }

}

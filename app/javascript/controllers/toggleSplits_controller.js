// hideTarget.controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // static targets = ['tbody','parent']
  connect() {
    console.log("toggle splits")
  }

  toggle() {
    console.log("toggle click")

    var toggler = event.currentTarget
    const splits = toggler.closest('tbody').nextElementSibling
    // console.log(splits)
    splits.classList.toggle('split-rows')
 
  } 

}

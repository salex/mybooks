import { Controller } from "@hotwired/stimulus"
// simple controller that toggles the show/hide class of an element 
export default class extends Controller {
// this is a little overkill, but you can use it to toggle 1 to n elements with a class
  connect() {
    // console.log("got a toggler")
  }

  toggleChild() {
    var elem = event.currentTarget
    var sum = document.getElementById('toggleMe')
    if (sum.classList.contains('hidden')) {
      sum.classList.remove('hidden')
      elem.classList.remove('fa-toggle-on')
      elem.classList.add('fa-toggle-off')
    }else{
      sum.classList.add('hidden')
      elem.classList.remove('fa-toggle-off')
      elem.classList.add('fa-toggle-on')
    }
  } 
}
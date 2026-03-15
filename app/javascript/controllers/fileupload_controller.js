import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit",'file'];

  connect() {
    console.log("Hello file_upload!")
    // console.log(this.fileTarget.value)

  }


  toggle() {
    // console.log(this.fileTarget.value)
    if (this.fileTarget.value == '') {
      this.submitTarget.classList.add('hidden')
    }else{
      console.log(this.fileTarget.value)
      this.submitTarget.classList.remove('hidden');

    }
  }

}


import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  hideMenu() {
    this.menuTarget.classList.add("hidden")
  }

  clickOutside(event) {
    const clickedInMenu = this.menuTarget.contains(event.target)

    if (!this.element.contains(event.target) || clickedInMenu) {
      this.hideMenu()
    }
  }

  connect() {
    document.addEventListener("click", this.clickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside.bind(this))
  }
}
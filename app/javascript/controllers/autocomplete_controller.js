import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "zip", "latitude", "longitude", "placeId", "label"]

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < 3) {
      this.dropdownTarget.innerHTML = ""
      return
    }

    this.showLoading()

    this.timeout = setTimeout(() => {
      fetch(`/addresses/suggestions?query=${encodeURIComponent(query)}`)
        .then(response => response.text())
        .then(html => {
          if (html.trim() === "") {
            this.showNoResults()
          } else {
            this.dropdownTarget.innerHTML = html
          }
        })
        .catch(() => this.showNoResults())
    }, 300)
  }

  select(event) {
    const { label, zip, latitude, longitude, placeid } = event.params
    
    // Two fields with same value but different purposes: visible box stays editable, hidden one is the frozen snapshot of what was actually picked
    this.inputTarget.value = label
    this.labelTarget.value = label

    this.zipTarget.value = zip
    this.latitudeTarget.value = latitude
    this.longitudeTarget.value = longitude
    this.placeIdTarget.value = placeid
    this.dropdownTarget.innerHTML = ""
  }

  showLoading() {
    this.dropdownTarget.innerHTML = `
      <div class="border rounded shadow bg-white p-3 text-gray-500 text-sm flex items-center gap-2">
        <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
        </svg>
        Searching...
      </div>
    `
  }

  showNoResults() {
    this.dropdownTarget.innerHTML = `
      <div class="border rounded shadow bg-white p-3 text-gray-500 text-sm">
        No results found
      </div>
    `
  }
}
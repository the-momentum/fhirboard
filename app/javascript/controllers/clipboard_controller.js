import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["source"]

    copy(event) {
        event.preventDefault()
        event.stopPropagation()

        navigator.clipboard.writeText(this.sourceTarget.href).then(() => {
            const originalText = this.sourceTarget.textContent
            this.sourceTarget.textContent = "Link copied!"

            setTimeout(() => {
                this.sourceTarget.textContent = originalText
            }, 2000)
        }).catch(err => {
            console.error('Failed to copy:', err)
            this.sourceTarget.textContent = "Failed to copy link"
            setTimeout(() => {
                this.sourceTarget.textContent = originalText
            }, 2000)
        })
    }
}

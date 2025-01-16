import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["link"]
    static values = {
        baseUrl: String
    }


    connect() {
        this.handleSession()
        this.updateSessionLink()
    }

    handleSession() {
        const urlParams = new URLSearchParams(window.location.search)
        let sessionToken = urlParams.get('session_token')

        if (!sessionToken) {
            sessionToken = localStorage.getItem('sessionToken')
        }

        if (sessionToken) {
            localStorage.setItem('sessionToken', sessionToken)
        }

        document.addEventListener('turbo:before-fetch-request', (event) => {
            const token = localStorage.getItem('sessionToken')
            if (token) {
                event.detail.fetchOptions.headers['X-Session-Token'] = token
            }
        })

        document.addEventListener('turbo:before-fetch-response', (event) => {
            const token = event.detail.fetchResponse.response.headers.get('X-Session-Token')
            if (token) {
                localStorage.setItem('sessionToken', token)
            }
        })
    }

    updateSessionLink() {
        if (this.hasLinkTarget) {
            const token = localStorage.getItem('sessionToken')
            if (token) {
                const url = new URL(window.location.href)
                url.searchParams.set('session_id', token)
                this.linkTarget.href = url.toString()
            }
        }
    }
}

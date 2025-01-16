import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = []

    connect() {
        this.handleSession()
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
}

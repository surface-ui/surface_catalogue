import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

function resizeIframe(iframe) {
  iframe.style.height = "0px"
  let height = iframe.contentWindow.document.documentElement.scrollHeight + 'px'
  iframe.style.height = height
}

window.togggleNode = (a) => {
  a.parentNode.querySelector('.menu-list').classList.toggle('is-hidden')
  let i = a.querySelector('span.icon > i')
  i.classList.toggle('fa-folder-open')
  i.classList.toggle('fa-folder')
}

let Hooks = {}

Hooks.EventLog = {
  updated(){
    let eventLog = this.el.parentNode
    eventLog.scrollTop = eventLog.scrollHeight
  }
}

Hooks.IframeBody = {
  mounted(){
    let iframe = this.el
    iframe.addEventListener("load", e => {
      resizeIframe(iframe)
    });
  },
  updated(){
    let iframe = this.el
    resizeIframe(iframe)
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


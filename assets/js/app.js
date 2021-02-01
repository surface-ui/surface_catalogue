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
import Prism from './prism.js';

window.togggleNode = (a) => {
  a.parentNode.querySelector('.menu-list').classList.toggle('is-hidden')
  const i = a.querySelector('span.icon > i')
  i.classList.toggle('fa-folder-open')
  i.classList.toggle('fa-folder')
}

let Hooks = {}

Hooks.EventLog = {
  updated(){
    const eventLog = this.el.parentNode
    eventLog.scrollTop = eventLog.scrollHeight
  }
}

window.handleEnableLatencySimClick = function(checkbox) {
  let socket = document.getElementById("playground-iframe").contentWindow.liveSocket
  let valueInput = document.getElementById("debug_profile_latency_sim_value")

  if (checkbox.checked) {
    valueInput.disabled = false
    let value = valueInput.value || 100
    valueInput.value = value
    socket.enableLatencySim(value)
  } else {
    socket.disableLatencySim()
    valueInput.disabled = true
  }

  updatePlaygroundTabLabel()
}

window.handleEnableDebugClick = function(checkbox) {
  let socket = document.getElementById("playground-iframe").contentWindow.liveSocket

  if (checkbox.checked) {
    socket.enableDebug()
  } else {
    socket.disableDebug()
  }
}

window.handleEnableProfileClick = function(checkbox) {
  let socket = document.getElementById("playground-iframe").contentWindow.liveSocket

  if (checkbox.checked) {
    socket.enableProfiling()
  } else {
    socket.disableProfiling()
  }
}

window.handleLatencySimValueBlur = function(input) {
  const socket = document.getElementById("playground-iframe").contentWindow.liveSocket
  const oldValue = socket.getLatencySim()

  if (input.value != oldValue) {
    const value = input.value || 1000
    input.value = value
    socket.enableLatencySim(value)
  }
}

function initDebugProfile(socket) {
  const debugProfileDiv = document.getElementById("debug-profile")
  const debugProfileDisabledDiv = document.getElementById("debug-profile-disabled")

  if (!socket) {
    debugProfileDiv.hidden = true
    debugProfileDisabledDiv.hidden = false
    return
  }

  debugProfileDiv.hidden = false
  debugProfileDisabledDiv.hidden = true

  const debugCheckbox = document.getElementById("debug_profile_enable_debug")
  debugCheckbox.checked = socket.isDebugEnabled()

  const profileCheckbox = document.getElementById("debug_profile_enable_profile")
  profileCheckbox.checked = socket.isProfileEnabled()

  const latencySimCheckbox = document.getElementById("debug_profile_enable_latency_sim")
  const latencySimInput = document.getElementById("debug_profile_latency_sim_value")
  const latencySimValue = socket.getLatencySim()

  if (latencySimValue) {
    latencySimCheckbox.checked = true
    latencySimInput.value = latencySimValue
  }
  updatePlaygroundTabLabel()
}

function updatePlaygroundTabLabel() {
  const socket = document.getElementById("playground-iframe").contentWindow.liveSocket
  const label = document.getElementById("playground-tab-label")

  if (socket.getLatencySim()) {
    label.innerHTML = 'Playground <span class="is-size-6" title="Latency simulator is enabled">⚠️</span>'
  } else {
    label.innerText = "Playground"
  }
}

function maybePatchSocket(socket) {
  if (!socket) {
    console.log("[Catalogue] window.liveSocket has not been set. Debug/Profile tab will be disabled.")
    return
  }

  if (socket.patched)
    return

  const path = socket.currentLocation.pathname
  const PHX_LV_DEBUG = `phx:live-socket:debug:${path}`
  const PHX_LV_PROFILE = `phx:live-socket:profiling:${path}`
  const PHX_LV_LATENCY_SIM = `phx:live-socket:latency-sim:${path}`

  // Latency Simulation

  socket.enableLatencySim = function(upperBoundMs){
    console.log(`latency simulator enabled as ${upperBoundMs}ms for the duration of this browser session.`)
    sessionStorage.setItem(PHX_LV_LATENCY_SIM, upperBoundMs)
  }

  socket.disableLatencySim = function(){ sessionStorage.removeItem(PHX_LV_LATENCY_SIM)}

  socket.getLatencySim = function() {
    let str = sessionStorage.getItem(PHX_LV_LATENCY_SIM)
    return str ? parseInt(str) : null
  }

  // Debug

  socket.isDebugEnabled = function(){ return sessionStorage.getItem(PHX_LV_DEBUG) === "true" }

  socket.enableDebug = function(){ sessionStorage.setItem(PHX_LV_DEBUG, "true") }

  socket.disableDebug = function(){ sessionStorage.removeItem(PHX_LV_DEBUG) }

  // Profile

  socket.isProfileEnabled = function(){ return sessionStorage.getItem(PHX_LV_PROFILE) === "true" }

  socket.enableProfiling = function(){ sessionStorage.setItem(PHX_LV_PROFILE, "true") }

  socket.disableProfiling = function(){ sessionStorage.removeItem(PHX_LV_PROFILE) }

  socket.patched = true
}

const debug = (view, kind, msg, obj) => {
  if (window.liveSocket.isDebugEnabled()) {
    console.log(`${view.id} ${kind}: ${msg} - `, obj)
  } else if (view.id == "playground") {
    maybePatchSocket(view.liveSocket)
    if (view.liveSocket.isDebugEnabled())
      console.log(`${view.id} ${kind}: ${msg} - `, obj)
  }
}

Hooks.IframeBody = {
  mounted(){
    const iframe = this.el
    iframe.addEventListener("load", e => {
      if (iframe.id == "playground-iframe") {
        const socket = iframe.contentWindow.liveSocket
        maybePatchSocket(socket)
        initDebugProfile(socket)
      }
    });
    let sendResize;
    iframe.contentWindow.addEventListener("resize", e => {
      if (iframe.id == "playground-iframe") {
        if (iframe.offsetWidth > iframe.parentElement.offsetWidth)
          iframe.style.width = "100%"

        const self = this
        clearTimeout(sendResize)
        sendResize = setTimeout(function() {
          self.pushEvent("playground_resize", {height: iframe.style.height, width: iframe.style.width})
        }, 300)
      }
    });
  }
};

Hooks.Highlight = {
  mounted() {
    Prism.highlightElement(document.getElementById(this.el.id))
  },
  updated() {
    Prism.highlightElement(document.getElementById(this.el.id))
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks, viewLogger: debug})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation
window.liveSocket = liveSocket


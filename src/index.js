
import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';



const currentLocation = window.location;
const backend_host_dev = "localhost:4000"
const backend_host_prod = "camelup.gigalixirapp.com"

const backend_host_ws = (currentLocation.hostname === "localhost") ? ("ws://" + backend_host_dev) : ("wss://" + backend_host_prod)
const backend_host_http = (currentLocation.hostname === "localhost") ? ("http://" + backend_host_dev) : ("https://" + backend_host_prod)

console.log(currentLocation);
console.log(backend_host_ws);
console.log(backend_host_http);


const { Socket } = require('phoenix-channels')


const socket = new Socket(backend_host_ws + "/socket", {
  params: { token: window.userToken },
  logger: (kind, msg, data) => { console.log('${kind}: ${msg}', data) }
})

const channel = socket.channel("games:1", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

socket.connect();

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: backend_host_http
});

import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const currentLocation_hostname = window.location.hostname;
const backend_host_dev = "localhost:4000";
const backend_host_prod = "camelup.gigalixirapp.com";

const backend_host_ws =
  currentLocation_hostname !== "camelup.zeit.sh"
    ? "ws://" + currentLocation_hostname + ":4000"
    : "wss://" + backend_host_prod;
const backend_host_http =
  currentLocation_hostname !== "camelup.zeit.sh"
    ? "http://" + backend_host_dev + ":4000"
    : "https://" + backend_host_prod;

console.log(currentLocation_hostname);
console.log(backend_host_ws);
console.log(backend_host_http);

const { Socket, Channel } = require("phoenix");

const socket = new Socket(backend_host_ws + "/socket", {
  params: { token: window.userToken },
  logger: (kind, msg, data) => {
    console.log("${kind}: ${msg}", data);
  },
});

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: backend_host_http,
});

let room = "1";
let channel = socket.channel("games:" + room);

app.ports.joinRoom.subscribe(function (room) {
  console.log(`JS will ask Phoenix to join room: `, room);
  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully room " + room, resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    })
    .receive("timeout", () =>
      console.log(
        "Networking issue trying to connect to room " +
          room +
          ". Still waiting..."
      )
    );
});

channel.on("broadcast_game_table", (payload) => {
  console.log(`JS: Receiving ${payload} game table data from Phoenix`, payload);
  app.ports.receiveGameTableFromServer.send(payload);
  console.log("JS finished sending game table to Elm");
});
// Action
socket.connect();

import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const currentLocation = window.location;
const backend_host_dev = "localhost:4000";
const backend_host_prod = "camelup.gigalixirapp.com";

const backend_host_ws =
  currentLocation.hostname === "localhost"
    ? "ws://" + backend_host_dev
    : "wss://" + backend_host_prod;
const backend_host_http =
  currentLocation.hostname === "localhost"
    ? "http://" + backend_host_dev
    : "https://" + backend_host_prod;

console.log(currentLocation);
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
let channel = socket.channel("games:lobby", {});

channel.on("broadcast_game_table", (payload) => {
  console.log(
    `JS: Receiving ${payload} game table data from Phoenix`,
    payload.gameTable
  );
  app.ports.receiveGameTable.send({ gameTable: payload.gameTable });
  console.log("JS finished sending game table to Elm");
});

app.ports.joinRoom.subscribe(function (room) {
  console.log(`JS will ask Phoenix to join room: `, room);
  channel = socket.channel("games:" + room);
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

// Action
socket.connect();

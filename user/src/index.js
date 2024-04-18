import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { ThirdwebProvider } from "@thirdweb-dev/react";
import "./styles/globals.css";




const Stavanger = {
  chainId: 686669576,
  name: "Stavanger",
  rpc: ["https://sn2-stavanger-rpc.eu-north-2.gateway.fm"],
  shortName: "Stavanger",
  chain: "Stavanger",
  slug: "stavanger",
  testnet: true,
  nativeCurrency: {
    name: "Ether",
    symbol: "ETH",
    decimals: 18,
  },
  explorers: [
    {
      name: "Blockscout",
      standard: "EIP3091",
      url: "https://sn2-stavanger-blockscout.eu-north-2.gateway.fm/",
    },
  ],
};


const container = document.getElementById("root");
const root = createRoot(container);
root.render(
  <React.StrictMode>
    <ThirdwebProvider
      activeChain={Stavanger}
      clientId={process.env.REACT_APP_TEMPLATE_CLIENT_ID}
    >
      <App />
    </ThirdwebProvider>
  </React.StrictMode>
);

